////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  StatusBarView.m
//  StatusBarItem
//
//  Created by Austin Cherry on 4/10/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import "StatusBarView.h"

static void *kActiveChangedKVO = &kActiveChangedKVO;

@implementation StatusBarView

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<StatusBarViewDelegate>)newDelegate
{
    [(NSObject *)newDelegate addObserver:self
                              forKeyPath:@"active"
                                 options:NSKeyValueObservingOptionNew
                                 context:kActiveChangedKVO];
    _delegate = newDelegate;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(NSRect)rect
{
    NSImage *menuletIcon;
    if ([self.delegate isActive])
    {
        menuletIcon = [NSImage imageNamed:@"Moon_Full.png"];
        [[NSColor selectedMenuItemColor] set]; /* blueish */
    }
    else
    {
        menuletIcon = [NSImage imageNamed:@"Moon_New.png"];
        [[NSColor clearColor] set];
    }
    NSRectFill(rect);
    [menuletIcon drawInRect:NSInsetRect(rect, 2, 2)
                   fromRect:NSZeroRect operation:NSCompositeSourceOver
                   fraction:1.0];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mouseDown:(NSEvent *)event
{
    [self.delegate menuletClicked];
}
////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - KVO

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kActiveChangedKVO)
    {
        [self setNeedsDisplay:YES];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////

@end
