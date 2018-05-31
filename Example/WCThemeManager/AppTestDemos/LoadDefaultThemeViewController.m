//
//  LoadDefaultThemeViewController.m
//  WCThemeManager_Example
//
//  Created by wesley_chen on 2018/5/30.
//  Copyright © 2018 daydreamboy. All rights reserved.
//

#import "LoadDefaultThemeViewController.h"
#import <WCThemeManager/WCThemeManager.h>

#define KEY_IMAGE           @"image"
#define KEY_TITLE_COLOR     @"title_color"
#define KEY_TITLE           @"title"

@interface LoadDefaultThemeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *listData;
@end

@implementation LoadDefaultThemeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _listData = @[
                      @{
                          KEY_IMAGE: @"1"
                          },
                      @{
                          KEY_IMAGE: @"2"
                          },
                      @{
                          KEY_IMAGE: @"3"
                          },
                      @{
                          KEY_IMAGE: @"4"
                          },
                      @{
                          KEY_IMAGE: @"5"
                          },
                      @{
                          KEY_IMAGE: @"6"
                          },
                      @{
                          KEY_IMAGE: @"7"
                          },
                      @{
                          KEY_IMAGE: @"8"
                          },
                      @{
                          KEY_IMAGE: @"9"
                          },
                      @{
                          KEY_IMAGE: @"10"
                          },
                      ];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = WCThemeColor(@"viewController-backgroundColor", [UIColor whiteColor]);
    
    [self.view addSubview:self.tableView];
}

#pragma mark - Getters

- (UITableView *)tableView {
    if (!_tableView) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat tableViewHeight = 500;
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, screenSize.width, tableViewHeight) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        
        _tableView = tableView;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sCellIdentifier = @"sCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sCellIdentifier];
    }
    
    NSDictionary *attrs = self.listData[indexPath.row];
    cell.imageView.image = WCThemeImage(attrs[KEY_IMAGE], nil);
    
    return cell;
}

@end
