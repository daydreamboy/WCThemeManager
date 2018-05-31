//
//  LoadDefaultThemeViewController.m
//  WCThemeManager_Example
//
//  Created by wesley_chen on 2018/5/30.
//  Copyright © 2018 daydreamboy. All rights reserved.
//

#import "LoadDefaultThemeViewController.h"
#import <WCThemeManager/WCThemeManager.h>

@interface LoadDefaultThemeViewController ()

@end

@implementation LoadDefaultThemeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = WCThemeColor(@"viewController-backgroundColor", [UIColor whiteColor]);
}

@end
