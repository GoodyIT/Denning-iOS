//
//  LoanViewController.m
//  Denning
//
//  Created by DenningIT on 24/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LoanAmortisationViewController.h"
#import "QMAlert.h"

@interface LoanAmortisationViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *loanAmountTF;
@property (weak, nonatomic) IBOutlet UITextField *annualInterestRateTF;
@property (weak, nonatomic) IBOutlet UITextField *loanPeriodInYear;

@property (weak, nonatomic) IBOutlet UITextField *monthlyInslament;
@property (weak, nonatomic) IBOutlet UITextField *numberOfMonths;
@property (weak, nonatomic) IBOutlet UITextField *totalInterest;

@end

@implementation LoanAmortisationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self configureMenuRightBtnWithImagename:@"menu_home" withSelector:@selector(gotoHome)];
}

- (void) gotoHome {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) configureMenuRightBtnWithImagename:(NSString*) imageName withSelector:(SEL) action {
    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 23)];
    [menuBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    [self.navigationItem setRightBarButtonItems:@[menuButtonItem] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareUI {
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    self.loanAmountTF.inputAccessoryView = accessoryView;
    self.annualInterestRateTF.inputAccessoryView = accessoryView;
    self.loanPeriodInYear.inputAccessoryView = accessoryView;

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popupScreen:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItems:@[backButtonItem] animated:YES];
}

- (void) popupScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (IBAction)didTapCalculate:(id)sender {
    if ([self.loanAmountTF.text isEqualToString:@""] || self.loanAmountTF.text.length == 0){
        [QMAlert showAlertWithMessage:@"Please input the loan amount value or loan period in year to calculate stamp duty." actionSuccess:NO inViewController:self];
        return;
    }
    
    double P = [self getActualNumber:self.loanAmountTF.text];
    double r = [self getActualNumber:self.annualInterestRateTF.text] / 12/100;
    double  n = [self getActualNumber:self.loanPeriodInYear.text] * 12;
    
    double A = P * (r + r / (pow(1+r, n) - 1));
    
    self.monthlyInslament.text = [NSString stringWithFormat:@"%.2f", A];
    self.numberOfMonths.text = [NSString stringWithFormat:@"%ld", (long)n];
    double total = n * A - P;
    self.totalInterest.text = [NSString stringWithFormat:@"%.2f", total];
    
    [self applyCommaToTextField:self.monthlyInslament];
    [self applyCommaToTextField:self.numberOfMonths];
    [self applyCommaToTextField:self.totalInterest];
}

- (IBAction)didTapReset:(id)sender {
    self.loanAmountTF.text = @"";
    self.annualInterestRateTF.text = @"";
    self.loanPeriodInYear.text = @"";
    self.monthlyInslament.text = @"";
    self.numberOfMonths.text = @"";
    self.totalInterest.text = @"";
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return 1;
    }
    return 0;
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
