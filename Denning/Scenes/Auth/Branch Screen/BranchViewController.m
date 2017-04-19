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

@end

@implementation BranchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNibs];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareUI {
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_background.png"]];
}

- (void)registerNibs {
    [BranchHeaderCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

#pragma mark - BranchHeaderDelegate
- (void) didBackBtnTapped:(BranchHeaderCell *)cell
{
    [self.navigationController popViewControllerAnimated:YES];
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
        [branchCell configureCellWithTitle:@"Select a Branch"];
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

- (IBAction) gotoPasswordConfirm: (UIButton*) sender
{
    FirmURLModel* urlModel = self.firmArray[sender.tag];
    [[DataManager sharedManager] setServerAPI:urlModel.firmServerURL withFirmName:urlModel.name];
    
    if (![[DataManager sharedManager].documentView isEqualToString: @"shared"]) {
        if (![[DataManager sharedManager].user.userType isEqualToString:@"denning"]){
            if ([[DataManager sharedManager].statusCode  isEqual: @(250)]) {
                [self performSegueWithIdentifier:kPasswordConfirmSegue sender:nil];
            } else {
                [self performSegueWithIdentifier:kPersonalFolderSegue sender:urlModel.document];
            }
        } else {
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
        }
    } else {
        [self gotoSharedFolder];
    }
}

- (void) gotoSharedFolder {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    @weakify(self);
    NSString *password = [DataManager sharedManager].user.password;
    [[QMNetworkManager sharedManager] clientSignIn:[[DataManager sharedManager].user.serverAPI stringByAppendingString:DENNING_CLIENT_SIGNIN] password:password withCompletion:^(BOOL success, NSString * _Nonnull error, DocumentModel * _Nonnull doumentModel) {
        
        [SVProgressHUD dismiss];
        @strongify(self);
        if (success) {
            [self performSegueWithIdentifier:kPersonalFolderSegue sender:doumentModel];
        } else {
            [QMAlert showAlertWithMessage:error actionSuccess:NO inViewController:self];
        }
    }];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPersonalFolderSegue]) {
        FolderViewController* folderVC = segue.destinationViewController;
        folderVC.documentModel = sender;
    }
}


@end
