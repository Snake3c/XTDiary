//
//  WriteViewController.m
//  XTDiary
//
//  Created by 叶慧伟 on 2016/11/9.
//  Copyright © 2016年 叶慧伟. All rights reserved.
//

#import "WriteViewController.h"

@interface WriteViewController ()

@property (nonatomic, strong)UIButton *coleseBtn;

@end

@implementation WriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUI];
}

- (void)setUI{
    self.coleseBtn = ({
        UIButton *colesedBtn = [[UIButton alloc]init];
        [self.view addSubview:colesedBtn];
        [colesedBtn setImage:[UIImage imageNamed:@"叉"] forState:UIControlStateNormal];
        [colesedBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [colesedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(30);
            make.top.equalTo(self.view).offset(40);
            make.width.height.equalTo(@30);
        }];
        
        colesedBtn;
    });
}

- (void)closeBtnClick{
    [self dismissViewControllerAnimated:YES completion:nil];
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
