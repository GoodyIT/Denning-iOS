//
//  TenancyViewController.m
//  Denning
//
//  Created by DenningIT on 22/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TenancyViewController.h"
#import "QMAlert.h"

@interface TenancyViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *monthlyRentTextField;
@property (weak, nonatomic) IBOutlet UITextField *annualRentLabel;
@property (weak, nonatomic) IBOutlet UITextField *termsOfTenancyTextField;
@property (weak, nonatomic) IBOutlet UITextField *resultTextField;
@property (weak, nonatomic) IBOutlet UITextField *legalCostTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalTextField;
@property (weak, nonatomic) IBOutlet UILabel *type;

@property (strong, nonatomic) NSDictionary* typeArray;

@end

@implementation TenancyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) prepareUI {
    self.monthlyRentTextField.delegate = self;
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    self.monthlyRentTextField.inputAccessoryView = accessoryView;
    self.termsOfTenancyTextField.inputAccessoryView = accessoryView;
    
    self.typeArray = @{@"Tenency":@(0.25), @"Lease":@(0.5)};
    
    self.type.text = @"Tenency";
}

- (void)handleTap {
    [self.view endEditing:YES];
}

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
    
    self.annualRentLabel.text = [NSString stringWithFormat:@"%.2f", [self getActualNumber:self.monthlyRentTextField.text] * 12];
    [self applyCommaToTextField:self.annualRentLabel];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 3;
//    } else if (section == 1) {
//        return 2;
//    } else if (section == 2) {
//        return 1;
//    }
//    
//    return 0;
//}

- (IBAction)didTapCalculate:(id)sender {
    if ([self.monthlyRentTextField.text isEqualToString:@""]){
        [QMAlert showAlertWithMessage:@"Please input the monthly rent to calculate stamp duty" actionSuccess:NO inViewController:self];
        return;
    }
    
    if ([self.termsOfTenancyTextField.text isEqualToString:@""]){
        [QMAlert showAlertWithMessage:@"Please input the terms of tenancy to calculate stamp duty" actionSuccess:NO inViewController:self];
        return;
    }

    if ([self getActualNumber:self.annualRentLabel.text] <= 2400){
        self.resultTextField.text = @"0";
        return;
    }
    
    double actualValue = [self getActualNumber:self.annualRentLabel.text]/250;
    if ([self getActualNumber:self.termsOfTenancyTextField.text] == 1){
        self.resultTextField.text = [NSString stringWithFormat:@"%.2f", actualValue];
    } else if ([self getActualNumber:self.termsOfTenancyTextField.text] < 4) {
        self.resultTextField.text = [NSString stringWithFormat:@"%.2f", actualValue * 2];
    } else {
        self.resultTextField.text = [NSString stringWithFormat:@"%.2f", actualValue * 4];
    }
    
    // calculate the legal cost
    double legalCost = 0;
    double factor = [[self.typeArray valueForKey:self.type.text] doubleValue];
    double monthlyRent = [[self removeCommaFromString:self.monthlyRentTextField.text] doubleValue];
    legalCost = monthlyRent * factor;
    self.legalCostTextField.text = [NSString stringWithFormat:@"%.2f", legalCost];
    self.totalTextField.text = [NSString stringWithFormat:@"%.2f", (self.resultTextField.text.doubleValue+legalCost)];
    
    [self applyCommaToTextField:self.resultTextField];
    [self applyCommaToTextField: self.legalCostTextField];
    [self applyCommaToTextField: self.totalTextField];
    
}

- (IBAction)didTapReset:(id)sender {
    self.monthlyRentTextField.text = @"";
    self.annualRentLabel.text = @"";
    self.termsOfTenancyTextField.text = @"";
    self.resultTextField.text = @"";
    self.legalCostTextField.text = @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    if (indexPath.section == 0 && indexPath.row == 3) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a Relationship"
                                                rows:[self.typeArray allKeys]
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               self.type.text = selectedValue;
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.type];
    }
    
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
