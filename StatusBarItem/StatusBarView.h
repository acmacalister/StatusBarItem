////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  StatusBarView.h
//  StatusBarItem
//
//  Created by Austin Cherry on 4/10/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

@protocol StatusBarViewDelegate <NSObject>

- (BOOL)isActive;
- (void)menuletClicked;

@end

@interface StatusBarView : NSView

@property (nonatomic, weak) id<StatusBarViewDelegate> delegate;

@end
