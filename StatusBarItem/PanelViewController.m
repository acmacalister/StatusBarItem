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
        [self processLoop];
        [self portsLoop];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)processLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        @autoreleasepool {
            NSTask *task = [[NSTask alloc] init]; // ps -eo pcpu,pid,user,command | sort -k 1 -r | head -6
            dispatch_async(dispatch_get_main_queue(), ^{
                // update the UI!!
            });
        }
    });
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)portsLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        @autoreleasepool {
            NSTask *task = [[NSTask alloc] init]; // lsof -i tcp:0-1024
            dispatch_async(dispatch_get_main_queue(), ^{
                // update the UI!!
            });
        }
    });
}
////////////////////////////////////////////////////////////////////////////////////////////////////

@end
