//
//  LoadCustomThemeViewController.m
//  WCThemeManager_Example
//
//  Created by wesley_chen on 2018/5/31.
//  Copyright © 2018 daydreamboy. All rights reserved.
//

#import "LoadCustomThemeViewController.h"
#import <WCThemeManager/WCThemeManager.h>

@interface LoadCustomThemeViewController ()

@end

@implementation LoadCustomThemeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    WCTheme *theme = [[WCThemeManager sharedInstance] registeredThemeWithName:@"appTheme"];
    self.view.backgroundColor = [theme colorForKey:@"viewController-backgroundColor" defaultColor:[UIColor whiteColor]];
}

@end
