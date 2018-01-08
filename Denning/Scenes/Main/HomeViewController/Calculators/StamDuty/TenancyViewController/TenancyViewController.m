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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 1;
    }
    
    return 0;
}

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
    double priceValue = [self getActualNumber:self.annualRentLabel.text];
    double legalCost = 0;
    if (priceValue  >= 500000) {
        legalCost  += 500000* 0.01;
    } else {
        legalCost  += priceValue * 0.01;
        legalCost = MAX(legalCost,500);
    }
    priceValue  -= 500000;
    
    if (priceValue  > 0 && priceValue  < 500000){
        legalCost  += priceValue *0.008;
    } else if (priceValue  >= 500000) {
        legalCost  += 500000*0.008;
    }
    priceValue  -= 500000;
    
    if (priceValue  > 0 && priceValue  < 2000000){
        legalCost  += priceValue *0.007;
    } else if (priceValue  >= 2000000) {
        legalCost  += 2000000*0.007;
    }
    priceValue  -= 2000000;
    
    if (priceValue  > 0 && priceValue  < 2000000){
        legalCost  += priceValue *0.006;
    } else if (priceValue  >= 2000000) {
        legalCost  += 2000000*0.006;
    }
    priceValue  -= 2000000;
    
    if (priceValue  > 0 && priceValue  < 2500000){
        legalCost  += priceValue *0.005;
    } else if (priceValue  >= 2500000) {
        legalCost  += 2500000*0.005;
    }
    priceValue  -= 2500000;
    
    if (priceValue > 0) {
        [QMAlert showAlertWithMessage:@"There will be a negotiation for the legal cost with such amount of money" actionSuccess:YES inViewController:self];
    }
    
    self.legalCostTextField.text = [NSString stringWithFormat:@"%.2f", legalCost];
    
    [self applyCommaToTextField:self.resultTextField];
    [self applyCommaToTextField: self.legalCostTextField];
}

- (IBAction)didTapReset:(id)sender {
    self.monthlyRentTextField.text = @"";
    self.annualRentLabel.text = @"";
    self.termsOfTenancyTextField.text = @"";
    self.resultTextField.text = @"";
    self.legalCostTextField.text = @"";
}

@end
