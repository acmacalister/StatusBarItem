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
#import "StatusBarPopupView.h"
#import "PanelViewController.h"

@interface AppDelegate ()

@property(nonatomic, strong)StatusBarPopupView *popupView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    PanelViewController *panelViewController = [[PanelViewController alloc] initWithNibName:@"PanelViewController" bundle:nil];
    
    // init the status item popup
    NSImage *image = [NSImage imageNamed:@"Moon_New"];
    NSImage *alternateImage = [NSImage imageNamed:@"Moon_Full"];
    
    self.popupView = [[StatusBarPopupView alloc] initWithViewController:panelViewController
                                                                  image:image
                                                         alternateImage:alternateImage];
}
@end
