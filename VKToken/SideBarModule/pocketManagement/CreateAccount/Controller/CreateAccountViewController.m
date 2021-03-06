//
//  CreateAccountViewController.m
//  VKToken
//
//  Created by vankiachain on 2017/12/12.
//  Copyright © 2017年 vankiachain. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "CreateAccountHeaderView.h"
#import "NavigationView.h"
#import "AccountsTableManager.h"
#import "AccountInfo.h"
#import "AppDelegate.h"
#import "BaseTabBarController.h"
#import "CreateAccountService.h"
#import "CreateAccountRequest.h"
//#import "VktPrivateKey.h"
#import "ImportAccountViewController.h"
#import "VKTMappingImportAccountViewController.h"
#import "RtfBrowserViewController.h"
#import "BackupAccountViewController.h"
#import "GetAccountRequest.h"
#import "GetAccount.h"
#import "GetAccountResult.h"
#import "CreateMemonicViewController.h"
#import "Validata_Invitecode_Request.h"
#import "VKToken-swift.h"


@interface CreateAccountViewController ()<UIGestureRecognizerDelegate,  NavigationViewDelegate, CreateAccountHeaderViewDelegate, LoginPasswordViewDelegate>
@property(nonatomic, strong) CreateAccountHeaderView *headerView;
@property(nonatomic, strong) NavigationView *navView;
@property(nonatomic, strong) CreateAccountService *createAccountService;
@property(nonatomic, strong) LoginPasswordView *loginPasswordView;
@property(nonatomic, strong) GetAccountRequest *getAccountRequest;
@property(nonatomic, strong) Validata_Invitecode_Request *validata_Invitecode_Request;
@property(nonatomic, strong) NSString *imported_wallet_id;
@end

@implementation CreateAccountViewController

- (CreateAccountService *)createAccountService{
    if (!_createAccountService) {
        _createAccountService = [[CreateAccountService alloc] init];
    }
    return _createAccountService;
}

- (NavigationView *)navView{
    if (!_navView) {
        _navView = [NavigationView navigationViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAVIGATIONBAR_HEIGHT) LeftBtnImgName:@"icon_back" title:NSLocalizedString(@"创建新账号", nil)rightBtnImgName:@"" delegate:self];
        _navView.leftBtn.lee_theme.LeeAddButtonImage(SOCIAL_MODE, [UIImage imageNamed:@"icon_back"], UIControlStateNormal).LeeAddButtonImage(BLACKBOX_MODE, [UIImage imageNamed:@"icon_back"], UIControlStateNormal);
    }
    return _navView;
}
- (CreateAccountHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[[NSBundle mainBundle] loadNibNamed:@"CreateAccountHeaderView" owner:nil options:nil] firstObject];
        _headerView.frame = CGRectMake(0, NAVIGATIONBAR_HEIGHT, SCREEN_WIDTH, 550);
        _headerView.delegate = self;
    }
    return _headerView;
}

- (LoginPasswordView *)loginPasswordView{
    if (!_loginPasswordView) {
        _loginPasswordView = [[[NSBundle mainBundle] loadNibNamed:@"LoginPasswordView" owner:nil options:nil] firstObject];
        _loginPasswordView.frame = self.view.bounds;
        _loginPasswordView.delegate = self;
    }
    return _loginPasswordView;
}

- (GetAccountRequest *)getAccountRequest{
    if (!_getAccountRequest) {
        _getAccountRequest = [[GetAccountRequest alloc] init];
    }
    return _getAccountRequest;
}

- (Validata_Invitecode_Request *)validata_Invitecode_Request{
    if (!_validata_Invitecode_Request) {
        _validata_Invitecode_Request = [[Validata_Invitecode_Request alloc] init];
    }
    return _validata_Invitecode_Request;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.headerView];
//    self.headerView.accountNameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入用户名,5~12位字符,字母a~z和数字1~5组成", nil) attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 14], NSForegroundColorAttributeName: [UIColor whiteColor]}];
//    [self configImportAccountBtn];
}

//CreateAccountHeaderViewDelegate
- (void)agreeTermBtnDidClick:(UIButton *)sender {
}
- (void)privacyPolicyBtnDidClick:(UIButton *)sender{
    RtfBrowserViewController *vc = [[RtfBrowserViewController alloc] init];
    vc.rtfFileName = @"VKTokenPrivacyPolicy";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)createAccountBtnDidClick:(UIButton *)sender {
    
    if (self.headerView.agreeItemBtn.isSelected) {
        [TOASTVIEW showWithText:NSLocalizedString(@"请勾选同意条款!", nil)];
        return;
    }
    if (![ RegularExpression validateVktAccountName:self.headerView.accountNameTF.text ]) {
        [TOASTVIEW showWithText:NSLocalizedString(@"账号名,5~12位字符,只能由小写a~z和1~5组成!", nil)];
        return;
    }
    if (![self checkPassword:self.headerView.passwordToSet.text]
               || ![self checkPassword : self.headerView.passwordToConfirm.text]) {
         [TOASTVIEW showWithText:NSLocalizedString(@"密码格式有误（至少8个字符，至少1个字母，1个数字）", nil)];
        return;
    }
    if (![self.headerView.passwordToSet.text isEqualToString:self.headerView.passwordToConfirm.text]) {
         [TOASTVIEW showWithText:NSLocalizedString(@"两次输入密码不一致!", nil)];
        return;
    }
    if (self.headerView.inviteCodeTF.text.length != 0 && self.headerView.inviteCodeTF.text.length != 5) {
         [TOASTVIEW showWithText:NSLocalizedString(@"请输入5位邀请码", nil)];
        return;
    }
    [self checkInviteCodeExist];
}

- (BOOL)checkPassword:(NSString *) password
{
    NSString *pattern = @"^(?=.*\\d)(?=.*[a-zA-Z]).{8,}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

- (void)checkInviteCodeExist{
    WS(weakSelf);
    self.validata_Invitecode_Request.InvitationCode = VALIDATE_STRING(self.headerView.inviteCodeTF.text) ;
    if (self.validata_Invitecode_Request.InvitationCode.length == 5) {
        [self.validata_Invitecode_Request postDataSuccess:^(id DAO, id data) {
             if ([data[@"code"] isEqualToNumber:@0] && [data[@"message"] isEqualToString:@"ok"]) {
                 [self checkAccountExist];
             }else{
                 [TOASTVIEW showWithText: NSLocalizedString(@"邀请码不存在，请重新输入", nil)];
                  NSLog(@"%s", "validata_Invitecode_Request doesn't exsit.");
             }
        } failure:^(id DAO, NSError *error) {
            NSLog(@"%@", error);
        }];
    }else{
        [self checkAccountExist];
    }
}

- (void)checkAccountExist{
    WS(weakSelf);
    self.getAccountRequest.name = VALIDATE_STRING(self.headerView.accountNameTF.text) ;
    [self.getAccountRequest postDataSuccess:^(id DAO, id data) {
        GetAccountResult *result = [GetAccountResult mj_objectWithKeyValues:data];
        if (![result.code isEqualToNumber:@0]) {
            [TOASTVIEW showWithText: result.message];
        }else{
            GetAccount *model = [GetAccount mj_objectWithKeyValues:result.data];
            if (model.account_name) {
                [TOASTVIEW showWithText: NSLocalizedString(@"账号已存在", nil)];
                return ;
            }else{
                [TOASTVIEW showWithText: NSLocalizedString(@"助记词正在生成中，请稍候...", nil)];
                TokenCoreVKT *tokenCoreVKT = [TokenCoreVKT sharedTokenCoreVKT];
                NSString *mnemonicStr = [tokenCoreVKT generateIdentity:nil:self.headerView.passwordToConfirm.text:nil];
                NSLog(NSLocalizedString(@"generateIdentity助记词:%@", nil), tokenCoreVKT.requestResult);
                
//                [tokenCoreVKT deriveEosWallet:self.headerView.passwordToConfirm.text];
                _imported_wallet_id = [tokenCoreVKT importVKTMnemonic:mnemonicStr : @"" :self.headerView.passwordToConfirm.text:nil];
                NSLog(NSLocalizedString(@"deriveEosWallet助记词:%@", nil), tokenCoreVKT.requestResult);
                
                //    [tokenCoreVKT importEthPrivateKey];
                //    NSLog(NSLocalizedString(@"importEthPrivateKey助记词:%@", nil), tokenCoreVKT.requestResult);
                if([[tokenCoreVKT hasVktWallet:nil]  compare:[NSNumber numberWithInt:0]] != NSOrderedSame) {
                    [self createkeys];
                }
            }
        }
    } failure:^(id DAO, NSError *error) {
        NSLog(@"%@", error);
    }];
}



// LoginPasswordViewDelegate
-(void)cancleBtnDidClick:(UIButton *)sender{
    [self.loginPasswordView removeFromSuperview];
}

-(void)confirmBtnDidClick:(UIButton *)sender{
    // 验证密码输入是否正确
    Wallet *current_wallet = CURRENT_WALLET;
    
    if (![WalletUtil validateWalletPasswordWithSha256:current_wallet.wallet_shapwd password:self.loginPasswordView.inputPasswordTF.text]) {
        [TOASTVIEW showWithText:NSLocalizedString(@"密码输入错误!", nil)];
        return;
    }
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 开始创建账号
        [self createkeys];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}

-(void)leftBtnDidClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)importAccount:(UIButton *)sender{
    ImportAccountViewController *vc = [[ImportAccountViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configImportAccountBtn{
    UIButton * button = [[UIButton alloc] init];
    [button setTitle:NSLocalizedString(@"如果已有账号，请点击这里导入", nil)forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button setTitleColor:HEX_RGB_Alpha(0xFFFFFF, 0.7) forState:(UIControlStateNormal)];
    button.lee_theme
    .LeeAddButtonTitleColor(SOCIAL_MODE, HEX_RGB_Alpha(0x4D7BFE, 1), UIControlStateNormal)
    .LeeAddButtonTitleColor(BLACKBOX_MODE, HEX_RGB_Alpha(0xFFFFFF, 0.7), UIControlStateNormal);
    [button addTarget:self action:@selector(importAccount:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    button.sd_layout.leftSpaceToView(self.view, MARGIN_20).rightSpaceToView(self.view, MARGIN_20).bottomSpaceToView(self.view, 23).heightIs(21);
}


/**
 生成注册vkt账号需要的所有 key
 account_active_private_key;
 account_active_public_key;
 account_owner_private_key;
 account_owner_public_key;
 */
- (void)createkeys{
    WS(weakSelf);
//    VktPrivateKey *ownerPrivateKey = [[VktPrivateKey alloc] initVktPrivateKey];
//    VktPrivateKey *activePrivateKey = [[VktPrivateKey alloc] initVktPrivateKey];
//    VktPrivateKey *activePrivateKey = ownerPrivateKey;
    
    TokenCoreVKT *tokenCoreVKT = [TokenCoreVKT sharedTokenCoreVKT];
    
    if (LEETHEME_CURRENTTHEME_IS_SOCAIL_MODE) {
        weakSelf.createAccountService.createVKTAccountRequest.uid = CURRENT_WALLET_UID;
    }else if (LEETHEME_CURRENTTHEME_IS_BLACKBOX_MODE){
        weakSelf.createAccountService.createVKTAccountRequest.uid = @"6f1a8e0eb24afb7ddc829f96f9f74e9d";
    }
    weakSelf.createAccountService.createVKTAccountRequest.vktAccountName = weakSelf.headerView.accountNameTF.text;
    weakSelf.createAccountService.createVKTAccountRequest.ownerKey = [tokenCoreVKT getVktPublicKey:_imported_wallet_id :weakSelf.headerView.passwordToConfirm.text:nil];
    weakSelf.createAccountService.createVKTAccountRequest.activeKey = [tokenCoreVKT getVktPublicKey:_imported_wallet_id :weakSelf.headerView.passwordToConfirm.text:nil];
    weakSelf.createAccountService.createVKTAccountRequest.inviteCode = weakSelf.headerView.inviteCodeTF.text;
    
//    NSLog(@"{ownerPrivateKey:%@\nvktPublicKey:%@\nactivePrivateKey:%@\nvktPublicKey:%@\n}", ownerPrivateKey.vktPrivateKey, ownerPrivateKey.vktPublicKey, activePrivateKey.vktPrivateKey, activePrivateKey.vktPublicKey);
    // 创建vkt账号
    
    [weakSelf.createAccountService createVKTAccount:^(id service, BOOL isSuccess) {
        
        if (isSuccess) {
            NSNumber *code = service[@"code"];
            if ([code isEqualToNumber:@0]) {
                // 创建账号成功
                [TOASTVIEW showWithText:NSLocalizedString(@"创建账号成功!", nil)];
                // TokenCoreVKT添加账户
                [tokenCoreVKT setVktAccountName:_imported_wallet_id: weakSelf.headerView.accountNameTF.text];

                // 如果本地没有钱包
                Wallet *model = [[Wallet alloc] init];
                //    model.wallet_name = self.createWalletView.walletNameTF.text;
                model.wallet_name = @"VKToken";
                
                model.wallet_shapwd = [WalletUtil generate_wallet_shapwd_withPassword:weakSelf.headerView.passwordToConfirm.text];
                model.wallet_uid = [model.wallet_name sha256];
                model.account_info_table_name = [NSString stringWithFormat:@"%@_%@", ACCOUNTS_TABLE,model.wallet_uid];
                [[WalletTableManager walletTable] addRecord: model];
                [[NSUserDefaults standardUserDefaults] setObject: model.wallet_uid  forKey:Current_wallet_uid];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // 创建账号(本地数据库)
                
                // 本地公钥和网络公钥匹配, 允许进行导入本地操作
                AccountInfo *accountInfo = [[AccountInfo alloc] init];
                accountInfo.account_name = weakSelf.headerView.accountNameTF.text;
                accountInfo.account_img = ACCOUNT_DEFALUT_AVATAR_IMG_URL_STR;
                accountInfo.account_active_public_key = [tokenCoreVKT getVktPublicKey:_imported_wallet_id: weakSelf.headerView.passwordToConfirm.text:nil];
                accountInfo.account_owner_public_key = [tokenCoreVKT getVktPublicKey:_imported_wallet_id: weakSelf.headerView.passwordToConfirm.text:nil];
                accountInfo.account_active_private_key = [AESCrypt encrypt:[tokenCoreVKT getVktPrivateKey:_imported_wallet_id :weakSelf.headerView.passwordToConfirm.text:nil] password:weakSelf.headerView.passwordToConfirm.text];
                accountInfo.account_owner_private_key = accountInfo.account_active_private_key;
                accountInfo.account_vktoken_wallet_id = _imported_wallet_id;
                accountInfo.is_privacy_policy = @"0";
                [[AccountsTableManager accountTable] addRecord:accountInfo];
                [WalletUtil setMainAccountWithAccountInfoModel:accountInfo];
                
                
                CreateMemonicViewController *vc = [[CreateMemonicViewController alloc] init];
                //                    createPrivateKeyViewController.walletModel = _walletModel;
                //                    createPrivateKeyViewController.privateWords = [[_walletModel.mnemonic tb_encodeStringWithKey:_walletModel.password] componentsSeparatedByString:@" "];
                NSString* nsmnemonic = [tokenCoreVKT getVktMnemonic:_imported_wallet_id: weakSelf.headerView.passwordToConfirm.text:nil];
                NSArray *mnemonicList = [nsmnemonic componentsSeparatedByString:@" "];
                vc.privateWords = mnemonicList;
                [weakSelf.navigationController pushViewController:vc animated:YES];
                
            }else{
                [TOASTVIEW showWithText:VALIDATE_STRING(service[@"message"])];
            }
            
        }
        
    }];
}




@end
