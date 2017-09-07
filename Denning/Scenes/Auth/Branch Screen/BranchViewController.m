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

- (IBAction) gotoPasswordConfirm: (UIButton*) sender
{
    FirmURLModel* urlModel = self.firmArray[sender.tag];
    [[DataManager sharedManager] setServerAPI:urlModel.firmServerURL withFirmName:urlModel.name withFirmCity:urlModel.city];
    
    if (![[DataManager sharedManager].documentView isEqualToString: @"shared"]) {
        if (![[DataManager sharedManager].user.userType isEqualToString:@"denning"] && ![[DataManager sharedManager].user.userType isEqualToString:@"personal"]){
            if ([[DataManager sharedManager].statusCode  isEqual: @(250)]) {
                [self performSegueWithIdentifier:kPasswordConfirmSegue sender:nil];
            } else {
                [self performSegueWithIdentifier:kPersonalFolderSegue sender:urlModel.document];
            }
        } else {
            if ([[DataManager sharedManager].user.userType isEqualToString:@"denning"]) {
                [[QMNetworkManager sharedManager] denningSignIn:[DataManager sharedManager].user.password withCompletion:^(BOOL success, NSString * _Nonnull error, NSDictionary * _Nonnull responseObject) {
                    if (error == nil) {
                        [[DataManager sharedManager] setSessionID:[responseObject valueForKeyNotNull:@"sessionID"]];
                        [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
                    } else {
                        [QMAlert showAlertWithMessage:error.localizedLowercaseString actionSuccess:NO inViewController:self];
                    }
                }];
            } else {
                NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:DENNING_CLIENT_SIGNIN];
                [[QMNetworkManager sharedManager] clientSignIn:url password:[DataManager sharedManager].user.password withCompletion:^(BOOL success, NSDictionary * _Nonnull responseObject, NSString * _Nonnull error, DocumentModel * _Nonnull doumentModel) {
                    if (error == nil) {
                        [[DataManager sharedManager] setSessionID:[responseObject valueForKeyNotNull:@"sessionID"]];
                        if ([[responseObject valueForKeyNotNull:@"statusCode"] isEqualToString:@"200"]) {
                            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
                        } else {
                            [self performSegueWithIdentifier:kPasswordConfirmSegue sender:nil];
                        }
                    } else {
                        [QMAlert showAlertWithMessage:error.localizedLowercaseString actionSuccess:NO inViewController:self];
                    }
                }];
            }
        }
    } else {
        [self gotoSharedFolder];
    }
}

- (void) confirmGotoSharedFolder {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Denning"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Document"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self confirmGotoSharedFolder];
                                                          }]; // 2
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Information"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               
                                                           }]; // 3
    
    [alert addAction:firstAction]; // 4
    [alert addAction:secondAction]; // 5
    
    [self presentViewController:alert animated:YES completion:nil]; // 6
}

- (void) gotoSharedFolder {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    @weakify(self);
    NSString *password = [DataManager sharedManager].user.password;
    [[QMNetworkManager sharedManager] clientSignIn:[[DataManager sharedManager].user.serverAPI stringByAppendingString:DENNING_CLIENT_SIGNIN] password:password withCompletion:^(BOOL success, NSDictionary * _Nonnull responseObject, NSString * _Nonnull error, DocumentModel * _Nonnull doumentModel) {
        
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
