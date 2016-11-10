//
//  CustomNavViewController.m
//  NewCreate
//
//  Created by 叶慧伟 on 16/10/15.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "CustomNavViewController.h"

@interface CustomNavViewController ()<UIGestureRecognizerDelegate>

@end

@implementation CustomNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    if (self.childViewControllers.count > 0) {
        UIButton *button = [[UIButton alloc]init];
        [button setImage:[UIImage imageNamed:@"navigationbar_back_withtext"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
        viewController.hidesBottomBarWhenPushed = YES;
//    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)leftBtnClick{
    [self popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return self.childViewControllers.count > 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
