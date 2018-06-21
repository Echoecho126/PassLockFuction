//
//  ViewController.m
//  PassLockView
//
//  Created by Echo_RSQ on 2018/6/21.
//  Copyright © 2018年 Echo_RSQ. All rights reserved.
//

#import "ViewController.h"
#import "PassSwitchVC.h"
#import "PassLockView.h"

@interface ViewController ()<PassLockViewDelegate>
//密码锁
@property (nonatomic, strong) UIVisualEffectView *backLockPassEffectView;
@property (nonatomic, strong) PassLockView *lockPassView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    
    //app从后天进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(checkPassLockView) name:UIApplicationWillEnterForegroundNotification object:nil];
    //密码锁--忘记密码LockPassReload
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leaveOutUserAccount) name:@"LockPassReload" object:nil];
    
    UIButton *passBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:passBtn];
    passBtn.frame =CGRectMake(100, 100, 150, 100);
    passBtn.backgroundColor =[UIColor redColor];
    [passBtn setTitle:@"跳转到密码界面" forState:UIControlStateNormal];
    [passBtn addTarget:self action:@selector(passBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    //app启动时检查密码锁
    [self showCheckLockPassView];
}

#pragma mark app第一次启动，检查密码锁
-(void)showCheckLockPassView{
    [self checkPassLockView];
}

-(void)leaveOutUserAccount{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //重新设置登录界面--此处重设根控制器
    ViewController *loadRegiterVc =[[ViewController alloc]init];
    loadRegiterVc.view.backgroundColor =[UIColor lightGrayColor];
    UINavigationController *navVC =[[UINavigationController alloc]initWithRootViewController:loadRegiterVc];
    [UIApplication sharedApplication].keyWindow.rootViewController =navVC;
}

-(void)checkPassLockView{
    
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    NSString *lockPass =[userDefaults objectForKey:@"LockPass"];
    
    if (lockPass.length >0 && self.lockPassView ==nil) {
        PassLockView *lockView =[[PassLockView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH) lockPassType:LockPassTypeInForegroud];
        self.lockPassView =lockView;
        lockView.delegate =self;
        
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        [[UIApplication sharedApplication].keyWindow addSubview:self.backLockPassEffectView];
        [[UIApplication sharedApplication].keyWindow addSubview:lockView];
    }
}

-(void)closeViewWithSetSussessOrCloseBtnClickIsSet:(BOOL)successSetPass{
    
    if (self.backLockPassEffectView) {
        [self.backLockPassEffectView removeFromSuperview];
        self.backLockPassEffectView = nil;
    }
    if (self.lockPassView) {
        [self.lockPassView removeFromSuperview];
        self.lockPassView =nil;
    }
}

#pragma mark 跳转密码相关界面
-(void)passBtnClick{
    
    PassSwitchVC *aaVC =[[PassSwitchVC alloc]init];
    [self.navigationController pushViewController:aaVC animated:YES];
}

#pragma mark  懒加载
-(UIVisualEffectView *)backLockPassEffectView{
    if (!_backLockPassEffectView) {
        UIBlurEffect *beffect   = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _backLockPassEffectView = [[UIVisualEffectView alloc]initWithEffect:beffect];
        _backLockPassEffectView.frame = CGRectMake(0, 0,ScreenW,ScreenH);
    }
    return _backLockPassEffectView;
}
@end
