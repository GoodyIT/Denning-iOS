//
//  ChangeBranchViewController.m
//  Denning
//
//  Created by DenningIT on 04/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ChangeBranchViewController.h"

@interface ChangeBranchViewController ()
{
    __block BOOL isLoading;
}

@end

@implementation ChangeBranchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
}
- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.branchArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChangeBranchCell" forIndexPath:indexPath];
    
    FirmURLModel* model = self.branchArray[indexPath.row];
    UILabel* branchName = [cell viewWithTag:1];
    branchName.text = model.name;
    UILabel* cityName = [cell viewWithTag:2];
    cityName.text = model.city;
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if ([model.city isEqualToString:[DataManager sharedManager].user.firmCity]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FirmURLModel* model = self.branchArray[indexPath.row];
    [[DataManager sharedManager] setServerAPI:model.firmServerURL firmURLModel:model];
    [self staffLogin:model];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.navigationController popViewControllerAnimated:YES];
                });
            } else {
                [QMAlert showAlertWithMessage:@"You have no access privilege to this firm." actionSuccess:NO inViewController:self];
            }
            
        } else {
            [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
        }
    }];
}


@end
