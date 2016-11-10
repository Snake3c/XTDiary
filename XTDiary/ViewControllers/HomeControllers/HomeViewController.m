//
//  HomeViewController.m
//  XTDiary
//
//  Created by 叶慧伟 on 2016/11/9.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "HomeViewController.h"
#import "XTCalendar.h"
#import "WriteViewController.h"

#define btnWidth 90
#define btnBottomMargin 100
#define btnMargin 50

@interface HomeViewController ()

@property (nonatomic, strong)UIButton *writeBtn;
@property (nonatomic, strong)UIButton *goBtn;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
}

- (void)setUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    XTCalendar *calendarView = [[XTCalendar alloc]initWithHeraderBackGroundColor:[UIColor cyanColor] andFrame:CGRectMake(0, 0, kScreenWidth, 300)];
    [self.view addSubview:calendarView];
    
    [self.view addSubview:self.writeBtn];
    [self.view addSubview:self.goBtn];
    
    [self btnAnimation];
}

- (void)btnAnimation{
    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:5 options:0 animations:^{
        [self.writeBtn setFrame:CGRectMake(btnMargin, kScreenHeight - btnBottomMargin - 70, btnWidth, btnWidth)];
        [self.goBtn setFrame:CGRectMake(kScreenWidth - btnMargin - btnWidth, kScreenHeight - btnBottomMargin - 70, btnWidth, btnWidth)];
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --Click--
- (void)writeBtnClick{
    WriteViewController *writeBtn = [[WriteViewController alloc]init];
    [self presentViewController:writeBtn animated:YES completion:nil];
}

#pragma mark --lazyload--
- (UIButton *)writeBtn{
    if (_writeBtn == nil) {
        _writeBtn = [UIButton buttonWithTitleColor:[UIColor blackColor] titleFontSize:13 buttonColor:nil state:UIControlStateNormal];
        [_writeBtn setImage:[UIImage imageNamed:@"练习"] forState:UIControlStateNormal];
        [_writeBtn setFrame:CGRectMake(kScreenWidth / 2 - btnWidth / 2, kScreenHeight - btnBottomMargin, btnWidth , btnWidth)];
        [_writeBtn addTarget:self action:@selector(writeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _writeBtn;
}

- (UIButton *)goBtn{
    if (_goBtn == nil) {
        _goBtn = [UIButton buttonWithTitleColor:[UIColor blackColor] titleFontSize:13 buttonColor:nil state:UIControlStateNormal];
        [_goBtn setImage:[UIImage imageNamed:@"路标"] forState:UIControlStateNormal];
        [_goBtn setFrame:CGRectMake(kScreenWidth / 2 - btnWidth / 2, kScreenHeight - btnBottomMargin, btnWidth , btnWidth)];

    }
    return _goBtn;
}

@end
