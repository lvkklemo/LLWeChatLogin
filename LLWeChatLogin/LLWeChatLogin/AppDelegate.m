//
//  AppDelegate.m
//  LLWeChatLogin
//
//  Created by 宇航 on 17/5/19.
//  Copyright © 2017年 HWD. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"
#import "AFNetworking.h"

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate

// 移动应用微信登录是基于OAuth2.0协议标准构建的微信OAuth2.0授权登录系统。

//1. 第三方发起微信授权登录请求，微信用户允许授权第三方应用后，微信会拉起应用或重定向到第三方网站，并且带上授权临时票据code参数；
//2. 通过code参数加上AppID和AppSecret等，通过API换取access_token；
//3. 通过access_token进行接口调用，获取用户基本数据资源或帮助用户实现基本操作。

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [WXApi registerApp:@"wx49c0ae1393d41bbd" withDescription:@"wxlogin"];
    
    return YES;
}

// 这个方法是用于从微信返回第三方App
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}

// 授权后回调
//授权后回调
/*
 http请求方式:GET
 // 根据响应结果中的code获取access_token(要用到申请时得到的AppID和AppSecret)
 https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
 正确返回
 {
 "access_token":"ACCESS_TOKEN",
 "expires_in":7200,
 "refresh_token":"REFRESH_TOKEN",
 "openid":"OPENID",
 "scope":"SCOPE",
 "unionid":"o6_bmasdasdsad6_2sgVt7hMZOPfL"
 }*/

- (void)onResp:(BaseResp *)resp {
    
    // 向微信请求授权后,得到响应结果
    if ([resp isKindOfClass:[SendAuthResp class]]) {
       
        SendAuthResp *temp = (SendAuthResp *)resp;
        NSString *accessUrlStr = [NSString stringWithFormat:@"%@/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WX_BASE_URL, WX_App_ID, WX_App_Secret, temp.code];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"applicatiob/json", nil];
        //2.设定类型. (这里要设置request-response的类型)
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:accessUrlStr parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            NSLog(@"请求access的responseObject = %@", responseObject);

            NSDictionary *accessDict = [NSDictionary dictionaryWithDictionary:responseObject];
            NSString *accessToken = [accessDict objectForKey:WX_ACCESS_TOKEN];
            NSString *openID = [accessDict objectForKey:WX_OPEN_ID];
            NSString *refreshToken = [accessDict objectForKey:WX_REFRESH_TOKEN];
            // 本地持久化，以便access_token的使用、刷新或者持续
            if (accessToken && ![accessToken isEqualToString:@""] && openID && ![openID isEqualToString:@""]) {
                [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:WX_ACCESS_TOKEN];
                [[NSUserDefaults standardUserDefaults] setObject:openID forKey:WX_OPEN_ID];
                [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:WX_REFRESH_TOKEN];
                // 命令直接同步到文件里，来避免数据的丢失
                [[NSUserDefaults standardUserDefaults] synchronize];             }
            [self wechatLoginByRequestForUserInfo];
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            
            NSLog(@"获取access_token时出错 = %@", error);
            
        }];
   }
}

// 获取用户个人信息（UnionID机制）
- (void)wechatLoginByRequestForUserInfo {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:WX_ACCESS_TOKEN];
    NSString *openID = [[NSUserDefaults standardUserDefaults] objectForKey:WX_OPEN_ID];
    NSString *userUrlStr = [NSString stringWithFormat:@"%@/userinfo?access_token=%@&openid=%@", WX_BASE_URL, accessToken, openID];
    // 请求用户数据
    [manager GET:userUrlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求用户信息的response = %@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取用户信息时出错 = %@", error);
    }];
}
/*
返回的Json结果
{
    "openid":"OPENID",
    "nickname":"NICKNAME",
    "sex":1,
    "province":"PROVINCE",
    "city":"CITY",
    "country":"COUNTRY",
    "headimgurl": "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
    "privilege":[
                 "PRIVILEGE1",
                 "PRIVILEGE2"
                 ],
    "unionid": " o6_bmasdasdsad6_2sgVt7hMZOPfL"
}
返回错误的Json事例
{
    "errcode":40003,"errmsg":"invalid openid"
}*/
/*
做到上面一步就应该得到返回微信的基本信息，然后根据公司后台的基本需求去实现授权后如何登录App.
1.首先获取到微信的openID，然后通过openID去后台数据库查询该微信的openID有没有绑定好的手机号.
2.如果没有绑定,首相第一步就是将微信用户的头像、昵称等等基本信息添加到数据库；然后通过手机获取验证码;最后绑定手机号。然后就登录App.
3.如果有，那么后台就返回一个手机号，然后通过手机登录App.
 */
@end
