////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  StatusBarController.h
//  StatusBarItem
//
//  Created by Austin Cherry on 4/10/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "StatusBarView.h"

@interface StatusBarController : NSObject <StatusBarViewDelegate>

@property(nonatomic, strong)StatusBarView *view;
@property (nonatomic, strong) NSPopover *popover;

@end
