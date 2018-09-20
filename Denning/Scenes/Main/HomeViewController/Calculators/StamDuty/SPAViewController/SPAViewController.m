//
//  SPAViewController.m
//  Denning
//
//  Created by DenningIT on 22/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "SPAViewController.h"
#import "QMAlert.h"

@interface SPAViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *priceValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *loanAmount;
@property (weak, nonatomic) IBOutlet UILabel *loanType;

@property (weak, nonatomic) IBOutlet UITextField *stampSPA;
@property (weak, nonatomic) IBOutlet UITextField *stampLoan;
@property (weak, nonatomic) IBOutlet UILabel *relationshipLabel;
@property (weak, nonatomic) IBOutlet UILabel *marginLabel;
@property (strong, nonatomic) NSArray* relationsArray;
@property (strong, nonatomic) NSMutableDictionary* marginArray;
@property (strong, nonatomic) NSDictionary* loanTypeArray;
@property (strong, nonatomic) NSMutableArray* loanMarginLabelArray;
@property (weak, nonatomic) IBOutlet UITextField *legalSPA;
@property (weak, nonatomic) IBOutlet UITextField *legalLoan;
@property (weak, nonatomic) IBOutlet UITextField *totalSPA;
@property (weak, nonatomic) IBOutlet UITextField *totalLoan;

@property (weak, nonatomic) IBOutlet UITextField *grandTotal;
@end

@implementation SPAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
}

- (void) prepareUI {
    self.relationsArray = [NSArray arrayWithObjects:@"Seller-Purchaser (100%)", @"Husband-wife (0%)", @"Parents-Child (50%)", @"Grandparent-Grandchild (50%)", @"Trustee-Beneficiary (RM10)", @"Administrator-Beneficiary (RM10)", @"Executor-Beneficiary (RM10)", @"Trustee-Trustee (RM10)flat", @"No consideration(Gift)100%", @"Others (RM10)", nil];
    
    self.marginArray = [NSMutableDictionary new];
    self.loanMarginLabelArray = [NSMutableArray new];
    for (int i = 100; i >= 1; i--) {
        NSString* label = [NSString stringWithFormat:@"%d%%", i];
        [self.loanMarginLabelArray addObject:label];
        [self.marginArray addEntriesFromDictionary:@{label: @(i)}];
    }
    
    self.loanTypeArray = @{@"Conventional":@(0.005), @"Islamic":@(0.005*0.8)};
    // Set the defaul value
    self.relationshipLabel.text = self.relationsArray[0];
    self.marginLabel.text = @"90%";
    self.loanType.text = @"Conventional";
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    self.priceValueTextField.inputAccessoryView = self.loanAmount.inputAccessoryView = accessoryView;
    
    [self.totalSPA addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapReset:(id)sender {
    self.priceValueTextField.text = self.relationshipLabel.text = self.totalSPA.text = self.totalLoan.text =
    self.legalSPA.text = self.legalLoan.text = @"";
}

- (void) calcLoanAmount {
    if (self.priceValueTextField.text.length == 0) {
        return;
    }
    double priceValue = [self getActualNumber:self.priceValueTextField.text];
    double loanMarginValue = [[self.marginArray valueForKey:self.marginLabel.text] doubleValue];
    self.loanAmount.text = [NSString stringWithFormat:@"%.2f", (priceValue*loanMarginValue/100.0f)];
}


- (IBAction)didTapCalculate:(id)sender {
    double priceValue = [self getActualNumber:self.priceValueTextField.text];
    double backPrice = priceValue;
    if ([self.priceValueTextField.text isEqualToString:@""]){
        [QMAlert showAlertWithMessage:@"Please input the price or market value to calculate stamp duty." actionSuccess:NO inViewController:self];
        return;
    }
    
    if (self.relationshipLabel.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the relationship you want to apply for." actionSuccess:YES inViewController:self];
        return;
    }
    
    if (self.marginLabel.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the loan margin you want to apply for." actionSuccess:YES inViewController:self];
        return;
    }
    
    // Calculate the stam Duty
    double stamDuty = 0;
    if (priceValue  >= 100000) {
        stamDuty  += 100000* 0.01;
    } else {
        stamDuty  += priceValue * 0.01;
    }
    
    priceValue  -= 100000;
    
    if (priceValue  > 0 && priceValue  < 400000){
        stamDuty  += priceValue *0.02;
    } else if (priceValue  >= 400000) {
        stamDuty  += 400000*0.02;
    }
    
    priceValue  -= 400000;
    
    if (priceValue  > 0) {
        stamDuty  += priceValue *0.03;
    }
    
    // calculate the legal cost
    priceValue = [[DIHelpers calcLoanAndLegal:backPrice][0] doubleValue];
    
    double legalCost = [[DIHelpers calcLoanAndLegal:backPrice][1] doubleValue];
    
    if (priceValue > 0) {
        [QMAlert showInformationWithMessage:@"Legal fee is negotiable for such price." inViewController:self];
    }
    
    if ([self.relationshipLabel.text isEqualToString:@"Seller-Purchaser (100%)"] || [self.relationshipLabel.text isEqualToString:@"No consideration(Gift)100%"])
    {
        stamDuty  *= 1; // 100%
        
    } else if ([self.relationshipLabel.text isEqualToString:@"Husband-wife (0%)"]){
        // No more stamp duty
        stamDuty  = 0;
    } else if ([self.relationshipLabel.text isEqualToString:@"Parents-Child (50%)"]){
        stamDuty  *= .5; // 50%
    } else if ([self.relationshipLabel.text isEqualToString:@"Grandparent-Grandchild (50%)"]){
        stamDuty  *= .5; // 50%
    } else if ([self.relationshipLabel.text isEqualToString:@"Administrator-Beneficiary (RM10)"] ||  [self.relationshipLabel.text isEqualToString:@"Executor-Beneficiary (RM10)"] || [self.relationshipLabel.text isEqualToString:@"Trustee-Beneficiary (RM10)"] || [self.relationshipLabel.text isEqualToString:@"Trustee-Trustee (RM10)flat"] || [self.relationshipLabel.text isEqualToString:@"Others (RM10)"]) {
        stamDuty = 10;
    } else {
        stamDuty  += 10; // Add RM10
    }
    
    legalCost *= 1;
    self.stampSPA.text = [NSString stringWithFormat:@"%.2f", stamDuty ];
    self.legalSPA.text = [NSString stringWithFormat:@"%.2f", legalCost];
    double totalValue = stamDuty + legalCost;
    self.totalSPA.text = [NSString stringWithFormat:@"%.2f", totalValue];
    [DIHelpers applyCommaToTextField:self.totalSPA];
    [DIHelpers applyCommaToTextField:self.legalSPA];
    [DIHelpers applyCommaToTextField:self.totalSPA];
    
    // Calculate Loan
    double amountValue = backPrice * [[self.marginArray valueForKey:self.marginLabel.text] doubleValue] / 100.0f;
    self.loanAmount.text = [NSString stringWithFormat:@"%.2f", amountValue];
    double stampDutyLoan = [[self.loanTypeArray valueForKey:self.loanType.text] doubleValue] * backPrice;
    double legalLoan = [[DIHelpers calcLoanAndLegal:backPrice][1] doubleValue];
    priceValue = [[DIHelpers calcLoanAndLegal:backPrice][0] doubleValue];
    self.stampLoan.text = [NSString stringWithFormat:@"%.2f", stampDutyLoan];
    self.legalLoan.text = [NSString stringWithFormat:@"%.2f", legalLoan];
    self.totalLoan.text = [NSString stringWithFormat:@"%.2f", (stampDutyLoan+legalLoan)];
    self.grandTotal.text = [NSString stringWithFormat:@"%.2f", (self.totalLoan.text.doubleValue+self.totalSPA.text.doubleValue)];
}

- (double) getActualNumber: (NSString*) formattedNumber
{
    return [[DIHelpers removeCommaFromString:formattedNumber] doubleValue];
}

#pragma mark - UITexFieldDelegate
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [DIHelpers applyCommaToTextField:textField];
    }
    
    if (textField.tag == 10) {
         double priceValue = [self getActualNumber:self.priceValueTextField.text];
        if (priceValue > 0) {
            
        }
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a Relationship"
                                            rows:self.relationsArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               self.relationshipLabel.text = selectedValue;
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.relationshipLabel];
    }
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a Margin"
                                                rows:self.loanMarginLabelArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               self.marginLabel.text = selectedValue;
                                               [self calcLoanAmount];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.relationshipLabel];
    }
    
    if (indexPath.section == 0 && indexPath.row == 4) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a Loan Type"
                                                rows:[self.loanTypeArray allKeys]
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               self.loanType.text = selectedValue;
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.relationshipLabel];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
