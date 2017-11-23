//
//  PaymentRecord.m
//  Denning
//
//  Created by Ho Thong Mee on 20/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PaymentRecord.h"
#import "BankReconHeaderCell.h"
#import "PaymentRecordFirstCell.h"
#import "PaymentRecordCell.h"

@interface PaymentRecord ()

@property (strong, nonatomic) NSDictionary* payment;

@end

@implementation PaymentRecord

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNib];
    [self getList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) registerNib {
    [PaymentRecordCell registerForReuseInTableView:self.tableView];
    [PaymentRecordFirstCell registerForReuseInTableView:self.tableView];
    [BankReconHeaderCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.tableFooterView = [UIView new];
}

- (void) getList {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Loading" duration:0.0];
    @weakify(self)
    [[QMNetworkManager sharedManager] getPaymentRecordWithFileNo:(NSString*)_fileNo completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
            _payment = result;
            [self.tableView reloadData];
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 33;
    } else {
        return 10;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
      return  [[_payment objectForKeyNotNull:@"section1"] count];
    } else if (section == 1) {
        return  [[_payment objectForKeyNotNull:@"section2"] count];
    } else {
        return  [[_payment objectForKeyNotNull:@"section3"] count];
    }

    return 0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BankReconHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[BankReconHeaderCell cellIdentifier]];
    cell.firstValue.text = @"Date Paid";
    cell.secondValue.text = @"Paid to";
    cell.thirdValue.text = @"Amount (RM)";
    cell.thirdValue.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
       NSArray* section1 = [_payment objectForKeyNotNull:@"section1"];
        PaymentRecordFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:[PaymentRecordFirstCell cellIdentifier] forIndexPath:indexPath];
        cell.firstValue.text = [DIHelpers getDateInShortForm:(NSString*)[section1[indexPath.row] valueForKeyNotNull:@"dtDatePaid"]];
        cell.secondValue.text = [section1[indexPath.row] valueForKeyNotNull:@"strPaidTo"];
        cell.thirdValue.text = [section1[indexPath.row] valueForKeyNotNull:@"decAmount"];
        return cell;
    }
        PaymentRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:[PaymentRecordCell cellIdentifier] forIndexPath:indexPath];
    if (indexPath.section == 1) {
       NSArray* section2 = [_payment objectForKeyNotNull:@"section2"];
        cell.firstLabel.text = [section2[indexPath.row] valueForKeyNotNull:@"strDescription"];
        cell.secondLabel.text = [section2[indexPath.row] valueForKeyNotNull:@"strValue"];
    } else if (indexPath.section == 2) {
        NSArray* section3 = [_payment objectForKeyNotNull:@"section3"];
        cell.firstLabel.text = [section3[indexPath.row] valueForKeyNotNull:@"strDescription"];
        cell.secondLabel.text = [section3[indexPath.row] valueForKeyNotNull:@"strValue"];
    }
    
    // Configure the cell...
    
    return cell;
}


@end
