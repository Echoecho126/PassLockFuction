//
//  SafeLockNumVC.h
//  PassLok
//
//  Created by Echo_RSQ on 2017/12/27.
//  Copyright © 2017年 Echo_RSQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PassLockView.h"

@protocol SafeLockNumVCDelegate<NSObject>
@optional

-(void)closeVCWhenSuccessSetPass:(BOOL)successSetPass;

@end

@interface SafeLockNumVC : UIViewController

@property(nonatomic,weak) id<SafeLockNumVCDelegate> delegate;

@property (nonatomic,assign)LockPassType passType;

@end
