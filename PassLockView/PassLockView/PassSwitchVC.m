//
//  PassSwitchVC.m
//  PassLockView
//
//  Created by Echo_RSQ on 2018/6/21.
//  Copyright © 2018年 Echo_RSQ. All rights reserved.
//

#import "PassSwitchVC.h"
#import "SafeLockNumVC.h"

@interface PassSwitchVC ()<SafeLockNumVCDelegate>
@property(nonatomic, assign) BOOL synNumLock;
@property(nonatomic,   weak) UIButton *changePassBtn;
@property(nonatomic,   weak) UIButton *passBtn;
@end

@implementation PassSwitchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    [self initData];
    [self addAllUI];
}

-(void)initData{
    
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    NSString *lockPass =[userDefaults objectForKey:@"LockPass"];
    NSLog(@"lockPass===%@",lockPass);
    
    self.synNumLock = lockPass.length >0 ? YES : NO;
}

-(void)addAllUI{
    
    UIButton *passBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.passBtn = passBtn;
    [self.view addSubview:passBtn];
    passBtn.frame=CGRectMake(100, 100, 200, 100);
    passBtn.backgroundColor =[UIColor greenColor];
    [passBtn setTitle:@"设置密码" forState:UIControlStateNormal];
    [passBtn setTitle:@"关闭密码" forState:UIControlStateSelected];
    [passBtn addTarget:self action:@selector(passBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *changePassBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    self.changePassBtn =changePassBtn;
    [self.view addSubview:changePassBtn];
    changePassBtn.frame=CGRectMake(100, 200, 200, 100);
    changePassBtn.backgroundColor =[UIColor redColor];
    [changePassBtn setTitle:@"修改密码" forState:UIControlStateNormal];
    [changePassBtn addTarget:self action:@selector(changePassBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    passBtn.selected     =self.synNumLock;
    changePassBtn.hidden =!self.synNumLock;
}

-(void)passBtnClick{

    SafeLockNumVC *numVc =[[SafeLockNumVC alloc]init];
    numVc.delegate=self;
    if (!self.passBtn.isSelected) {
        //设置密码
        numVc.passType = LockPassTypeSet;
    }else{
        //关闭密码
        numVc.passType = LockPassTypeClose;
        self.changePassBtn.hidden = YES;
    }
    
    [self presentViewController:numVc animated:YES completion:nil];
}

-(void)changePassBtnClick{
    //修改密码
    SafeLockNumVC *numVc =[[SafeLockNumVC alloc]init];
    numVc.passType =LockPassTypeReset;
    numVc.delegate =self;
    [self presentViewController:numVc animated:YES completion:nil];
}

#pragma  mark SafeLockNumVC 代理
-(void)closeVCWhenSuccessSetPass:(BOOL)successSetPass{
    self.synNumLock = successSetPass;
    
    self.passBtn.selected =successSetPass;
    self.changePassBtn.hidden = !successSetPass;
}

@end
