//
//  TransactionDetail.m
//  Denning
//
//  Created by Ho Thong Mee on 16/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TransactionDetail.h"

@interface TransactionDetail ()
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *transactionNo;
@property (weak, nonatomic) IBOutlet UILabel *fileNo;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *billNo;
@property (weak, nonatomic) IBOutlet UILabel *recdPaid;
@property (weak, nonatomic) IBOutlet UILabel *descriptionValue;
@property (weak, nonatomic) IBOutlet UILabel *DRAmount;
@property (weak, nonatomic) IBOutlet UILabel *CRAmount;
@property (weak, nonatomic) IBOutlet UILabel *mode;
@property (weak, nonatomic) IBOutlet UILabel *bankAccount;
@property (weak, nonatomic) IBOutlet UILabel *issuedBy;
@property (weak, nonatomic) IBOutlet UILabel *updatedBy;

@end

@implementation TransactionDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Transaction Detail";
    self.date.text = [DIHelpers convertDateToCustomFormat:_model.date];
    self.transactionNo.text = _model.documentNo;
    self.fileNo.text = _model.fileNo;
    self.fileName.text = _model.fileName;
    self.billNo.text = _model.taxInvoice;
    self.recdPaid.text = _model.recdPaid;
    self.descriptionValue.text = _model.ledgerDescription;
    self.DRAmount.text = _model.amountDR;
    self.CRAmount.text = _model.amountCR;
    self.mode.text = _model.paymentMode;
    self.bankAccount.text = _model.bankAcc;
    self.issuedBy.text = _model.issuedBy;
    self.updatedBy.text = _model.updatedBy;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 13;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
