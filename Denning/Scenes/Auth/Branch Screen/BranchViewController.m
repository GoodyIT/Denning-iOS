//
//  BranchViewController.m
//  Denning
//
//  Created by DenningIT on 29/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "BranchViewController.h"
#import "BranchHeaderCell.h"
#import "FolderViewController.h"

@interface BranchViewController ()<BranchHeaderDelegate>
{
    __block BOOL isLoading;
}

@end

@implementation BranchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNibs];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) prepareUI {
   
}

- (void)registerNibs {
    [BranchHeaderCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

#pragma mark - BranchHeaderDelegate
- (void) didBackBtnTapped:(BranchHeaderCell *)cell
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.firmArray.count + 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 140;
    }
    return 71;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        BranchHeaderCell *branchCell = [tableView dequeueReusableCellWithIdentifier:[BranchHeaderCell cellIdentifier] forIndexPath:indexPath];
        [branchCell configureCellWithTitle:@"Select firm"];
        branchCell.delegate = self;
        return branchCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BranchCell" forIndexPath:indexPath];
    
    UIButton *firmBtn = [cell viewWithTag:1];
    firmBtn.tag = indexPath.row - 1;
    FirmURLModel* urlModel = self.firmArray[indexPath.row-1];
    [firmBtn setTitle:urlModel.name forState:UIControlStateNormal];
    
    return cell;
}

- (void) gotoUpload:(FirmURLModel*)urlModel  {
    [DataManager sharedManager].tempServerURL = urlModel.firmServerURL;
    [self performSegueWithIdentifier:kFileUploadSegue sender:nil];
}

- (void) proceedLogin:(FirmURLModel*)urlModel {
    
    [self staffLogin:urlModel];
}

- (void) gotoMain {
    [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
}

- (void) gotoSharedFolder:(FirmURLModel*)urlModel  {
    [DataManager sharedManager].tempServerURL = urlModel.firmServerURL;
    [self clientLogin];
}

- (void) staffLogin:(FirmURLModel*)urlModel {
    if (isLoading) return;
    isLoading = YES;
    
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:DENNING_SIGNIN_URL];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    @weakify(self)
    [[QMNetworkManager sharedManager] staffSignIn:url password:[DataManager sharedManager].user.password withCompletion:^(NSDictionary * _Nonnull responseObject, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            if ([[responseObject valueForKeyNotNull:@"statusCode"] isEqual:@(200)]) {
                [[DataManager sharedManager] setServerAPI:urlModel.firmServerURL withFirmName:urlModel.name withFirmCity:urlModel.city];
                [[DataManager sharedManager] setOnlySessionID:[responseObject valueForKeyNotNull:@"sessionID"]];
                [self gotoMain];
            } else {
                [QMAlert showAlertWithMessage:@"You have no access privilege to this firm." actionSuccess:NO inViewController:self];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) clientLogin {
    if (isLoading) return;
    isLoading = YES;
    NSString* url = [[DataManager sharedManager].tempServerURL stringByAppendingString:DENNING_CLIENT_SIGNIN];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    @weakify(self)
    [[QMNetworkManager sharedManager] clientSignIn:url password:[DataManager sharedManager].user.password withCompletion:^(BOOL success, NSDictionary * _Nonnull responseObject, NSError * _Nonnull error, DocumentModel * _Nonnull doumentModel) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [[DataManager sharedManager] setOnlySessionID:[responseObject valueForKeyNotNull:@"sessionID"]];
            if ([[responseObject valueForKeyNotNull:@"statusCode"] isEqual:@(250)]) {
                [self clientFirstLogin];
            } else {
                if (doumentModel.folders.count == 0) {
                    [QMAlert showAlertWithMessage:@"There is no shared folder for you" actionSuccess:NO inViewController:self];
                } else {
                    [self performSegueWithIdentifier:kPersonalFolderSegue sender:doumentModel];
                }
            }
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) clientFirstLogin {
    NSString* url = [[DataManager sharedManager].tempServerURL stringByAppendingString:DENNING_CLIENT_FIRST_SIGNIN];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    [[QMNetworkManager sharedManager] clientSignIn:url password:@"5566" withCompletion:^(BOOL success, NSDictionary * _Nonnull responseObject, NSError * _Nonnull error, DocumentModel * _Nonnull doumentModel) {
        [SVProgressHUD dismiss];
        if (error == nil) {
            [[DataManager sharedManager] setOnlySessionID:[responseObject valueForKeyNotNull:@"sessionID"]];
            [self performSegueWithIdentifier:kPersonalFolderSegue sender:doumentModel];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (IBAction) gotoPasswordConfirm: (UIButton*) sender
{
    if ([[DataManager sharedManager].documentView isEqualToString: @"upload"]) {
        [self gotoUpload:self.firmArray[sender.tag]];
    } else if ([[DataManager sharedManager].documentView isEqualToString: @"shared"]) {
        [self gotoSharedFolder:self.firmArray[sender.tag]];
    } else {
        [self proceedLogin:self.firmArray[sender.tag]];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPersonalFolderSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        FolderViewController* folderVC = (FolderViewController*)nav.topViewController;
        folderVC.documentModel = sender;
    }
}


@end
