//
//  RegisterAccountToVoteSystem_Abi_json_to_bin_request.m
//  VKToken
//
//  Created by vankiachain on 2018/6/11.
//  Copyright © 2018 vankiachain. All rights reserved.
//

#import "RegisterAccountToVoteSystem_Abi_json_to_bin_request.h"

@implementation RegisterAccountToVoteSystem_Abi_json_to_bin_request
-(NSString *)requestUrlPath{
    return @"/abi_json_to_bin";
}

-(NSDictionary *)parameters{
    // 交易JSON序列化
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject: VALIDATE_STRING(self.code) forKey:@"code"];
    [params setObject:VALIDATE_STRING(self.action) forKey:@"action"];
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    [args setObject:VALIDATE_STRING(self.proxy) forKey:@"proxy"];
    [args setObject:VALIDATE_STRING(self.isproxy) forKey:@"isproxy"];
    [params setObject:args forKey:@"args"];
    return params;
}
@end
