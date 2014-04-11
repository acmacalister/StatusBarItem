////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AppDelegate.m
//  StatusBarItem
//
//  Created by Austin Cherry on 4/8/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import "AppDelegate.h"
#import "StatusBarController.h"

@interface AppDelegate ()

@property(nonatomic, strong)StatusBarController *controller;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    self.controller = [[StatusBarController alloc] init];

}
@end
