//
//  InvitationCodeHeaderView.m
//  VKToken
//
//  Created by Lee on 2019/7/9.
//  Copyright © 2019 vankiachain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InvitationCodeHeaderView.h"

@implementation InvitationCodeHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
    //     self.tipLabel.font = [UIFont boldSystemFontOfSize:24];
    //    self.generateQRCodeBtn.lee_theme
    //    .LeeAddBackgroundColor(SOCIAL_MODE, HEXCOLOR(0xCCCCCC))
    //    .LeeAddBackgroundColor(BLACKBOX_MODE, HEXCOLOR(0xA3A3A3));
    
    self.mainView.frame = CGRectMake(0,0,375,667);
    self.mainView.alpha = 1.0;
    
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,375,667);
    gl.startPoint = CGPointMake(0.5, 1);
    gl.endPoint = CGPointMake(0.5, 0);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:180/255.0 green:253/255.0 blue:255/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:91/255.0 green:210/255.0 blue:214/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:1/255.0 green:167/255.0 blue:173/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0),@(0.6f),@(1.0f)];
    [self.mainView.layer addSublayer:gl];
    
    self.qrView.frame = CGRectMake(15,94,345,449.5);
    self.qrView.alpha = 1.0;
    self.qrView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    self.qrView.layer.cornerRadius = 16;
    
    [self.mainView addSubview:self.qrView];
    
    
}
@end