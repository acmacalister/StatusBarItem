////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  StatusBarPopupView.h
//  StatusBarItem
//
//  Created by Austin Cherry on 4/15/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

@interface StatusBarPopupView : NSView

@property(nonatomic, getter=isActive)BOOL active;
@property(nonatomic, assign)BOOL animated;
@property(nonatomic, assign)NSImage *image;
@property(nonatomic, strong)NSImage *alternateImage;
@property(nonatomic, strong)NSStatusItem *statusItem;

// init methods
- (id)initWithViewController:(NSViewController *)controller;
- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image;
- (id)initWithViewController:(NSViewController *)controller
                       image:(NSImage *)image
              alternateImage:(NSImage *)alternateImage;

// show / hide popover
- (void)showPopover;
- (void)showPopoverAnimated:(BOOL)animated;
- (void)hidePopover;

// view size
- (void)setContentSize:(CGSize *)size;

@end
