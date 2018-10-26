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
#import "FirmPasswordConfirmViewController.h"

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
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

    return self.firmArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0) {
//        BranchHeaderCell *branchCell = [tableView dequeueReusableCellWithIdentifier:[BranchHeaderCell cellIdentifier] forIndexPath:indexPath];
//        [branchCell configureCellWithTitle:@"Select firm"];
//        branchCell.delegate = self;
//        return branchCell;
//    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BranchCell" forIndexPath:indexPath];
    
    UIButton *firmBtn = [cell viewWithTag:1];
    firmBtn.titleLabel.minimumScaleFactor = 0.5f;
    firmBtn.titleLabel.numberOfLines = 0;
    firmBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    firmBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    firmBtn.tag = indexPath.row;
    FirmURLModel* urlModel = self.firmArray[indexPath.row];
    NSString* buttonTitle = [NSString stringWithFormat:@"%@\n%@", urlModel.name, urlModel.city];
    [firmBtn setTitle:buttonTitle forState:UIControlStateNormal];
    
    return cell;
}

- (void) proceedLogin:(FirmURLModel*)urlModel {
    [[DataManager sharedManager] setServerAPI:urlModel.firmServerURL firmURLModel:urlModel];
    [self staffLogin:urlModel];
}

- (void) gotoMain {
    [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
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
                [[DataManager sharedManager] setOnlySessionID:[responseObject valueForKeyNotNull:@"sessionID"]];
                [self gotoMain];
            } else {
                [QMAlert showAlertWithMessage:@"You have no access privilege to this firm." actionSuccess:NO inViewController:self];
            }
            
        } else {
            [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
        }
    }];
}

- (void) clientLogin:(FirmURLModel*)urlModel  {
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
            [[DataManager sharedManager] setOnlySessionID:[responseObject valueForKeyNotNull:@"theCode"]];
            if ([[responseObject valueForKeyNotNull:@"statusCode"] isEqual:@(250)]) {
                [self performSegueWithIdentifier:kFirmPasswordSegue sender:urlModel];
            } else {
                if ([[DataManager sharedManager].documentView isEqualToString: @"upload"]) {
                    [self performSegueWithIdentifier:kFileUploadSegue sender:nil];
                } else {
                    if (doumentModel.folders.count == 0) {
                        [QMAlert showAlertWithMessage:@"There is no shared folder for you" actionSuccess:NO inViewController:self];
                    } else {
                        [self performSegueWithIdentifier:kPersonalFolderSegue sender:doumentModel];
                    }
                }
            }
        } else {
            [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
        }
    }];
}

- (IBAction) gotoPasswordConfirm: (UIButton*) sender
{
    if ([[DataManager sharedManager].documentView isEqualToString: @"upload"] || [[DataManager sharedManager].documentView isEqualToString: @"shared"]) {
        [DataManager sharedManager].tempServerURL = self.firmArray[sender.tag].firmServerURL;
        [DataManager sharedManager].tempTheCode = self.firmArray[sender.tag].theCode;
        
        [self clientLogin:self.firmArray[sender.tag]];
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
    } else if ([segue.identifier isEqualToString:kFirmPasswordSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        FirmPasswordConfirmViewController* vc = nav.viewControllers.firstObject;
        FirmURLModel* model = (FirmURLModel*) sender;
        vc.branch = model.city;
        vc.firmName = model.name;
    }
}


@end
