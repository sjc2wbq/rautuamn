//
//  LocationViewController.m
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonItemPressed:)];
}
- (void)leftBarButtonItemPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
