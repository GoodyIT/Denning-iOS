//
//  SharesViewController.m
//  Denning
//
//  Created by Denning IT on 2018-09-17.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import "SharesViewController.h"

@interface SharesViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *saleConsideration;
@property (weak, nonatomic) IBOutlet UITextField *PER;
@property (weak, nonatomic) IBOutlet UITextField *NTA;
@property (weak, nonatomic) IBOutlet UITextField *stamDuty;
@property (weak, nonatomic) IBOutlet UITextField *legalFee;
@property (weak, nonatomic) IBOutlet UITextField *legalFeeLabel;
@property (weak, nonatomic) IBOutlet UITextField *total;

@property (strong, nonatomic) NSMutableDictionary* legalFeeArray;
@property (strong, nonatomic) NSMutableArray* legalFeeLabelArray;

@end

@implementation SharesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareUI {
    self.legalFeeArray = [NSMutableDictionary new];
    self.legalFeeLabelArray = [NSMutableArray new];
    for (int i = 1; i <= 100; i++) {
        NSString* label = [NSString stringWithFormat:@"%d%%", i];
        [self.legalFeeLabelArray addObject:label];
        [self.legalFeeArray addEntriesFromDictionary:@{label: @(i)}];
    }
    
    self.legalFeeLabel.text = @"1%";
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    self.saleConsideration.inputAccessoryView = self.NTA.inputAccessoryView = self.PER.inputAccessoryView = accessoryView;
}

- (void)handleTap {
    [self.view endEditing:YES];
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    
//    return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 3;
//    } else if (section == 1) {
//        return 3;
//    }
//    
//    return 1;
//}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [DIHelpers applyCommaToTextField:textField];
    }
}

- (IBAction)doCalc:(id)sender {
    double highestValue = MAX([[DIHelpers removeCommaFromString:self.saleConsideration.text] doubleValue], [[DIHelpers removeCommaFromString:self.NTA.text] doubleValue]);
    highestValue = MAX(highestValue, [[DIHelpers removeCommaFromString:self.PER.text] doubleValue]);
    double stampDuty = ceil(highestValue / 1000.0f) * 3;
    self.stamDuty.text = [NSString stringWithFormat:@"%.2f", stampDuty];
    double factor = [[self.legalFeeArray valueForKey:self.legalFeeLabel.text] doubleValue];
    double legalFee = (highestValue*factor/100.0f);
    self.legalFee.text = [NSString stringWithFormat:@"%.2f", legalFee];
    self.total.text = [NSString stringWithFormat:@"%.2f", (stampDuty+legalFee)];
}

- (IBAction)doReset:(id)sender {
    self.saleConsideration.text = self.NTA.text = self.PER.text = self.stamDuty.text =
    self.legalFee.text = self.total.text = @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select a option"
                                                rows:self.legalFeeLabelArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               
                                               self.legalFeeLabel.text = selectedValue;
                                               [self doCalc:nil];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"Block Picker Canceled");
                                         }
                                              origin:self.legalFeeLabel];
    }
    
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
