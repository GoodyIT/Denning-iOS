//
//  LoanViewController.m
//  Denning
//
//  Created by DenningIT on 22/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LoanViewController.h"
#import "QMAlert.h"

@interface LoanViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *loanAmount;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *resultLabel;
@property (weak, nonatomic) IBOutlet UITextField *legalCostTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalTextField;

@property (strong, nonatomic)NSArray* typesArray;

@end

@implementation LoanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self prepareUI];
}

- (void) prepareUI {
    self.typesArray = [NSArray arrayWithObjects:@"Conventional", @"Islamic", nil];
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    self.loanAmount.inputAccessoryView = accessoryView;
}

- (void)handleTap {
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    
//    return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 2;
//    } else if (section == 1) {
//        return 2;
//    } else if (section == 2) {
//        return 1;
//    }
//    return 6;
//}

- (NSString*) removeCommaFromString: (NSString*) formattedNumber
{
    NSArray * comps = [formattedNumber componentsSeparatedByString:@","];
    
    NSString * result = nil;
    for(NSString *s in comps)
    {
        if(result)
        {
            result = [result stringByAppendingFormat:@"%@",[s capitalizedString]];
        } else
        {
            result = [s capitalizedString];
        }
    }
    
    return result;
}
- (double) getActualNumber: (NSString*) formattedNumber
{
    return [[self removeCommaFromString:formattedNumber] doubleValue];
}

- (void) applyCommaToTextField:(UITextField*) textField
{
    NSString *mystring = [self removeCommaFromString:textField.text];
    NSNumber *number = [NSDecimalNumber decimalNumberWithString:mystring];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    textField.text = [formatter stringFromNumber:number];
}

#pragma mark - UITexFieldDelegate
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [self applyCommaToTextField:textField];
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a type"
                                                rows:self.typesArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               self.typeLabel.text = selectedValue;
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.typeLabel];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapCalculate:(id)sender {
    if ([self.loanAmount.text isEqualToString:@""]){
        [QMAlert showAlertWithMessage:@"Please input the loan amount value to calculate stamp duty" actionSuccess:NO inViewController:self];
        return;
    }

    if (self.typeLabel.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the relationship you want to apply for" actionSuccess:YES inViewController:self];
        return;
    }
    
    double stamDuty;
    if ([self.typeLabel.text isEqualToString:@"Conventional"]) {
        stamDuty = [self getActualNumber:self.loanAmount.text]*0.005;
    } else { // Islamic
        stamDuty = [self getActualNumber:self.loanAmount.text]*0.005*80/100;
    }
    
    // calculate the legal cost
    double priceValue = [self getActualNumber:self.loanAmount.text];
    double legalCost = [[DIHelpers calcLoanAndLegal:priceValue][1] doubleValue];
    priceValue = [[DIHelpers calcLoanAndLegal:priceValue][0] doubleValue];
    
    if (priceValue > 0) {
        [QMAlert showAlertWithMessage:@"There will be a negotiation for the legal cost with such amount of money" actionSuccess:YES inViewController:self];
    }
    
    self.resultLabel.text = [NSString stringWithFormat:@"%.2f", stamDuty];
    self.legalCostTextField.text =[NSString stringWithFormat:@"%.2f", legalCost];
    
    [self applyCommaToTextField:self.resultLabel];
    [self applyCommaToTextField: self.legalCostTextField];
}

- (IBAction)didTapReset:(id)sender {
    self.loanAmount.text = @"";
    self.typeLabel.text = @"";
    self.resultLabel.text = @"";
    self.legalCostTextField.text = @"";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
