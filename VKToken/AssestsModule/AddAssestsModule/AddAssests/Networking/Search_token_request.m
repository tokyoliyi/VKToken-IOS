//
//  Search_token_request.m
//  VKToken
//
//  Created by vankiachain on 2018/7/18.
//  Copyright © 2018 vankiachain. All rights reserved.
//

#import "Search_token_request.h"

@implementation Search_token_request
-(NSString *)requestUrlPath{
    return [NSString stringWithFormat:@"%@/search_token?key=%@&accountName=%@", REQUEST_PERSONAL_BASEURL, self.key, self.accountName];
}
@end
