//
//  AddReceiptViewController.m
//  Denning
//
//  Created by DenningIT on 18/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddReceiptViewController.h"
#import "ListWithCodeTableViewController.h"
#import "ListWithDescriptionViewController.h"
#import "SimpleMatterViewController.h"
#import "TaxInvoiceListViewController.h"
#import "AccountTypeViewController.h"
#import "SimpleAutocomplete.h"

@interface AddReceiptViewController ()<ContactListWithCodeSelectionDelegate, ContactListWithDescSelectionDelegate, SWTableViewCellDelegate, UITextFieldDelegate>
{
    NSString* titleOfList;
    NSString* nameOfField;
    
    CGFloat autocompleteCellHeight;
    NSString* serverAPI;
    
    NSString* selectedIssuerBankCode;
    NSString* selectedID;
}
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *fileNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *billNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *accountType;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *receivedFrom;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *amount;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *transaction;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *mode;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *issuerBank;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *bankBranch;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *chequeNo;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *checqueAmount;
@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *remarks;

@property (weak, nonatomic) IBOutlet SWTableViewCell *QRCodeCell;

@property (weak, nonatomic) IBOutlet SWTableViewCell *fileNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *billNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *accountTypeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *receivedFromCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *amountCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *transactionCell;

@property (weak, nonatomic) IBOutlet SWTableViewCell *modeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *issuerBankCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *bankBranchCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *chequeNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *chequeAmountCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *remarksCell;

@end

@implementation AddReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareUI {
    autocompleteCellHeight = 58;
    serverAPI = [DataManager sharedManager].user.serverAPI;
    
    self.fileNo.floatLabelActiveColor = self.fileNo.floatLabelPassiveColor = [UIColor redColor];
    self.billNo.floatLabelActiveColor = self.billNo.floatLabelPassiveColor = [UIColor redColor];
    self.accountType.floatLabelActiveColor = self.accountType.floatLabelPassiveColor = [UIColor redColor];
    self.receivedFrom.floatLabelPassiveColor = self.receivedFrom.floatLabelPassiveColor = [UIColor redColor];
    self.amount.floatLabelActiveColor = self.amount.floatLabelPassiveColor = [UIColor redColor];
    self.transaction.floatLabelActiveColor = self.transaction.floatLabelPassiveColor = [UIColor redColor];
    self.mode.floatLabelActiveColor = self.mode.floatLabelPassiveColor = [UIColor redColor];
    self.issuerBank.floatLabelActiveColor = self.issuerBank.floatLabelPassiveColor = [UIColor redColor];
    self.bankBranch.floatLabelActiveColor = self.bankBranch.floatLabelPassiveColor = [UIColor redColor];
    self.chequeNo.floatLabelActiveColor = self.chequeNo.floatLabelPassiveColor = [UIColor redColor];
    self.checqueAmount.floatLabelActiveColor = self.checqueAmount.floatLabelPassiveColor = [UIColor redColor];

    self.remarks.floatLabelActiveColor = self.remarks.floatLabelPassiveColor = [UIColor redColor];
    
    UIToolbar* _accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    _accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    _accessoryView.tintColor = [UIColor babyRed];
    
    _accessoryView.items = @[
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [_accessoryView sizeToFit];
    
    self.fileNo.inputAccessoryView = _accessoryView;
    self.billNo.inputAccessoryView = _accessoryView;
    self.accountType.inputAccessoryView = _accessoryView;
    self.receivedFrom.inputAccessoryView = _accessoryView;
    self.transaction.inputAccessoryView = _accessoryView;
    self.mode.inputAccessoryView = _accessoryView;
    self.issuerBank.inputAccessoryView = _accessoryView;
    self.amount.inputAccessoryView = _accessoryView;
    self.transaction.inputAccessoryView = _accessoryView;
    self.bankBranch.inputAccessoryView = _accessoryView;
    self.chequeNo.inputAccessoryView = _accessoryView;
    self.checqueAmount.inputAccessoryView = _accessoryView;
    self.remarks.inputAccessoryView = _accessoryView;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (IBAction)saveReceipt:(id)sender {
    NSDictionary* data = @{
                           @"accountType": @{
                               @"ID": selectedID
                           },
                           @"amount": self.amount.text,
                           @"description": @"Fees and Disbursements",
                           @"fileNo": self.fileNo.text,
                           @"invoiceNo": self.billNo.text,
                           @"payment": @{
                               @"bankBranch": self.bankBranch.text,
                               @"chequeAmount": self.checqueAmount.text,
                               @"chequeRef": self.chequeNo.text,
                               @"issuerBank": selectedIssuerBankCode,
                               @"mode": self.mode.text
                           },
                           @"receivedForm": self.receivedFrom,
                           @"remarks": self.remarks.text
                           };
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    [[QMNetworkManager sharedManager] saveReceiptWithParams:data WithCompletion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully Saved" duration:1.0];
            
            return;
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.QRCodeCell.leftUtilityButtons = [self leftButtons];
            self.QRCodeCell.delegate = self;
            return self.QRCodeCell;
        } else if (indexPath.row == 1) {
            self.fileNoCell.leftUtilityButtons = [self leftButtons];
            self.fileNoCell.delegate = self;
            return self.fileNoCell;
        } else if (indexPath.row == 2) {
            self.billNoCell.leftUtilityButtons = [self leftButtons];
            self.billNoCell.delegate = self;
            return self.billNoCell;
        } else if (indexPath.row == 3) {
            self.accountTypeCell.leftUtilityButtons = [self leftButtons];
            self.accountTypeCell.delegate = self;
            return self.accountTypeCell;
        } else if (indexPath.row == 4) {
            self.receivedFromCell.leftUtilityButtons = [self leftButtons];
            self.receivedFromCell.delegate = self;
            return self.receivedFromCell;;
        } else if (indexPath.row == 5) {
            return self.amountCell;
        } else if (indexPath.row == 6) {
            return self.transactionCell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            self.modeCell.leftUtilityButtons = [self leftButtons];
            self.modeCell.delegate = self;
            return self.modeCell;
        } else if (indexPath.row == 1) {
            self.issuerBankCell.leftUtilityButtons = [self leftButtons];
            self.issuerBankCell.delegate = self;
            return self.issuerBankCell;
        } else if (indexPath.row == 2) {
            return self.bankBranchCell;
        } else if (indexPath.row == 3) {
            return self.chequeNoCell;;
        } else if (indexPath.row == 4) {
            return self.chequeAmountCell;
        } else if (indexPath.row == 5) {
            return self.remarksCell;
        }
    }
    
    return nil;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    UIFont *font = [UIFont fontWithName:@"SFUIText-Medium" size:16.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    NSAttributedString* clearString = [[NSAttributedString alloc] initWithString:@"Clear" attributes:attributes];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] attributedTitle:clearString];
    
    return leftUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    [cell hideUtilityButtonsAnimated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.fileNo.text = @"";
        } else if (indexPath.row == 1) {
            self.billNo.text = @"";
        } else if (indexPath.row == 2) {
            self.accountType.text = @"";
        } else if (indexPath.row == 3) {
            self.receivedFrom.text = @"";
        } else if (indexPath.row == 4) {
            self.amount.text = @"";
        } else if (indexPath.row == 5) {
            self.transaction.text = @"";
        }
    } else if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.mode.text = @"";
        } else if (indexPath.row == 1) {
            self.issuerBank.text = @"";
        } else if (indexPath.row == 2) {
            self.bankBranch.text = @"";
        } else if (indexPath.row == 3) {
            self.chequeNo.text = @"";
        } else if (indexPath.row == 4) {
            self.checqueAmount.text = @"";
        } else if (indexPath.row == 5) {
            self.remarks.text = @"";
        }
    }
}

- (void) showPopup: (UIViewController*) vc {
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:vc];
    [STPopupNavigationBar appearance].barTintColor = [UIColor blackColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.containerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    popupController.containerView.layer.shadowOffset = CGSizeMake(4, 4);
    popupController.containerView.layer.shadowOpacity = 1;
    popupController.containerView.layer.shadowRadius = 1.0;
    
    [popupController presentInViewController:self];
}

- (void) showAutocomplete {
    [self.view endEditing:YES];
    
    SimpleAutocomplete *vc = [[UIStoryboard storyboardWithName:@
                                                        "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"SimpleAutocomplete"];
    vc.url = RECEIPT_TRANS_DESC_GET_LIST_URL;
    vc.title = @"";
    vc.updateHandler =  ^(NSString* selectedString) {
        [self didSelectListWithDescription:nil name:nameOfField withString:selectedString];
    };
    
    [self showPopup:vc];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL editable = YES;
    if (textField.tag == 4 || textField.tag == 14) {
        string = string.uppercaseString;
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        text = [text stringByReplacingOccurrencesOfString:@"." withString:@""];
        double number = [text intValue] * 0.01;
        textField.text = [NSString stringWithFormat:@"%.2lf", number];
        editable = NO;
    } else if (textField.tag == 12 || textField.tag == 13 || textField.tag == 15) {
        editable = YES;
    } else {
        editable = NO;
    }
    
    return editable;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 6;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:kSimpleMatterSegue sender:MATTERSIMPLE_GET_URL];
        } else if (indexPath.row == 2) {
            [self performSegueWithIdentifier:kTaxInvoiceSegue sender:RECEIPT_TAX_INVOICE_GET_LIST_URL];
        } else if (indexPath.row == 3) {
            [self performSegueWithIdentifier: kAccountTypeSegue sender:  ACCOUNT_TYPE_GET_LIST_URL];
        } else if (indexPath.row == 6) {
            [self showAutocomplete];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            titleOfList = @"Select Payment";
            nameOfField = @"payment";
            [self performSegueWithIdentifier:kListWithDescriptionSegue sender:ACCOUNT_PAYMENT_MODE_GET_URL];
        } else if (indexPath.row == 1) {
            titleOfList = @"Select Issuer";
            nameOfField = @"issuer";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:ACCOUNT_CHEQUE_ISSUEER_GET_URL];
        } else if (indexPath.row == 2) {
            titleOfList = @"Select Issuer";
            nameOfField = @"issuer";
            [self performSegueWithIdentifier:kListWithCodeSegue sender:ACCOUNT_CHEQUE_ISSUEER_GET_URL];;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ContactListWithCodeSelectionDelegate
- (void) didSelectList:(UIViewController *)listVC name:(NSString*) name withModel:(CodeDescription *)model
{
    if ([name isEqualToString:@"issuer"]) {
        self.issuerBank.text = model.descriptionValue;
        selectedIssuerBankCode = model.codeValue;
    }
}

#pragma mark - ContactListWithDescriptionDelegate
- (void) didSelectListWithDescription:(UIViewController *)listVC name:(NSString*) name withString:(NSString *)description
{
    if ([name isEqualToString:@"payment"]) {
        self.mode.text = description;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kListWithCodeSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        ListWithCodeTableViewController *listCodeVC = navVC.viewControllers.firstObject;
        listCodeVC.delegate = self;
        listCodeVC.titleOfList = titleOfList;
        listCodeVC.name = nameOfField;
        listCodeVC.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kListWithDescriptionSegue]) {
        UINavigationController *navVC =segue.destinationViewController;
        
        ListWithDescriptionViewController *listDescVC = navVC.viewControllers.firstObject;
        listDescVC.contactDelegate = self;
        listDescVC.titleOfList = titleOfList;
        listDescVC.name = nameOfField;
        listDescVC.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kSimpleMatterSegue]) {
        SimpleMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterSimple *model) {
            
            self.fileNo.text = model.systemNo;
        };
    }
    
    if ([segue.identifier isEqualToString:kTaxInvoiceSegue]) {
        TaxInvoiceListViewController* vc = segue.destinationViewController;
        vc.updateHandler = ^(TaxModel *model) {
            self.billNo.text = model.documentNo;
        };
    }
    
    if ([segue.identifier isEqualToString:kAccountTypeSegue]) {
        AccountTypeViewController* vc = segue.destinationViewController;
        vc.updateHandler = ^(AccountTypeModel *model) {
            self.accountType.text = model.shortDescription;
            selectedID = model.ID;
        };
    }
}


@end
