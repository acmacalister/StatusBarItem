////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  StatusBarPopupView.m
//  StatusBarItem
//
//  Created by Austin Cherry on 4/15/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import "StatusBarPopupView.h"

#define kMinViewWidth 16

@interface StatusBarPopupView ()

@property(nonatomic, strong)NSViewController *viewController;
@property(nonatomic, strong)NSImageView *imageView;
@property(nonatomic, strong)NSPopover *popover;
@property(nonatomic, strong)id popoverTransiencyMonitor;

@end

@implementation StatusBarPopupView

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithViewController:(NSViewController *)controller
{
    return [self initWithViewController:controller image:nil];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image
{
    return [self initWithViewController:controller image:image alternateImage:nil];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithViewController:(NSViewController *)controller
                       image:(NSImage *)image
              alternateImage:(NSImage *)alternateImage
{
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    
    self = [super initWithFrame:NSMakeRect(0, 0, kMinViewWidth, height)];
    if (self)
    {
        self.viewController = controller;
        
        self.image = image;
        self.alternateImage = alternateImage;
        
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, kMinViewWidth, height)];
        [self addSubview:self.imageView];
        
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        self.statusItem.view = self;
        
        self.active = NO;
        self.animated = YES;
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - drawing

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(NSRect)dirtyRect
{
    // set view background color
    if (self.active)
        [[NSColor selectedMenuItemColor] setFill];
    else
        [[NSColor clearColor] setFill];
    
    NSRectFill(dirtyRect);
    
    // set image
    NSImage *image = (self.active ? self.alternateImage : self.image);
    self.imageView.image = image;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateViewFrame
{
    CGFloat width = MAX(MAX(kMinViewWidth, self.alternateImage.size.width), self.image.size.width);
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    
    NSRect frame = NSMakeRect(0, 0, width, height);
    self.frame = frame;
    self.imageView.frame = frame;
    
    [self setNeedsDisplay:YES];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentSize:(CGSize *)size
{
    self.popover.contentSize = *size;
}
////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Mouse Events

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mouseDown:(NSEvent *)theEvent
{
    if (self.popover.isShown)
        [self hidePopover];
    else
        [self showPopover];
}
////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Setter

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setActive:(BOOL)active
{
    _active = active;
    [self setNeedsDisplay:YES];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImage:(NSImage *)image
{
    _image = image;
    [self updateViewFrame];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setAlternateImage:(NSImage *)image
{
    _alternateImage = image;
    if (!image && _image)
        _alternateImage = _image;
    [self updateViewFrame];
}
////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Show/Hide Popover

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showPopover
{
    [self showPopoverAnimated:self.animated];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showPopoverAnimated:(BOOL)animated
{
    self.active = YES;
    
    if (!self.popover)
    {
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = self.viewController;
    }
    
    if (!self.popover.isShown)
    {
        self.popover.animates = animated;
        [self.popover showRelativeToRect:self.frame ofView:self preferredEdge:NSMinYEdge];
        self.popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask handler:^(NSEvent* event) {
            [self hidePopover];
        }];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hidePopover
{
    self.active = NO;
    
    if (self.popover && self.popover.isShown)
    {
        [self.popover close];
        
		if (self.popoverTransiencyMonitor)
        {
            [NSEvent removeMonitor:_popoverTransiencyMonitor];
            self.popoverTransiencyMonitor = nil;
        }
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
@end
