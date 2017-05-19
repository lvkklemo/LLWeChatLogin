//
//  AppDelegate.h
//  LLWeChatLogin
//
//  Created by 宇航 on 17/5/19.
//  Copyright © 2017年 HWD. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WX_BASE_URL @"https://api.weixin.qq.com/sns"
#define WX_App_ID @"wx49c0ae1393d41bbd"  // 注册微信时的AppID
#define WX_App_Secret @"d0dd6b58da42cbc4f4b715c70e65c***" // 注册时得到的AppSecret
#define WX_ACCESS_TOKEN @"access_token"
#define WX_OPEN_ID @"openid"
#define WX_REFRESH_TOKEN @"refresh_token"
#define WX_UNION_ID @"unionid"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

