//
//  SafeLockNumVC.m
//  PassLok
//
//  Created by Echo_RSQ on 2017/12/27.
//  Copyright © 2017年 Echo_RSQ. All rights reserved.
//

#import "SafeLockNumVC.h"

@interface SafeLockNumVC ()<PassLockViewDelegate>

@end

@implementation SafeLockNumVC

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    
    [self loadAllUI];
}

#pragma  mark 关闭
-(void)closeViewWithSetSussessOrCloseBtnClickIsSet:(BOOL)successSetPass{
    
    if ([self.delegate respondsToSelector:@selector(closeVCWhenSuccessSetPass:)]) {
        [self.delegate closeVCWhenSuccessSetPass:successSetPass];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadAllUI{
    
    PassLockView *passView =[[PassLockView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH) lockPassType:self.passType];
    passView.delegate = self;
    [self.view addSubview:passView];
}

@end
