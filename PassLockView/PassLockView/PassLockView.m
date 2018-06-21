//
//  PassLockView.m
//  PassLok
//
//  Created by Echo_RSQ on 2017/12/27.
//  Copyright © 2017年 Echo_RSQ. All rights reserved.
//

#import "PassLockView.h"
#import "Masonry.h"
#define RSQColorFromHex(rgbValue)        [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0f green:((float)((rgbValue & 0xFF00) >> 8))/255.0f blue:((float)(rgbValue & 0xFF))/255.0f alpha:1.0f]

@interface PassLockView()
@property (nonatomic,assign) LockPassType passType;//当前所处界面

@property (nonatomic,strong) UIView  *pointBackView;//圆点
@property (nonatomic,strong) UILabel *tipLabel;//提示文本

@property (nonatomic,weak) UIView *bluePoint1;
@property (nonatomic,weak) UIView *bluePoint2;
@property (nonatomic,weak) UIView *bluePoint3;
@property (nonatomic,weak) UIView *bluePoint4;

@property (nonatomic,  copy) UIColor *textBorderColor;

@property (nonatomic,assign) NSInteger tapCount;//点击次数，0开始，点击+1，删除-1
@property (nonatomic,copy) NSString *passStr1;//第一遍
@property (nonatomic,copy) NSString *passStr2;//第2+遍

//重置密码时，还有几次输入机会
@property (nonatomic,assign) NSInteger chanceNum;
@property (nonatomic,assign) BOOL reSetAgain;//验证救旧密码后，重新设置密码
@property (nonatomic,copy) NSString *originalPass;//重置密码时的原始密码

@end

@implementation PassLockView

- (instancetype)initWithFrame:(CGRect)frame lockPassType:(LockPassType)passType{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.passType =passType;
        [self addAllUI];
    }
    return self;
}

-(void)addAllUI{
    if (self.passType == LockPassTypeInForegroud) {
        self.backgroundColor = [UIColor clearColor];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
    
    self.tapCount = 0;
    self.textBorderColor = RSQColorFromHex(0x8c8c8c);
    
    //重置和关闭用到
    self.chanceNum =3;
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    NSString *pass =[userDefaults objectForKey:@"LockPass"];
    if (pass.length >0) {
        self.originalPass =pass;
    }
    
    NSString *titleStr =@"设置密码";
    NSString *tipStr   =@"请输入密码";
    if (self.passType == LockPassTypeReset) {
        titleStr =@"重置密码";
        tipStr =@"请输入原密码";
    }else if (self.passType == LockPassTypeClose){
        titleStr =@"验证密码";
    }
    
    if (self.passType == LockPassTypeInForegroud) {
        self.textBorderColor = [UIColor whiteColor];
    }else{
        
        //模拟导航
        UIView *line =[[UIView alloc]initWithFrame:CGRectMake(0, SafeTopHeight, ScreenW, 0.5)];
        [self addSubview:line];
        line.backgroundColor =RSQColorFromHex(0xE0E0E0);
        
        CGFloat btnY = 29;
        CGFloat titleY = 28;
        if (SafeTopHeight == 88) {
            btnY += 24;
            titleY +=24;
        }
        
        UIButton *closeBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:closeBtn];
        [closeBtn setImage:[UIImage imageNamed:@"CloseBlack"] forState:UIControlStateNormal];
        closeBtn.adjustsImageWhenHighlighted =NO;
        closeBtn.frame =CGRectMake(12, btnY, 24, 24);
        [closeBtn addTarget:self action:@selector(closePassView) forControlEvents:UIControlEventTouchUpInside];
        UILabel *titleLable =[[UILabel alloc]init];
        [self addSubview:titleLable];
        [self setLabelFont:[UIFont systemFontOfSize:19] textAligement:NSTextAlignmentCenter textColor:RSQColorFromHex(0x4a4a4a) andText:tipStr label:titleLable];
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(130, 26));
            make.top.equalTo(self).offset(titleY);
            make.centerX.equalTo(self);
        }];
    }
    
    CGFloat pointWH = 10;
    CGFloat offset  = 2;//蓝点和空心圆 半径差2
    CGFloat centerSpace = 40.0 *ScaleScreenW;
    CGFloat widthPointV = pointWH * 4 + 3 *centerSpace;
    //为了加动画，把四个圆点点放在一起
    self.pointBackView =[[UIView alloc]init];
    [self addSubview:self.pointBackView];
    self.pointBackView.backgroundColor =[UIColor clearColor];
    [self.pointBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(69*ScaleScreenH + 64);
        make.centerX.equalTo(self);
        make.height.equalTo(@(pointWH+ offset));
        make.width.equalTo(@(widthPointV));
    }];
    
    CGFloat pointX = 0;
    for (NSInteger i = 0 ; i <4; i ++) {
        UIView *point =[[UIView alloc]init];
        [self.pointBackView addSubview:point];
        point.backgroundColor =[UIColor clearColor];
        point.layer.cornerRadius = pointWH * 0.5;
        point.layer.borderColor = self.textBorderColor.CGColor;
        point.layer.borderWidth =1;
        pointX = i* (pointWH + centerSpace);
        
        [point mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(pointX));
            make.size.mas_equalTo(CGSizeMake(pointWH, pointWH));
            make.top.equalTo(self.pointBackView).offset(0.5 *offset);
        }];
        
        //设置密码时的蓝点
        UIView *bluePoint =[[UIView alloc]init];
        [self.pointBackView addSubview:bluePoint];
        if (self.passType == LockPassTypeInForegroud) {
            bluePoint.backgroundColor = [UIColor whiteColor];
        }else{
            bluePoint.backgroundColor = RSQColorFromHex(0x55abfd);
        }
        bluePoint.layer.cornerRadius =(pointWH + offset) *0.5;
        bluePoint.hidden =YES;
        if (i == 0) {
            self.bluePoint1 = bluePoint;
        }else if (i ==1){
            self.bluePoint2 = bluePoint;
        }else if (i ==2){
            self.bluePoint3 = bluePoint;
        }else{
            self.bluePoint4 = bluePoint;
        }
        
        [bluePoint mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(pointWH +offset, pointWH + offset));
            make.centerX.equalTo(point.mas_centerX);
            make.centerY.equalTo(point.mas_centerY);
        }];
    }
    
    self.tipLabel =[[UILabel alloc]init];
    [self addSubview:self.tipLabel];
    [self setLabelFont:[UIFont systemFontOfSize:13] textAligement:NSTextAlignmentCenter textColor:self.textBorderColor andText:tipStr label:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.pointBackView.mas_centerX);
        make.top.equalTo(self.pointBackView.mas_bottom).offset(28);
        make.height.equalTo(@(18));
    }];
    
    CGFloat btnWH = 60 *ScaleScreenW;
    CGFloat btnCenterSpace = (ScreenW - 3 *btnWH) /4;
    CGFloat btnCenterHeight = 31 *ScaleScreenH;
    CGFloat btnTopY = ScreenH - 40*ScaleScreenH - 3*btnCenterHeight - 4 *btnWH;
    
    CGFloat x =btnCenterSpace;
    CGFloat y =btnTopY;
    NSInteger row =0;
    NSInteger collum =0;
    
    for (NSInteger i =0 ; i< 12; i ++) {
        
        UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        btn.layer.cornerRadius =btnWH *0.5;
        btn.layer.borderWidth =1;
        btn.layer.borderColor=self.textBorderColor.CGColor;
        [btn.titleLabel setFont:[UIFont systemFontOfSize:30]];
        [btn setTitleColor:self.textBorderColor forState:UIControlStateNormal];
        btn.tag = i + 1;
        
        row = i /3;
        collum = i%3;
        x = collum*(btnWH + btnCenterSpace) + btnCenterSpace;
        y = btnTopY + row * (btnWH + btnCenterHeight);
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(btnWH, btnWH));
            make.left.equalTo(@(x));
            make.top.equalTo(@(y));
        }];
        
        if (i != 11) {
            [btn setTitle:[NSString stringWithFormat:@"%ld",i+1] forState:UIControlStateNormal];
        }
        
        //找回密码
        if (i == 9) {
            btn.layer.borderColor=[UIColor clearColor].CGColor;
            [btn.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [btn setTitle:@"忘记密码" forState:UIControlStateNormal];
            if(self.passType == LockPassTypeSet){
                btn.hidden =YES;
            }
        }
        
        //按钮 0
        if (i == 10) {
            btn.tag =0;
            [btn setTitle:@"0" forState:UIControlStateNormal];
        }
        
        //撤销按钮
        if (i == 11) {
            NSString *imgName =@"PassDeleteGray";
            if (self.passType == LockPassTypeInForegroud) {
                imgName =@"PassDeletewhite";
            }
            btn.layer.borderColor=[UIColor clearColor].CGColor;
            [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            [btn setContentMode:UIViewContentModeCenter];
            btn.adjustsImageWhenHighlighted =NO;
        }
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(buttonAction:forEvent:) forControlEvents:UIControlEventAllTouchEvents];
    }
}

-(void)setLabelFont:(UIFont *)font textAligement:(NSTextAlignment )alignment textColor:(UIColor *)color andText:(NSString *)text label:(UILabel *)label{
    label.font = font;
    label.textAlignment = alignment;
    label.textColor = color;
    label.text = text;
}

//按压拖拽
-(void)buttonAction:(UIButton *)sender forEvent:(UIEvent *)event{
    
    UITouchPhase phase = event.allTouches.anyObject.phase;
    if (phase == UITouchPhaseBegan) {
        sender.backgroundColor = RSQColorFromHex(0xf5f5f5);
    }
    
    if(phase == UITouchPhaseEnded || phase == UITouchPhaseCancelled ){
        sender.backgroundColor = [UIColor clearColor];
    }
}

//关闭按钮
-(void)closePassView{
    if (self.passType == LockPassTypeSet) {
        if ([self.delegate respondsToSelector:@selector(closeViewWithSetSussessOrCloseBtnClickIsSet:)]) {
            [self.delegate closeViewWithSetSussessOrCloseBtnClickIsSet:NO];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(closeViewWithSetSussessOrCloseBtnClickIsSet:)]) {
            [self.delegate closeViewWithSetSussessOrCloseBtnClickIsSet:YES];
        }
    }
}

#pragma mark 按钮点击事件0-11
-(void)btnClick:(UIButton *)btn{
    btn.backgroundColor =[UIColor clearColor];
    
    NSInteger btnTag =btn.tag;
    if(btnTag < 10){
        //号码按钮 点击
        self.tapCount += 1;
        [self numBtnClickWithBtnNum:btnTag];
        
    }else if(btnTag ==10){
        //忘记密码 点击
        [self loadAccountAgain];
        
    }else if (btnTag ==12){
        //删除按钮 点击
        if (self.tapCount !=0 && self.tapCount != 4) {
            self.tapCount -=1;
            [self deleteBtnClick];
        }
    }
}

//点击数字按钮
-(void)numBtnClickWithBtnNum:(NSInteger)btnTag{
    
    NSInteger countNow = self.tapCount % 4;
    //1.记录密码
    if(self.passStr1.length == 0){
        self.passStr1 =[NSString stringWithFormat:@"%ld",(long)btnTag];
    }else if(self.passStr1.length <4){
        self.passStr1 =[NSString stringWithFormat:@"%@%ld",self.passStr1,(long)btnTag];
    }else{
        //第2+次设置密码
        if (self.passStr2.length ==0) {
            self.passStr2 =[NSString stringWithFormat:@"%ld",(long)btnTag];
        }else if (self.passStr2.length <4){
            self.passStr2 =[NSString stringWithFormat:@"%@%ld",self.passStr2,(long)btnTag];
        }
    }
    //    NSLog(@"添加----密码1= %@,密码2==%@",self.passStr1,self.passStr2);
    
    //1.蓝点显示/隐藏+动画
    if(countNow ==1){
        self.bluePoint1.hidden =NO;
    }else if (countNow ==2){
        self.bluePoint2.hidden =NO;
    }else if (countNow ==3){
        self.bluePoint3.hidden =NO;
    }else{
        self.bluePoint4.hidden =NO;
        
        if (self.tapCount == 4) {
            
            //第一遍密码输入之后提示
            [self check1PassAfterSet];
            
        }else if (self.tapCount ==8){
            
            if(self.passType == LockPassTypeSet){
                //第2遍密码输入后，检查是否一样
                [self check2PassIsSame];
                
            }else if (self.passType == LockPassTypeReset){
                //第2遍密码输入后，检查是否一样
                [self check2PassIsSame];
                
            }else if(self.passType == LockPassTypeInForegroud){
                
            }
        }
    }
}

//删除按钮点击
-(void)deleteBtnClick{
    
    NSInteger countNow = self.tapCount % 4;
    if (countNow ==1) {
        self.bluePoint2.hidden =YES;
    }else if (countNow ==2){
        self.bluePoint3.hidden =YES;
    }else if (countNow ==3){
        
    }else if (countNow ==0){
        self.bluePoint1.hidden =YES;
    }
    
    if (self.passStr1.length == 0) {
        //小蓝点全部删除后，再点击删除，不做处理
    }else if (self.passStr1.length < 4){
        //第一遍输入密码时--删除点击
        NSString *subStr =[self.passStr1 substringToIndex:self.passStr1.length -1];
        self.passStr1 =[NSString stringWithFormat:@"%@",subStr];
    }else if (self.passStr1.length ==4){
        //第一遍已经有四位时，删除的第二遍+的数字
        if (self.passStr1.length ==0) {
            //第二遍+ 清空了密码
        }else if(self.passStr2.length <4){
            NSString *subStr =[self.passStr2 substringToIndex:self.passStr2.length -1];
            self.passStr2 =[NSString stringWithFormat:@"%@",subStr];
        }else if (self.passStr2.length ==4){
            
        }else{}
    }else{}
}

//机会用完; 忘记密码---重新登录
-(void)loadAccountAgain{
    NSLog(@"退出登录，重新登录");
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@""  forKey:@"LockPass"];
    [userDefaults synchronize];
    
    //发通知，需要重新登录
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockPassReload" object:nil];
}

#pragma mark 检查第1遍密码输入后
-(void)check1PassAfterSet{
    
    //第一遍密码输入之后提示
    if(self.passType == LockPassTypeSet){
        [self.tipLabel setText:@"请再次输入密码"];
    }else if (self.passType == LockPassTypeReset){
        if (self.reSetAgain) {
            //验证旧密码后，从新输入密码
            [self.tipLabel setText:@"请再次输入新密码"];
        }else{
            //验证旧密码
            //和原始密码对比
            if ([self.originalPass isEqualToString:self.passStr1]) {
                //一样
                self.passStr1 =@"";
                self.tapCount =0;
                self.reSetAgain =YES;
                [self.tipLabel setText:@"请输入新密码"];
                
            }else{
                //不一样
                self.passStr1 =@"";
                self.tapCount =0;
                self.chanceNum -=1;
                if (self.chanceNum >0) {
                    [self.tipLabel setText:[NSString stringWithFormat:@"密码不正确，还可以尝试%ld次",(long)self.chanceNum]];
                    [self showErrorAnimation];
                }else{
                    //重置密码密码机会用完了，重新登录
                    [self loadAccountAgain];
                }
            }
        }
        
    }else if (self.passType == LockPassTypeClose){
        
        if ([self.originalPass isEqualToString:self.passStr1]) {
            //一样 关闭密码设置
            NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@""  forKey:@"LockPass"];
            [userDefaults synchronize];
            if([self.delegate respondsToSelector:@selector(closeViewWithSetSussessOrCloseBtnClickIsSet:)]){
                [self.delegate closeViewWithSetSussessOrCloseBtnClickIsSet:NO];
            }
            
        }else{
            //不一样
            self.passStr1 =@"";
            self.tapCount =0;
            self.chanceNum -=1;
            if (self.chanceNum >0) {
                [self.tipLabel setText:[NSString stringWithFormat:@"密码不正确，还可以尝试%ld次",(long)self.chanceNum]];
                [self showErrorAnimation];
            }else{
                //重置密码密码机会用完了，重新登录
                [self loadAccountAgain];
            }
        }
        
    }else if(self.passType == LockPassTypeInForegroud){
        
        if ([self.originalPass isEqualToString:self.passStr1]) {
            //一样 进入app
            if([self.delegate respondsToSelector:@selector(closeViewWithSetSussessOrCloseBtnClickIsSet:)]){
                [self.delegate closeViewWithSetSussessOrCloseBtnClickIsSet:NO];
            }
            
        }else{
            //不一样
            self.passStr1 =@"";
            self.tapCount =0;
            self.chanceNum -=1;
            if (self.chanceNum >0) {
                [self.tipLabel setText:[NSString stringWithFormat:@"密码不正确，还可以尝试%ld次",(long)self.chanceNum]];
                [self showErrorAnimation];
            }else{
                //重置密码密码机会用完了，重新登录
                [self loadAccountAgain];
            }
        }
    }
    
    self.userInteractionEnabled =NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bluePoint1.hidden =YES;
        self.bluePoint2.hidden =YES;
        self.bluePoint3.hidden =YES;
        self.bluePoint4.hidden =YES;
        self.userInteractionEnabled =YES;
    });
}

#pragma mark 检查第二遍密码输入后
-(void)check2PassIsSame{
    
    //密码输入一样//保存到偏好
    if (![self.passStr2 isEqualToString:self.passStr1]) {
        //密码输入不一样
        [self.tipLabel setText:@"与上次输入不一致，请再输入一次"];
        self.passStr2 =@"";
        
        self.bluePoint1.hidden =YES;
        self.bluePoint2.hidden =YES;
        self.bluePoint3.hidden =YES;
        self.bluePoint4.hidden =YES;
        
        self.tapCount =4;
        //错误动画
        [self showErrorAnimation];
        
    }else{
        //密码输入一样//保存到偏好
        [self pass1SameToPass2];
    }
}

-(void)pass1SameToPass2{
    
    //密码输入一样//保存到偏好
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.passStr1  forKey:@"LockPass"];
    [userDefaults synchronize];
    
    //关闭界面
    if ([self.delegate respondsToSelector:@selector(closeViewWithSetSussessOrCloseBtnClickIsSet:)]) {
        [self.delegate closeViewWithSetSussessOrCloseBtnClickIsSet:YES];
    }else{
        //后台进入前台，添加在window上
        [self removeFromSuperview];
    }
}

-(void)showErrorAnimation{
    
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.fromValue = [NSNumber numberWithFloat:-5];
    shake.toValue   = [NSNumber numberWithFloat:5];
    shake.duration = 0.05;//执行时间
    shake.autoreverses = YES; //是否重复
    shake.repeatCount = 2;//次数
    [self.tipLabel.layer addAnimation:shake forKey:@"shakeAnimation1"];
    [self.pointBackView.layer addAnimation:shake forKey:@"shakeAnimation2"];
}

@end
