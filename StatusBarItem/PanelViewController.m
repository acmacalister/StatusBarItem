////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  PanelViewController.m
//  StatusBarItem
//
//  Created by Austin Cherry on 4/15/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import "PanelViewController.h"
#import "ACTableSource.h"
#import "TextTableViewCell.h"

@interface PanelViewController ()<ACTableSourceDelegate>

@property (weak) IBOutlet NSView *processesView;
@property (weak) IBOutlet NSView *portsView;
@property (weak) IBOutlet NSTableView *processTableView;
@property (nonatomic,strong)ACTableSource *dataSource;
@property(nonatomic, strong)NSMutableArray *processItems;

@end

@implementation PanelViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(processLoop) userInfo:nil repeats:YES];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(portsLoop) userInfo:nil repeats:YES];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)awakeFromNib
{
    self.dataSource = [[ACTableSource alloc] init];
    self.dataSource.delegate = self;
    self.processTableView.dataSource = self.dataSource;
    self.processTableView.delegate = self.dataSource;
    
    self.processItems = [NSMutableArray array];
    
    [self.dataSource bindArrays:@[self.processItems] toTableView:self.processTableView];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)processLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        @autoreleasepool {
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/bin/sh";
            task.arguments = @[@"-c", @"ps -eo pcpu,pid,comm | sed 1d | sort -k 1 -r | head -10"];
            NSPipe *pipe;
            pipe = [NSPipe pipe];
            [task setStandardOutput:pipe];
            NSFileHandle *file = [pipe fileHandleForReading];
            [task launch];
            NSData *data = [file readDataToEndOfFile];
            NSString *string = [NSString stringWithUTF8String:[data bytes]];
            if(string)
            {
                NSArray *items = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                [self.processItems addObjectsFromArray:items];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.processTableView reloadData];
            });
        }
    });
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)portsLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        @autoreleasepool {
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/usr/sbin/lsof";
            task.arguments = @[@"-i", @"tcp:0-1024"];
            NSPipe *pipe;
            pipe = [NSPipe pipe];
            [task setStandardOutput:pipe];
            NSFileHandle *file = [pipe fileHandleForReading];
            [task launch];
            NSData *data = [file readDataToEndOfFile];
            NSString *string = [NSString stringWithUTF8String:[data bytes]];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"[data]: %@", string);
            });
        }
    });
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)classForObject:(id)object
{
    return [TextTableViewCell class];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    self.dataSource = nil;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
@end
