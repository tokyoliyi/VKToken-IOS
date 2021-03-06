//
//  SystemSettingViewController.m
//  VKToken
//
//  Created by vankiachain on 2018/1/17.
//  Copyright © 2018年 vankiachain. All rights reserved.
//

#import "SystemSettingViewController.h"
#import "NavigationView.h"
#import "BaseTabBarController.h"
#import "AppDelegate.h"
#import "RtfBrowserViewController.h"
#import "PasswordView.h"
#import "NJOPasswordStrengthEvaluator.h"
#import "FeedbackViewController.h"
#import "LanguageSettingViewController.h"
#import "AboutUsViewController.h"
#import "ShareToFrirndsViewController.h"
#import "Macro.h"
#import "AuthID.h"
#import "AuthPasswordViewController.h"
#import "CurrencySettingViewController.h"
#import "ChangePasswordView.h"
#import "VKToken-swift.h"

@import LocalAuthentication;

@interface SystemSettingViewController ()< UIGestureRecognizerDelegate, NavigationViewDelegate, UITableViewDelegate , UITableViewDataSource, ChangePasswordViewDelegate>
@property(nonatomic, strong) NavigationView *navView;
@property(nonatomic , strong) NSDictionary *dataSourceDictionary;
@property (nonatomic, strong) UISwitch *fingerprintLoginSwitch;
@property (nonatomic, strong) NSString *authString;
@property(nonatomic, strong) ChangePasswordView *changePasswordView;
@end

@implementation SystemSettingViewController

- (NavigationView *)navView{
    if (!_navView) {
        _navView = [NavigationView navigationViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT) LeftBtnImgName:@"icon_back" title:NSLocalizedString(@"系统设置", nil)rightBtnImgName:@"" delegate:self];
        _navView.leftBtn.lee_theme.LeeAddButtonImage(SOCIAL_MODE, [UIImage imageNamed:@"icon_back"], UIControlStateNormal).LeeAddButtonImage(BLACKBOX_MODE, [UIImage imageNamed:@"icon_back"], UIControlStateNormal);
    }
    return _navView;
}

- (ChangePasswordView *)changePasswordView{
    if (!_changePasswordView) {
        _changePasswordView = [[[NSBundle mainBundle] loadNibNamed:@"ChangePasswordView" owner:nil options:nil] firstObject];
        _changePasswordView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _changePasswordView.delegate = self;
    }
    return _changePasswordView;
}

- (NSDictionary *)dataSourceDictionary{
    if (!_dataSourceDictionary) {
        NSString *authType = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthTypeKey];
        if (authType) {
            if ([authType isEqualToString:kAuthTypePassword]) {
                _authString = NSLocalizedString(@"login_pwd", nil);
            } else if ([authType isEqualToString:kAuthTypeFaceId]) {
                _authString = NSLocalizedString(@"login_faceid", nil);
            } else if ([authType isEqualToString:kAuthTypeTouchId]) {
                _authString = NSLocalizedString(@"login_touchid", nil);
            }
        } else {
            switch ([AuthID sharedInstance].supportBiometricType) {
                case AuthSupportTypeNone:
                    _authString = NSLocalizedString(@"login_pwd", nil);
                    break;
                case AuthSupportTypeTouchID:
                    _authString = NSLocalizedString(@"login_touchid", nil);
                    break;
                case AuthSupportTypeFaceID:
                    _authString = NSLocalizedString(@"login_faceid", nil);
                    break;
                default:
                    _authString = NSLocalizedString(@"login_pwd", nil);
                    break;
            }
        }
        
        BOOL isSwitchOn = ([[NSUserDefaults standardUserDefaults] objectForKey:kAuthSwithOnStatusKey] != nil);
        
    
        if (LEETHEME_CURRENTTHEME_IS_SOCAIL_MODE) {
            _dataSourceDictionary = @{
                                      @"firstSection" : @[NSLocalizedString(@"清空缓存", nil), NSLocalizedString(@"语言", nil),
                                                        @{@"title":NSLocalizedString(_authString, nil),@"switch":@(isSwitchOn)},NSLocalizedString(@"意见反馈", nil)]  ,
                                      @"secondSection" : @[ NSLocalizedString(@"法律条款与隐私政策", nil), NSLocalizedString(@"关于我们", nil)],
                                      @"thirdSection": @[NSLocalizedString(@"分享给好友", nil)]
                                      };//NSLocalizedString(@"语言", nil),
        }else if(LEETHEME_CURRENTTHEME_IS_BLACKBOX_MODE){
            _dataSourceDictionary = @{
                                      @"firstSection" : @[NSLocalizedString(@"清空缓存", nil), NSLocalizedString(@"语言", nil),NSLocalizedString(@"货币单位", nil),NSLocalizedString(@"修改密码", nil), @{@"title":NSLocalizedString(_authString, nil),@"switch":@(isSwitchOn)}]
//                                      ,
//                                      @"secondSection" : @[ NSLocalizedString(@"法律条款与隐私政策", nil), NSLocalizedString(@"关于我们", nil)]
                                      };//NSLocalizedString(@"语言", nil),
        }
    }
    return _dataSourceDictionary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.navView];
    self.mainTableView.mj_header.hidden = YES;
    self.mainTableView.mj_footer.hidden = YES;
    [self.view addSubview:self.mainTableView];
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mainTableView.lee_theme
    .LeeConfigBackgroundColor(@"baseHeaderView_background_color");
    [self.mainTableView reloadData];
    [self.changePasswordView.inputNewPasswordTF addTarget:self action:@selector(textFiledDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.changePasswordView.confirmPasswordTF addTarget:self action:@selector(textFiledDidChanged:) forControlEvents:UIControlEventEditingChanged];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BaseTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:CELL_REUSEIDENTIFIER];
    if (!cell) {
        cell = [[BaseTableViewCell1 alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:CELL_REUSEIDENTIFIER];
    }
    
    cell.rightIconImgName = @"right_arrow_gray";
    [cell.contentView addSubview:cell.rightIconImageView];
    cell.rightIconImageView.sd_layout.rightSpaceToView(cell.contentView, 20).widthIs(7).heightIs(14).centerYEqualToView(cell.contentView);
    cell.rightIconImageView.hidden = NO;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.bottomLineView.hidden = NO;
    
    if (indexPath.section == 0) {
        NSArray *topArr = [self.dataSourceDictionary objectForKey:@"firstSection"];
        if (indexPath.row == (topArr.count-1)) {
            NSDictionary *dict = [self.dataSourceDictionary objectForKey:@"firstSection"][indexPath.row];
            if (dict) {
                cell.textLabel.text = [dict objectForKey:@"title"];
                NSNumber *switchValue = dict[@"switch"];
                if (switchValue == nil) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    UISwitch *fingerprintLoginSwitch = [[UISwitch alloc] init];
                    [fingerprintLoginSwitch addTarget:self action:@selector(valueChnage:) forControlEvents:UIControlEventTouchUpInside];
                    fingerprintLoginSwitch.on = [switchValue boolValue];
                    cell.accessoryView = fingerprintLoginSwitch;
                    _fingerprintLoginSwitch = fingerprintLoginSwitch;
                }
                
            }
            cell.rightIconImageView.hidden = YES;
            cell.bottomLineView.hidden = YES;
        }else {
            cell.textLabel.text = topArr[indexPath.row];
            if([cell.textLabel.text isEqualToString:NSLocalizedString(@"清空缓存", nil)]){
                NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)[0];
                cell.detailTextLabel.text = [cachePath fileSize];
                cell.detailTextLabel.textColor = RGB(240, 143, 67);
                cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
                cell.rightIconImageView.hidden = YES;
            }
        }
    }else if (indexPath.section == 1){
        NSArray *bottomArr = [self.dataSourceDictionary objectForKey:@"secondSection"];
        cell.textLabel.text = bottomArr[indexPath.row];
        if (indexPath.row == (bottomArr.count-1)) {
            cell.bottomLineView.hidden = YES;
        }
    }else if (indexPath.section == 2){
        NSArray *bottomArr = [self.dataSourceDictionary objectForKey:@"thirdSection"];
        cell.textLabel.text = bottomArr[indexPath.row];
        if (indexPath.row == (bottomArr.count-1)) {
            cell.bottomLineView.hidden = YES;
        }
    }
    return cell;
}

- (void)valueChnage:(UISwitch *)switchView {
    AuthPasswordViewController *vc = [[AuthPasswordViewController alloc] initWithNibName:@"AuthPasswordViewController" bundle:nil];
    
    if (switchView.on) {
        vc.pwdType = kPasswordTypeSet;
        vc.title = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"set", nil),self.authString];
    } else {
        vc.pwdType = kPasswordTypeCancel;
        vc.title = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"cancel", nil),self.authString];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        NSArray *firstArr = [self.dataSourceDictionary objectForKey:@"firstSection"];
        return firstArr.count;
    }else if (section ==  1){
        NSArray *secondArr = [self.dataSourceDictionary objectForKey:@"secondSection"];
        return secondArr.count;
    }else if (section ==  2){
        NSArray *thirdArr = [self.dataSourceDictionary objectForKey:@"thirdSection"];
        return thirdArr.count;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceDictionary.allKeys.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.lee_theme
    .LeeConfigBackgroundColor(@"baseHeaderView_background_color");
    headerLabel.font = [UIFont systemFontOfSize:11];
    return headerLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return MARGIN_10;
    }else if (section == 1){
        return MARGIN_20;
    }else if (section == 2){
        return MARGIN_20;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BaseTableViewCell1 *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"语言", nil)]) {
        LanguageSettingViewController *vc = [[LanguageSettingViewController alloc] init];
        vc.languageSettingViewControllerFromMode = LanguageSettingViewControllerFromOtherPage;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([cell.textLabel.text isEqualToString:NSLocalizedString(@"货币单位", nil)]){
        CurrencySettingViewController *vc = [[CurrencySettingViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([cell.textLabel.text isEqualToString:NSLocalizedString(@"清空缓存", nil)]){
        // clear cache
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)[0];
        NSFileManager *mgr = [NSFileManager defaultManager];
        if ([mgr fileExistsAtPath:cachePath]) {
            // 删除子文件夹
            [self removeCache];
//            BOOL isRemoveSuccessed = [mgr removeItemAtPath:cachePath error:nil];
//            if (isRemoveSuccessed) { // 删除成功
                [TOASTVIEW showWithText:NSLocalizedString(@"清理成功~", nil)];
//            }
        }
        [tableView reloadData];
        
    }else if([cell.textLabel.text isEqualToString:NSLocalizedString(@"意见反馈", nil)]){
        FeedbackViewController *vc = [[FeedbackViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if([cell.textLabel.text isEqualToString:NSLocalizedString(@"法律条款与隐私政策", nil)]){
        RtfBrowserViewController *vc = [[RtfBrowserViewController alloc] init];
        vc.rtfFileName = @"VKTokenPrivacyPolicy";
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if([cell.textLabel.text isEqualToString:NSLocalizedString(@"关于我们", nil)]){
        AboutUsViewController *vc = [[AboutUsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if([cell.textLabel.text isEqualToString:NSLocalizedString(@"分享给好友", nil)]){
        ShareToFrirndsViewController *vc = [[ShareToFrirndsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];

        
    }else if([cell.textLabel.text isEqualToString:NSLocalizedString(@"修改密码", nil)]){

        [self.view addSubview:self.changePasswordView];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}
-(void)leftBtnDidClick{
    [self.navigationController popViewControllerAnimated:YES];
}

//ChangePasswordViewDelegate
- (void)cancleBtnDidClick:(UIButton *)sender{
    [self remove_change_passwordView];
}

- (void)textFiledDidChanged:(UITextField *)textfield {
    if ([self.changePasswordView.inputNewPasswordTF isEqual:textfield] ||
        [self.changePasswordView.confirmPasswordTF isEqual:textfield]) {
        [self showPasswordTipLabelWithField:textfield];
    }
}

- (void)showPasswordTipLabelWithField:(UITextField *)textField {
    [self.changePasswordView.pwdStrengthLabel setTextColor:[UIColor redColor]];
    if (textField.text.length == 0) {
        self.changePasswordView.pwdStrengthLabel.text = NSLocalizedString(@"pwd_length_tip", nil);
    } else {
        if ([self judgePasswordStrength:textField.text] == eWeakPassword) {
            self.changePasswordView.pwdStrengthLabel.text = NSLocalizedString(@"pwd_length_weak", nil);
        } else {
            self.changePasswordView.pwdStrengthLabel.text = @"";
        }
    }
}

- (void)confirmPasswordBtnDidClick:(UIButton *)sender{
    // 校验输入
    if (IsStrEmpty(self.changePasswordView.oraginalPasswordTF.text) || IsStrEmpty(self.changePasswordView.confirmPasswordTF.text) || IsStrEmpty(self.changePasswordView.inputNewPasswordTF.text)) {
        [TOASTVIEW showWithText:NSLocalizedString(@"输入不能为空!", nil)];
        return;
    }
    
    if (![self.changePasswordView.inputNewPasswordTF.text isEqualToString:self.changePasswordView.confirmPasswordTF.text]) {
        [TOASTVIEW showWithText:NSLocalizedString(@"两次输入的密码不一致!", nil)];
        return;
    }
    
    if ([self judgePasswordStrength:self.changePasswordView.inputNewPasswordTF.text] == eWeakPassword) {
        self.changePasswordView.pwdStrengthLabel.text = NSLocalizedString(@"pwd_length_weak", nil);
        return;
    } else {
        self.changePasswordView.pwdStrengthLabel.text = @"";
    }
    
    [SVProgressHUD show];
    Wallet *current_wallet = CURRENT_WALLET;
    if (![WalletUtil validateWalletPasswordWithSha256:current_wallet.wallet_shapwd password:self.changePasswordView.oraginalPasswordTF.text]) {
        [TOASTVIEW showWithText:NSLocalizedString(@"原始密码输入有误!", nil)];
        [SVProgressHUD dismiss];
        [self remove_change_passwordView];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 开始修改密码
        [self changeWalletPassword];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self remove_change_passwordView];
        });
    });
}

- (void)changeWalletPassword{
    NSArray *allLocalAccount = [[AccountsTableManager accountTable] selectAccountTable];
    Wallet *wallet = CURRENT_WALLET;
    TokenCoreVKT *tokenCoreVKT = [TokenCoreVKT sharedTokenCoreVKT];
    for (AccountInfo *model in allLocalAccount) {
        [tokenCoreVKT changeVktPassword: model.account_vktoken_wallet_id: self.changePasswordView.oraginalPasswordTF.text:self.changePasswordView.confirmPasswordTF.text];
        NSString *decrypt_active_private_key = [AESCrypt decrypt:model.account_active_private_key password:self.changePasswordView.oraginalPasswordTF.text];
        NSString *decrypt_owner_private_key = [AESCrypt decrypt:model.account_owner_private_key password:self.changePasswordView.oraginalPasswordTF.text];
        
        NSString *encrypt_active_private_key = [AESCrypt encrypt:decrypt_active_private_key password:self.changePasswordView.confirmPasswordTF.text];
        NSString *encrypt_owner_private_key = [AESCrypt encrypt:decrypt_owner_private_key password:self.changePasswordView.confirmPasswordTF.text];
        
        // update table
        BOOL result = [[AccountsTableManager accountTable] executeUpdate:[NSString stringWithFormat: @"UPDATE '%@' SET account_active_private_key = '%@', account_owner_private_key = '%@'  WHERE account_name = '%@'", wallet.account_info_table_name, encrypt_active_private_key, encrypt_owner_private_key , model.account_name]];
        if (result) {
            NSLog(@"changeWalletPassword Success");
        }
    }
    
    // 验证通过, 修改密码
    BOOL result = [[WalletTableManager walletTable] executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET wallet_shapwd = '%@' WHERE wallet_uid = '%@'",  WALLET_TABLE, [WalletUtil generate_wallet_shapwd_withPassword:self.changePasswordView.confirmPasswordTF.text], CURRENT_WALLET_UID]];
    if (result) {
        [TOASTVIEW showWithText:NSLocalizedString(@"修改密码成功!", nil)];
    }
}

- (void)remove_change_passwordView{
    [self.changePasswordView removeFromSuperview];
//    self.changePasswordView = nil;
    self.changePasswordView.inputNewPasswordTF.text = @"";
    self.changePasswordView.confirmPasswordTF.text = @"";
    self.changePasswordView.oraginalPasswordTF.text = @"";
}

-(void)removeCache
{
    //===============清除缓存==============
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];

    // NSLog(@"文件数 ：%lu",(unsigned long)[files count]);
    for (NSString *p in files)
    {
        NSError *error;
        NSString *path = [cachePath stringByAppendingPathComponent:p];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path] && [[NSFileManager defaultManager] isDeletableFileAtPath:path])
        {
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
                NSLog(@"Error trying to delete %@: %@", path, error);
            }
        } else {
            NSLog(@"Can't delete %@", path);
        }
    }
}

#pragma mark - TODO
- (PasswordEnum)judgePasswordStrength:(NSString*)password {
    
    if (password.length == 0) {
        return eEmptyPassword;
    }
    
    NJOPasswordStrength strength = [NJOPasswordStrengthEvaluator strengthOfPassword:password];
    
    PasswordEnum pwdStrong = eWeakPassword;
    switch (strength) {
        case NJOVeryWeakPasswordStrength:
        case NJOWeakPasswordStrength:
            pwdStrong = eWeakPassword;
            break;
        case NJOReasonablePasswordStrength:
            pwdStrong = eSosoPassword;
            break;
        case NJOStrongPasswordStrength:
            pwdStrong = eGoodPassword;
            break;
        case NJOVeryStrongPasswordStrength:
            pwdStrong = eSafePassword;
            break;
        default:
            break;
    }
    
    return pwdStrong;
}

@end
