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

@property (weak) IBOutlet NSTableView *processTableView;
@property (nonatomic,strong)ACTableSource *dataSource;
@property(nonatomic, strong)NSMutableArray *cpuItems;
@property(nonatomic, strong)NSMutableArray *pidItems;
@property(nonatomic, strong)NSMutableArray *processItems;

@property (weak) IBOutlet NSTableView *portTableView;
@property (nonatomic,strong)ACTableSource *portDataSource;
@property(nonatomic, strong)NSMutableArray *portPidItems;
@property(nonatomic, strong)NSMutableArray *portComItems;
@property(nonatomic, strong)NSMutableArray *portNameItems;


- (IBAction)notSafeToGoAlone:(id)sender;

@end

@implementation PanelViewController

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(processLoop) userInfo:nil repeats:YES];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(portsLoop) userInfo:nil repeats:YES];
        DDLogCInfo(@"[INFO] Time to be official...");
        DDLogCInfo(@"[INFO] Initializing process information loop.");
        DDLogCInfo(@"[INFO] Initializing port information loop.");
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
    
    self.cpuItems = [NSMutableArray array];
    self.pidItems = [NSMutableArray array];
    self.processItems = [NSMutableArray array];
    
    [self.dataSource bindArrays:@[self.cpuItems, self.pidItems, self.processItems] toTableView:self.processTableView];
    
    self.portDataSource = [[ACTableSource alloc] init];
    self.portDataSource.delegate = self;
    self.portTableView.dataSource = self.portDataSource;
    self.portTableView.delegate = self.portDataSource;
    
    self.portPidItems = [NSMutableArray array];
    self.portComItems = [NSMutableArray array];
    self.portNameItems = [NSMutableArray array];
    
    [self.portDataSource bindArrays:@[self.portPidItems, self.portComItems, self.portNameItems] toTableView:self.portTableView];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)processLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        @autoreleasepool {
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/bin/sh";
            task.arguments = @[@"-c", @"ps -eo pcpu,pid,comm | sed 1d | sort -k 1 -r | head -30 | awk '{print $1 \"-\" $2 \"-\" $3 \" \" $5 \" \" $8}'"];
            NSPipe *pipe;
            pipe = [NSPipe pipe];
            [task setStandardOutput:pipe];
            NSFileHandle *file = [pipe fileHandleForReading];
            [task launch];
            NSData *data = [file readDataToEndOfFile];
            NSString *string = [NSString stringWithUTF8String:[data bytes]];
            if(string)
            {
                [self.cpuItems removeAllObjects];
                [self.pidItems removeAllObjects];
                [self.processItems removeAllObjects];
                NSArray *items = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                for(NSString *item in items)
                {
                    if(item.length > 0)
                    {
                        NSArray *temp = [item componentsSeparatedByString:@"-"];
                        if(temp.count == 3)
                        {
                            [self.cpuItems addObject:temp[0]];
                            [self.pidItems addObject:temp[1]];
                            [self.processItems addObject:[[temp[2] componentsSeparatedByString:@"/"] lastObject]];
                        }
                    }

                }
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
            task.arguments = @[@"-F", @"cn", @"-i", @"tcp:0-1024"];
            NSPipe *pipe;
            pipe = [NSPipe pipe];
            [task setStandardOutput:pipe];
            NSFileHandle *file = [pipe fileHandleForReading];
            [task launch];
            NSData *data = [file readDataToEndOfFile];
            NSString *string = [NSString stringWithUTF8String:[data bytes]];
            if(string)
            {
                [self.portNameItems removeAllObjects];
                [self.portPidItems removeAllObjects];
                [self.portComItems removeAllObjects];
                NSArray *items = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                NSMutableArray *names = [NSMutableArray array];
                for(NSString *item in items)
                {
                    if(item.length == 0)
                        continue;
                    NSString *val = [item substringFromIndex:1];
                    if([item hasPrefix:@"p"])
                    {
                        if(names.count > 0)
                        {
                            NSString *name = [names componentsJoinedByString:@","];
                            [self.portNameItems addObject:name];
                            [names removeAllObjects];
                        }
                        [self.portPidItems addObject:val];
                    }
                    else if([item hasPrefix:@"c"])
                    {
                        [self.portComItems addObject:val];
                    }
                    else if([item hasPrefix:@"n"])
                    {
                        [names addObject:[[val componentsSeparatedByString:@":"] lastObject]];
                    }
                }
                NSString *name = [names componentsJoinedByString:@","];
                [self.portNameItems addObject:name];
                [names removeAllObjects];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
               [self.portTableView reloadData];
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
    self.portDataSource = nil;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)notSafeToGoAlone:(id)sender
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"It's not safe to go alone!" defaultButton:@"Claim Destiny!"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"Legend of Zelda nerdiness"];
    [alert runModal];
    DDLogCError(@"[ERROR] This is a sample error to warn users of unsafe conditions");
}
////////////////////////////////////////////////////////////////////////////////////////////////////
@end
