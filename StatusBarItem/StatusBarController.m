////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  StatusBarController.m
//  StatusBarItem
//
//  Created by Austin Cherry on 4/10/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import "StatusBarController.h"
#import "PopoverViewController.h"

@interface StatusBarController ()

@property (nonatomic, strong) NSStatusItem *item;
@property (nonatomic, assign, getter = isActive) BOOL active;

@end

@implementation StatusBarController

////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)init
{
    if(self = [super init])
    {
        CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
        self.item = [[NSStatusBar systemStatusBar] statusItemWithLength:thickness];
        self.view = [[StatusBarView alloc] initWithFrame:(NSRect){.size={thickness, thickness}}];
        self.view.delegate = self;
        [self.item setView:self.view];
        [self.item setHighlightMode:NO];
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupPopoverView
{
    if (!self.popover)
    {
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = [[PopoverViewController alloc] init];
        float width = self.popover.contentViewController.view.frame.size.width;
        float height = self.popover.contentViewController.view.frame.size.height;
        self.popover.contentSize = (CGSize){width, height};
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - StatusBarViewDelegate

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)menuletClicked
{
    self.active = !self.active;
    if (self.active)
    {
        [self setupPopoverView];
        [self.popover showRelativeToRect:[self.view frame]
                                  ofView:self.view
                           preferredEdge:NSMinYEdge];
    }
    else
        [self.popover performClose:self];
}
////////////////////////////////////////////////////////////////////////////////////////////////////

@end
