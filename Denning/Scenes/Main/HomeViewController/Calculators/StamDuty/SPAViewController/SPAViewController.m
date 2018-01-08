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
@property (weak, nonatomic) IBOutlet UITextField *resultTextField;
@property (weak, nonatomic) IBOutlet UILabel *relationshipLabel;
@property (strong, nonatomic) NSArray* relationsArray;
@property (weak, nonatomic) IBOutlet UITextField *legalCostTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalTextField;

@end

@implementation SPAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
}

- (void) prepareUI {
    self.relationsArray = [NSArray arrayWithObjects:@"Seller-Purchaser (100%)", @"Husband-wife (0%)", @"Parents-Child (50%)", @"Grandparent-Grandchild (50%)", @"Trustee-Beneficiary (RM10)", @"Administrator-Beneficiary (+RM10)", @"Trustee-Trustee (RM10)flat", @"No consideration(Gift)100%", @"Others (RM10)", nil];
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    self.priceValueTextField.inputAccessoryView = accessoryView;
    
    [self.resultTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapReset:(id)sender {
    self.priceValueTextField.text = @"";
    self.relationshipLabel.text = @"";
    self.resultTextField.text = @"";
    self.legalCostTextField.text = @"";
}

- (IBAction)didTapCalculate:(id)sender {
    double priceValue = [self getActualNumber:self.priceValueTextField.text];
    if ([self.priceValueTextField.text isEqualToString:@""]){
        [QMAlert showAlertWithMessage:@"Please input the price or market value to calculate stamp duty" actionSuccess:NO inViewController:self];
        return;
    }
    
    if (self.relationshipLabel.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the relationship you want to apply for" actionSuccess:YES inViewController:self];
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
    priceValue = [self getActualNumber:self.priceValueTextField.text];
    
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
    } else if ([self.relationshipLabel.text isEqualToString:@"Administrator-Beneficiary (+RM10)"] || [self.relationshipLabel.text isEqualToString:@"Trustee-Beneficiary (RM10)"] || [self.relationshipLabel.text isEqualToString:@"Trustee-Trustee (RM10)flat"] || [self.relationshipLabel.text isEqualToString:@"Others (RM10)"]) {
        stamDuty = 10;
    } else {
        stamDuty  += 10; // Add RM10
    }
    
    legalCost *= 1;
    self.resultTextField.text = [NSString stringWithFormat:@"%.2f", stamDuty ];
    self.legalCostTextField.text = [NSString stringWithFormat:@"%.2f", legalCost];
    
    [self applyCommaToTextField:self.resultTextField];
    [self applyCommaToTextField:self.legalCostTextField];
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
//
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
//    return 0;
//}

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
