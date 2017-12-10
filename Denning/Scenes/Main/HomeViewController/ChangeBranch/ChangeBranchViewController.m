//
//  ChangeBranchViewController.m
//  Denning
//
//  Created by DenningIT on 04/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ChangeBranchViewController.h"

@interface ChangeBranchViewController ()

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
    [[DataManager sharedManager] setServerAPI:model.firmServerURL withFirmName:model.name withFirmCity:model.city];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
