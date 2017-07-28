//
//  RealPropertyGainTaxViewController.m
//  Denning
//
//  Created by DenningIT on 23/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "RealPropertyGainTaxViewController.h"
#import "CalendarViewController.h"
#import "QMAlert.h"

@interface RealPropertyGainTaxViewController ()<UITextFieldDelegate>
{
    double numberOfYears;
    NSDate *disposalDate;
    NSDate *acquisitionDate;
    NSDateFormatter *dateFormat;
    double taxRate;
    double realpropertyTax;
}
@property (weak, nonatomic) IBOutlet UITextField *disposalPriceTF;
@property (weak, nonatomic) IBOutlet UITextField *saleCommissionTF;
@property (weak, nonatomic) IBOutlet UITextField *legalCostsTF;
@property (weak, nonatomic) IBOutlet UITextField *renovationImprovementTF;
@property (weak, nonatomic) IBOutlet UITextField *netDisposalPriceTF;

@property (weak, nonatomic) IBOutlet UITextField *acquisitionPriceTF;
@property (weak, nonatomic) IBOutlet UITextField *purchaseCommisionTF;
@property (weak, nonatomic) IBOutlet UITextField *legalCostsStampDutyTF;
@property (weak, nonatomic) IBOutlet UITextField *otherCostsIncurredTF;
@property (weak, nonatomic) IBOutlet UITextField *netAcquisitionPriceTF;
@property (weak, nonatomic) IBOutlet UITextField *gainsLossTF;
@property (weak, nonatomic) IBOutlet UITextField *dateOfDisposalTF;
@property (weak, nonatomic) IBOutlet UITextField *dateOfAcquizition;
@property (weak, nonatomic) IBOutlet UITextField *numberOfYearHeldTF;
@property (weak, nonatomic) IBOutlet UITextField *statusOfTaxPayerTF;
@property (weak, nonatomic) IBOutlet UITextField *taxRateTF;

@property (weak, nonatomic) IBOutlet UITextField *taxPayable;

@property (strong, nonatomic) NSArray* statusOfTaxPayerArray;

@end

@implementation RealPropertyGainTaxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self configureMenuRightBtnWithImagename:@"menu_home" withSelector:@selector(gotoHome)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) gotoHome {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareUI {
    self.statusOfTaxPayerArray = @[@"Malaysian Individual / PR", @"Malaysian Company", @"Foreigner", @"Foreign Company"];
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    self.disposalPriceTF.inputAccessoryView = accessoryView;
    self.saleCommissionTF.inputAccessoryView = accessoryView;
    self.legalCostsTF.inputAccessoryView = accessoryView;
    self.renovationImprovementTF.inputAccessoryView = accessoryView;
    self.purchaseCommisionTF.inputAccessoryView = accessoryView;
    self.acquisitionPriceTF.inputAccessoryView = accessoryView;
    self.legalCostsStampDutyTF.inputAccessoryView = accessoryView;
    self.otherCostsIncurredTF.inputAccessoryView = accessoryView;
    self.numberOfYearHeldTF.inputAccessoryView = accessoryView;
    
    self.dateOfDisposalTF.delegate = self;
    self.dateOfAcquizition.delegate = self;

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popupScreen:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItems:@[backButtonItem] animated:YES];
}

- (void) popupScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) configureMenuRightBtnWithImagename:(NSString*) imageName withSelector:(SEL) action {
    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 23)];
    [menuBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    [self.navigationItem setRightBarButtonItems:@[menuButtonItem] animated:YES];
}

- (void)handleTap {
    [self.view endEditing:YES];
}


- (void)showCalendar: (NSString*) typeString {
    [self.view endEditing:YES];
    
    CalendarViewController *calendarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.realVC = self;
    calendarViewController.typeOfDate = typeString;
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:calendarViewController];
    [STPopupNavigationBar appearance].barTintColor = [UIColor blackColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"SFUIText-Medium" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.containerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    popupController.containerView.layer.shadowOffset = CGSizeMake(4, 4);
    popupController.containerView.layer.shadowOpacity = 1;
    popupController.containerView.layer.shadowRadius = 1.0;
    
    [popupController presentInViewController:self];
}

- (double) calculateNetDisposalPrice
{
    return [self getActualNumber:self.disposalPriceTF.text] - [self getActualNumber:self.saleCommissionTF.text] - [self getActualNumber:self.legalCostsTF.text] - [self getActualNumber:self.renovationImprovementTF.text];
}

- (double) calculateNetAcquisitionPrice
{
    return [self getActualNumber:self.acquisitionPriceTF.text] + [self getActualNumber:self.purchaseCommisionTF.text] + [self getActualNumber:self.legalCostsStampDutyTF.text] + [self getActualNumber:self.otherCostsIncurredTF.text];
}

- (BOOL) checkInputValidate
{
    BOOL isValid = YES;
    
    if (self.disposalPriceTF.text.length == 0 || self.saleCommissionTF.text.length == 0 || self.legalCostsTF.text.length == 0 || self.renovationImprovementTF.text.length == 0 || self.acquisitionPriceTF.text.length == 0 || self.purchaseCommisionTF.text.length == 0 || self.legalCostsTF.text.length == 0 || self.otherCostsIncurredTF.text.length == 0 || self.dateOfDisposalTF.text.length == 0 || self.dateOfAcquizition.text.length == 0 || self.statusOfTaxPayerTF.text.length == 0) {
        return NO;
    }
    
    if (isValid) {
        [self calculateNumberOfYearHeld];
    }
    
    return isValid;
}

- (IBAction)didTapCalculate:(id)sender {
    if (![self checkInputValidate]) {
        [QMAlert showAlertWithMessage:@"Please input all the values before calculation." actionSuccess:NO inViewController:self];
        return;
    }
    
    double gainsLoss = [self getActualNumber:self.gainsLossTF.text];
    
    if ([self.statusOfTaxPayerTF.text isEqualToString:@"Malaysian Company"]) {
        [self calculateTaxRateForLocalCompany];
        realpropertyTax =  gainsLoss * taxRate / 100;
    } else if ([self.statusOfTaxPayerTF.text isEqualToString:@"Malaysian Individual / PR"]) {
        [self calculateTaxRateForLocalPerson];
        realpropertyTax =  gainsLoss * taxRate / 100;
//        [self applyTaxRestriction];
    } else if ([self.statusOfTaxPayerTF.text isEqualToString:@"Foreigner"]) {
        [self calculateTaxRateForForeignerAndCompany];
        realpropertyTax =  gainsLoss * taxRate / 100;
//        [self applyTaxRestriction];
    } else if ([self.statusOfTaxPayerTF.text isEqualToString:@"Foreign Company"]) {
        [self calculateTaxRateForForeignerAndCompany];
        realpropertyTax =  gainsLoss * taxRate / 100;
    }
    
    self.taxRateTF.text = [NSString stringWithFormat:@"%.2f", taxRate];
    self.taxPayable.text = [NSString stringWithFormat:@"%2.f", realpropertyTax];
    [self applyCommaToTextField:self.taxRateTF];
    [self applyCommaToTextField:self.taxPayable];
}

- (void) applyTaxRestriction
{
    if ([acquisitionDate earlierDate:[dateFormat dateFromString:@"2014-01-01"]]) {
        realpropertyTax = MAX(realpropertyTax, 5000);
    } else {
        realpropertyTax = MAX(realpropertyTax, 10000);
    }
}

- (void) calculateTaxRateForLocalCompany
{
    taxRate = 0;
//    if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2009-12-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2012-01-01"]]){
//        taxRate = 5;
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2011-12-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2013-01-01"]]) {
//        if (numberOfYears <= 2) {
//            taxRate = 10;
//        } else if (numberOfYears <= 5) {
//            taxRate = 5;
//        }
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2012-12-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2014-01-01"]]) {
//        if (numberOfYears <= 2) {
//            taxRate = 15;
//        } else if (numberOfYears <= 5) {
//            taxRate = 10;
//        }
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2013-12-31"]]) {
//        if (numberOfYears <= 3) {
//            taxRate = 30;
//        } else if (numberOfYears <= 4) {
//            taxRate = 20;
//        } else if (numberOfYears <= 5) {
//            taxRate = 15;
//        } else if (numberOfYears <= 6) {
//           taxRate = 5;
//        }
//    }
    
    if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2014-01-01"]]) {
        if (numberOfYears < 2) {
            taxRate = 30;
        } else if (numberOfYears < 3) {
            taxRate = 30;
        } else if (numberOfYears < 4) {
            taxRate = 20;
        } else if (numberOfYears < 5) {
            taxRate = 15;
        } else {
            taxRate = 5;
        }
    }
}

- (void) calculateTaxRateForLocalPerson
{
    taxRate = 0;
//    if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2009-12-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2012-01-01"]]){
//        taxRate = 5;
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2011-12-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2013-01-01"]]) {
//        if (numberOfYears <= 2) {
//            taxRate = 10;
//        } else if (numberOfYears <= 5) {
//            taxRate = 5;
//        }
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2012-12-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2014-01-01"]]) {
//        if (numberOfYears <= 2) {
//            taxRate = 15;
//        } else if (numberOfYears <= 5) {
//            taxRate = 10;
//        }
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2013-12-31"]]) {
//        if (numberOfYears <= 3) {
//            taxRate = 30;
//        } else if (numberOfYears <= 4) {
//            taxRate = 20;
//        } else if (numberOfYears <= 5) {
//            taxRate = 15;
//        }
//    }
    if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2014-01-01"]]) {
        if (numberOfYears < 2) {
            taxRate = 30;
        } else if (numberOfYears < 3) {
            taxRate = 30;
        } else if (numberOfYears < 4) {
            taxRate = 20;
        } else if (numberOfYears < 5) {
            taxRate = 15;
        } else {
            taxRate = 0;
        }
    }

}

- (void) calculateTaxRateForForeignerAndCompany
{
    taxRate = 0;
//    if ([acquisitionDate laterDate:[dateFormat dateFromString:@"1997-10-16"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2007-04-01"]]){
//        if (numberOfYears <= 5) {
//            taxRate = 30;
//        } else {
//            taxRate = 5;
//        }
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2007-03-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2010-01-01"]]){
//        taxRate = 0;
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2010-05-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2012-06-01"]]){
//        if (numberOfYears <= 5) {
//            taxRate = 5;
//        }
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2012-05-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2013-06-01"]]){
//        if (numberOfYears <= 2) {
//            taxRate = 10;
//        } else if (numberOfYears <= 5) {
//            taxRate = 5;
//        }
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2013-05-31"]] && [acquisitionDate earlierDate:[dateFormat dateFromString:@"2014-06-01"]]){
//        if (numberOfYears <= 2) {
//            taxRate = 15;
//        } else if (numberOfYears <= 5) {
//            taxRate = 10;
//        }
//    } else if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2014-05-31"]]){
//        if (numberOfYears <= 5) {
//            taxRate = 30;
//        } else {
//            taxRate = 5;
//        }
//    }
    if ([acquisitionDate laterDate:[dateFormat dateFromString:@"2014-01-01"]]) {
        if (numberOfYears < 2) {
            taxRate = 30;
        } else if (numberOfYears < 3) {
            taxRate = 30;
        } else if (numberOfYears < 4) {
            taxRate = 30;
        } else if (numberOfYears < 5) {
            taxRate = 30;
        } else {
            taxRate = 5;
        }
    }

}

- (IBAction)didTapReset:(id)sender {
    self.disposalPriceTF.text = @"";
    self.saleCommissionTF.text = @"";
    self.legalCostsTF.text = @"";
    self.renovationImprovementTF.text = @"";
    self.netDisposalPriceTF.text = @"";
    
    self.acquisitionPriceTF.text = @"";
    self.purchaseCommisionTF.text = @"";
    self.legalCostsStampDutyTF.text = @"";
    self.otherCostsIncurredTF.text = @"";
    self.netAcquisitionPriceTF.text = @"";
    
    self.gainsLossTF.text = @"";
    self.dateOfAcquizition.text = @"";
    self.dateOfDisposalTF.text = @"";
    self.numberOfYearHeldTF.text = @"";
    self.statusOfTaxPayerTF.text = @"";
    self.taxRateTF.text = @"";
    self.taxPayable.text = @"";
}

- (void) calculateNumberOfYearHeld
{
    if (self.dateOfDisposalTF.text.length == 0 || self.dateOfAcquizition.text.length == 0){
        return;
    }
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    disposalDate = [dateFormat dateFromString:self.dateOfDisposalTF.text];
    acquisitionDate = [dateFormat dateFromString:self.dateOfAcquizition.text];
    
    if ([disposalDate compare:acquisitionDate] == NSOrderedAscending) {
        [QMAlert showAlertWithMessage:@"Opps! there is something wrong. please input valid dates." actionSuccess:NO inViewController:self];
        return;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [gregorian components:units fromDate:acquisitionDate toDate:disposalDate options:0];
    numberOfYears = [components year];
    CGFloat numberOfMonths = [components month];
    CGFloat numberOfDays = [components day];
    numberOfYears += numberOfMonths / 12.0f + numberOfDays/365.0f;
    
    self.numberOfYearHeldTF.text = [NSString stringWithFormat:@"%.3f", numberOfYears];
}

- (void) updateDateOfDisposal: (NSString*) date
{
    self.dateOfDisposalTF.text = date;
    [self calculateNumberOfYearHeld];
}

- (void) updateDateOfAcquisition: (NSString*) date
{
    self.dateOfAcquizition.text = date;
    [self calculateNumberOfYearHeld];
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
        
        NSNumber* tag = [NSNumber numberWithInteger:textField.tag];
        if ([@[@(0), @(1), @(2), @(3),@(5), @(6), @(7), @(8)] containsObject:tag]){
            double netDisposalPrice = 0, netAcquisitionPrice = 0;
            if ([@[@(0), @(1), @(2), @(3)] containsObject:tag]){
                netDisposalPrice = [self calculateNetDisposalPrice];
                self.netDisposalPriceTF.text = [NSString stringWithFormat:@"%.2f", netDisposalPrice];
                [self applyCommaToTextField:self.netDisposalPriceTF];
            }
            if ([@[@(5), @(6), @(7), @(8)] containsObject:tag]){
                netAcquisitionPrice = [self calculateNetAcquisitionPrice];
                self.netAcquisitionPriceTF.text = [NSString stringWithFormat:@"%.2f", netAcquisitionPrice];
                [self applyCommaToTextField:self.netAcquisitionPriceTF];
            }
            netDisposalPrice = [self getActualNumber:self.netDisposalPriceTF.text];
            netAcquisitionPrice = [self getActualNumber:self.netAcquisitionPriceTF.text];
            double gainsLoss = netDisposalPrice - netAcquisitionPrice;
            self.gainsLossTF.text = [NSString stringWithFormat:@"%.2f", gainsLoss];
            [self applyCommaToTextField:self.gainsLossTF];
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    } else if (section == 1) {
        return 5;
    } else if (section == 2) {
        return 5;
    } else if (section == 3) {
        return 2;
    } else if (section == 4) {
        return 1;
    }

    return 0;
}

#pragma mark - TextField delegate
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 11){
        [self showCalendar: @"Date of Disposal"];
    } else if (textField.tag == 12) {
        [self showCalendar: @"Date of Acquisition"];
    } else {
        return YES;
    }
    
    return NO;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    if (indexPath.section == 2 && indexPath.row == 4) {
        [ActionSheetStringPicker showPickerWithTitle:@"Status of Taxpayer"
                                                rows:self.statusOfTaxPayerArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               self.statusOfTaxPayerTF.text = selectedValue;
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.statusOfTaxPayerTF];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
