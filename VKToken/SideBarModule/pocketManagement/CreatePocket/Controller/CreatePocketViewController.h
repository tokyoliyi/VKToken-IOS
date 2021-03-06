//
//  CreatePocketViewController.h
//  VKToken
//
//  Created by vankiachain on 2018/1/4.
//  Copyright © 2018年 vankiachain. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 从那个模式下跳转过来
 */
typedef NS_ENUM(NSInteger, CreatePocketViewControllerFromMode) {
    CreatePocketViewControllerFromSocialMode,
    CreatePocketViewControllerFromBlackBoxMode
};

@interface CreatePocketViewController : BaseViewController
@property(nonatomic, assign) CreatePocketViewControllerFromMode createPocketViewControllerFromMode;

@end
