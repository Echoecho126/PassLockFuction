//
//  PassLockView.h
//  PassLok
//
//  Created by Echo_RSQ on 2017/12/27.
//  Copyright © 2017年 Echo_RSQ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LockPassTypeSet,//设置密码
    LockPassTypeReset,//更改密码
    LockPassTypeClose,//关闭密码
    LockPassTypeInForegroud,//进入前台
} LockPassType;

@protocol PassLockViewDelegate<NSObject>
@optional

-(void)closeViewWithSetSussessOrCloseBtnClickIsSet:(BOOL)successSetPass;//关闭界面

@end

@interface PassLockView : UIView

-(instancetype)initWithFrame:(CGRect)frame lockPassType:(LockPassType)passType;

@property (nonatomic,weak) id<PassLockViewDelegate>delegate;

@end
