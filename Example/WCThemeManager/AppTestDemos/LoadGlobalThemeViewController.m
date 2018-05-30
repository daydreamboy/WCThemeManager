//
//  LoadGlobalThemeViewController.m
//  WCThemeManager_Example
//
//  Created by wesley_chen on 2018/5/30.
//  Copyright © 2018 daydreamboy. All rights reserved.
//

#import "LoadGlobalThemeViewController.h"
#import "WCThemeManager.h"

@interface LoadGlobalThemeViewController ()

@end

@implementation LoadGlobalThemeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = WCThemeColor(@"viewController-backgroundColor", [UIColor whiteColor]);
}

@end
