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

- (void) gotoUpload:(FirmURLModel*)urlModel  {
    [DataManager sharedManager].tempServerURL = urlModel.firmServerURL;
    [self performSegueWithIdentifier:kFileUploadSegue sender:nil];
}

- (void) proceedLogin:(FirmURLModel*)urlModel {
    [[DataManager sharedManager] setServerAPI:urlModel.firmServerURL withFirmName:urlModel.name withFirmCity:urlModel.city];
    [self gotoMain];
}

- (void) gotoMain {
    [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
}

- (IBAction) gotoPasswordConfirm: (UIButton*) sender
{
    if ([[DataManager sharedManager].documentView isEqualToString: @"upload"]) {
        [self gotoUpload:self.firmArray[sender.tag]];
    } else {
        [self proceedLogin:self.firmArray[sender.tag]];
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

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//}


@end
