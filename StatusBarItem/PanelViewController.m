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

@interface PanelViewController ()
@property (weak) IBOutlet NSView *processesView;
@property (weak) IBOutlet NSView *portsView;

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
            dispatch_async(dispatch_get_main_queue(), ^{
                // update the UI!!
                NSLog(@"[data]: %@", string);
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
                // update the UI!!
                NSLog(@"[data]: %@", string);
            });
        }
    });
}
////////////////////////////////////////////////////////////////////////////////////////////////////

@end
