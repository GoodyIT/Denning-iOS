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
#import "DetailWithAutocomplete.h"
#import "TaxInvoice.h"
#import "AccountTypeViewController.h"
#import "BankBranchAutoComplete.h"
#import "DashboardContact.h"
#import "TransactionDescViewController.h"
#import "PaymentModeViewController.h"
#import "CodeTransactionAutoComplete.h"

enum RECEIPT_ROWS {
    FILE_NO_ROW,
    BILL_NO_ROW,
    ACCOUNT_TYPE_ROW,
    RECEIVED_FROM_ROW,
    AMOUNT_ROW,
    TRANSACTION_DESC_ROW
};

enum PAYMENT_MODE_ROWS {
    MODE_ROW,
    ISSUER_BANK_ROW,
    BANK_BRANCH_ROW,
    CHEQUE_NO_ROW,
    CHEQUE_AMOUT_ROW,
    REMARKS_ROW
};

@interface AddReceiptViewController ()<ContactListWithCodeSelectionDelegate, SWTableViewCellDelegate, UITextFieldDelegate>
{
    NSString* titleOfList;
    NSString* nameOfField;
    
    CGFloat autocompleteCellHeight;
    NSString* serverAPI;
    
    NSString* selectedIssuerBankCode, *selectedRecievedFromCode, *selectedTransactionCode, *modeCode;
    NSString* selectedID;
    
    __block BOOL isSaved, isLoading;
}

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
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
    selectedID = selectedTransactionCode = selectedIssuerBankCode = selectedRecievedFromCode = @"";
    _fileNo.text = @"";
    
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
    self.bankBranch.inputAccessoryView = _accessoryView;
    self.chequeNo.inputAccessoryView = _accessoryView;
    self.checqueAmount.inputAccessoryView = _accessoryView;
    self.remarks.inputAccessoryView = _accessoryView;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.fileNo.text = _model.fileNo;
    self.billNo.text = _model.invoiceNo;
    self.accountType.text = _model.accountType.descriptionValue;
    _receivedFrom.text = _model.receivedFromName;
//    _transaction.text =
    _mode.text = _model.payment.mode;
    _issuerBank.text = _model.payment.issuerBank;
    _amount.text = _model.amount;
    _bankBranch.text = _model.payment.bankBranch;
    _chequeNo.text = _model.payment.referenceNo;
    _checqueAmount.text = _model.payment.totalAmount;
    _remarks.text = _model.remarks;
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (BOOL) checkValidation {
    
    return YES;
}

- (void) _save {
    if (isSaved) {
        self.saveBtn.enabled = NO;
        return;
    }
    
    if (isLoading) return;
    isLoading = YES;
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self)
    [[QMNetworkManager sharedManager] saveReceiptWithParams:[self buildSaveParam] WithCompletion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        self->isLoading = NO;
        self->isSaved = YES;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully Saved" duration:1.0];
            
            return;
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) _update {
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:RECEIPT_UPDATE_URL];
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    [[QMNetworkManager sharedManager] sendPrivatePutWithURL:url params:[self buildParam] completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully Updated" duration:1.0];
            
            return;
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}

- (NSDictionary*) buildSaveParam {
    return @{
             @"accountType": @{
                     @"ID": selectedID
                     },
             @"amount": self.amount.text,
            @"fileNo": self.fileNo.text,
             @"invoiceNo": self.billNo.text,
             @"payment":@{
                 @"bankBranch": self.bankBranch.text,
                 @"totalAmount": self.checqueAmount.text,
                 @"referenceNo": _chequeNo.text,
                 @"issuerBank": _issuerBank.text,
                 @"mode": _mode.text,
             },
             @"receivedFromName": _receivedFrom.text,
             @"remarks": _remarks.text
         };
}

- (NSDictionary*) buildParam {
    NSMutableDictionary* data = [NSMutableDictionary new];
    if (![selectedID isEqualToString: _model.accountType.ID]) {
        [data addEntriesFromDictionary:@{@"accountType": @{
                                                 @"ID": selectedID
                                                 }}];
    }
    
    if (![_amount.text isEqualToString: _model.amount]) {
        [data addEntriesFromDictionary:@{@"amount": self.amount.text}];
    }
    
    if (![_fileNo.text isEqualToString: _model.fileNo]) {
        [data addEntriesFromDictionary:@{@"fileNo": self.fileNo.text}];
    }
    
    if (![_billNo.text isEqualToString: _model.invoiceNo]) {
        [data addEntriesFromDictionary:@{@"invoiceNo": self.billNo.text}];
    }
    
    NSMutableDictionary* payment = [NSMutableDictionary new];
    if (![_bankBranch.text isEqualToString: _model.payment.bankBranch]) {
        [payment addEntriesFromDictionary:@{@"bankBranch": self.bankBranch.text}];
    }
    
    if (![_checqueAmount.text isEqualToString:_model.payment.totalAmount ]) {
        [payment addEntriesFromDictionary:@{@"totalAmount": self.checqueAmount.text}];
    }
    
    if (![_chequeNo.text isEqualToString:_model.payment.referenceNo]) {
        [payment addEntriesFromDictionary:@{@"referenceNo": _chequeNo.text}];
    }
    
    if (![_issuerBank.text isEqualToString:_model.payment.issuerBank]) {
        [payment addEntriesFromDictionary:@{@"issuerBank": _issuerBank.text}];
    }
    
    if (![_mode.text isEqualToString:_model.payment.mode]) {
        [payment addEntriesFromDictionary:@{@"mode": _mode.text}];
    }
    [data addEntriesFromDictionary:@{@"payment":payment}];
    
    if (![_receivedFrom.text isEqualToString:_model.receivedFromName]) {
        [data addEntriesFromDictionary:@{@"receivedFromName": _receivedFrom.text}];
    }
    
    if (![_remarks.text isEqualToString:_model.remarks]) {
        [data addEntriesFromDictionary:@{@"remarks": _remarks.text}];
    }
    
    return [data copy];
}

- (IBAction)saveReceipt:(id)sender {
    if (![_isUpdate isEqualToString:@"update"]) {
        [self _save];
    } else {
        [QMAlert showConfirmDialog:@"Do you want to update data?" withTitle:@"Alert" inViewController:self completion:^(UIAlertAction * _Nonnull action) {
            if  ([action.title isEqualToString:@"OK"]) {
                [self _update];
            }
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.section == 0) {
       /* if (indexPath.row == 0) {
            self.QRCodeCell.leftUtilityButtons = [self leftButtons];
            self.QRCodeCell.delegate = self;
            return self.QRCodeCell;
        } else*/
        if (indexPath.row == FILE_NO_ROW) {
            self.fileNoCell.leftUtilityButtons = [self leftButtons];
            self.fileNoCell.delegate = self;
            return self.fileNoCell;
        } else if (indexPath.row == BILL_NO_ROW) {
            self.billNoCell.leftUtilityButtons = [self leftButtons];
            self.billNoCell.delegate = self;
            return self.billNoCell;
        } else if (indexPath.row == ACCOUNT_TYPE_ROW) {
            self.accountTypeCell.leftUtilityButtons = [self leftButtons];
            self.accountTypeCell.delegate = self;
            return self.accountTypeCell;
        } else if (indexPath.row == RECEIVED_FROM_ROW) {
            self.receivedFromCell.leftUtilityButtons = [self leftButtons];
            self.receivedFromCell.delegate = self;
            return self.receivedFromCell;;
        } else if (indexPath.row == AMOUNT_ROW) {
            return self.amountCell;
        } else if (indexPath.row == TRANSACTION_DESC_ROW) {
            return self.transactionCell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == MODE_ROW) {
            self.modeCell.leftUtilityButtons = [self leftButtons];
            self.modeCell.delegate = self;
            return self.modeCell;
        } else if (indexPath.row == ISSUER_BANK_ROW) {
            self.issuerBankCell.leftUtilityButtons = [self leftButtons];
            self.issuerBankCell.delegate = self;
            return self.issuerBankCell;
        } else if (indexPath.row == BANK_BRANCH_ROW) {
            return self.bankBranchCell;
        } else if (indexPath.row == CHEQUE_NO_ROW) {
            self.chequeNoCell.delegate = self;
            return self.chequeNoCell;;
        } else if (indexPath.row == CHEQUE_AMOUT_ROW) {
            self.chequeAmountCell.delegate = self;
            return self.chequeAmountCell;
        } else if (indexPath.row == REMARKS_ROW) {
            self.remarksCell.delegate = self;
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
        if (indexPath.row == FILE_NO_ROW) {
            self.fileNo.text = @"";
        } else if (indexPath.row == BILL_NO_ROW) {
            self.billNo.text = @"";
        } else if (indexPath.row == ACCOUNT_TYPE_ROW) {
            self.accountType.text = @"";
        } else if (indexPath.row == RECEIVED_FROM_ROW) {
            self.receivedFrom.text = @"";
        } else if (indexPath.row == AMOUNT_ROW) {
            self.amount.text = @"";
        } else if (indexPath.row == TRANSACTION_DESC_ROW) {
            self.transaction.text = @"";
        }
    } else if (indexPath.section == 0) {
        if (indexPath.row == MODE_ROW) {
            self.mode.text = @"";
        } else if (indexPath.row == ISSUER_BANK_ROW) {
            self.issuerBank.text = @"";
        } else if (indexPath.row == BANK_BRANCH_ROW) {
            self.bankBranch.text = @"";
        } else if (indexPath.row == CHEQUE_NO_ROW) {
            self.chequeNo.text = @"";
        } else if (indexPath.row == CHEQUE_AMOUT_ROW) {
            self.checqueAmount.text = @"";
        } else if (indexPath.row == REMARKS_ROW) {
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

- (void) showBankBranchAutocomplete {
    [self.view endEditing:YES];
    
    BankBranchAutoComplete *vc = [[UIStoryboard storyboardWithName:@
                                   "AddReceipt" bundle:nil] instantiateViewControllerWithIdentifier:@"BankBranchAutoComplete"];
    vc.url = BANK_BRANCH_GET_LIST_URL;
    vc.updateHandler =  ^(BankBranchModel* model) {
        self.bankBranch.text = model.name;
    };
    [self showPopup:vc];
}


- (void) showDetailAutoComplete: (NSString*) url {
    DetailWithAutocomplete *vc = [[UIStoryboard storyboardWithName:@
                                   "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailWithAutocomplete"];
    vc.url = url;
    vc.title = titleOfList;
    vc.updateHandler =  ^(CodeDescription* model) {
        self.issuerBank.text = model.descriptionValue;
        selectedIssuerBankCode = model.codeValue;
    };
    
    [self showPopup:vc];
}

- (void) showTransactionAutoComplete: (NSString*) url {
    CodeTransactionAutoComplete *vc = [[UIStoryboard storyboardWithName:@
                                   "AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"CodeTransactionAutoComplete"];
    vc.url = url;
    vc.title = titleOfList;
    vc.updateHandler =  ^(CodeTransactionDesc* model) {
        self.transaction.text = model.strTransactionDescription;
        selectedTransactionCode = model.codeValue;
    };
    
    [self showPopup:vc];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length > 14) {
        return NO;
    }
    if (textField.tag == 4 || textField.tag == 14) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        textField.text = [DIHelpers formatDecimal:text];
        return NO;
    }
    
    return YES;
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
        if (indexPath.row == FILE_NO_ROW) {
            [self performSegueWithIdentifier:kSimpleMatterSegue sender:MATTERSIMPLE_GET_URL];
        } else if (indexPath.row == BILL_NO_ROW) {
            [self performSegueWithIdentifier:kTaxInvoiceSegue sender:TAXINVOICE_ALL_GET_URL];
        } else if (indexPath.row == ACCOUNT_TYPE_ROW) {
            [self performSegueWithIdentifier: kAccountTypeSegue sender:  ACCOUNT_TYPE_GET_LIST_URL];
        } else if (indexPath.row == RECEIVED_FROM_ROW) {
            [self performSegueWithIdentifier:kContactGetListSegue sender:GENERAL_CONTACT_URL];
        } else if (indexPath.row == TRANSACTION_DESC_ROW) {
            [self showTransactionAutoComplete:TRANSACTION_DESCRIPTION_RECEIPT_GET];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == MODE_ROW) {
            [self performSegueWithIdentifier:kPaymentModeSegue sender:PAYMENT_MODE_GET_URL];
        } else if (indexPath.row == ISSUER_BANK_ROW) {
            titleOfList = @"Select Issuer";
            nameOfField = @"issuer";
//            [self performSegueWithIdentifier:kListWithCodeSegue sender:ACCOUNT_CHEQUE_ISSUEER_GET_URL];
            [self showDetailAutoComplete:ACCOUNT_CHEQUE_ISSUEER_GET_URL];
        } else if (indexPath.row == BANK_BRANCH_ROW) {
            [self showBankBranchAutocomplete];
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
    } else if ([segue.identifier isEqualToString:kSimpleMatterSegue]) {
        SimpleMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterSimple *model) {
            self.fileNo.text = model.systemNo;
        };
    } else if ([segue.identifier isEqualToString:kTaxInvoiceSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        TaxInvoice* vc = nav.viewControllers.firstObject;
        vc.fileNo = _fileNo.text;
        vc.url = sender;
        vc.updateHandler = ^(TaxInvoiceModel *model) {
            self.billNo.text = model.invoiceNo;
            _receivedFrom.text = model.issueToName;
        };
    } else if ([segue.identifier isEqualToString:kAccountTypeSegue]) {
        AccountTypeViewController* vc = segue.destinationViewController;
        vc.updateHandler = ^(AccountTypeModel *model) {
            self.accountType.text = model.shortDescription;
            selectedID = model.ID;
        };
    } else if ([segue.identifier isEqualToString:kContactGetListSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        DashboardContact* vc = nav.viewControllers.firstObject;
        vc.url = sender;
        vc.callback = @"callback";
        vc.updateHandler = ^(SearchResultModel *model) {
            _receivedFrom.text = [model.JsonDesc objectForKey:@"name"];
             selectedRecievedFromCode = [model.JsonDesc objectForKey:@"code"];
        };
    } else if ([segue.identifier isEqualToString:kCodeTransactionDescSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        TransactionDescViewController* vc =  nav.viewControllers.firstObject;
        vc.url = sender;
        vc.updateHandler = ^(CodeTransactionDesc *model) {
            _transaction.text = model.strTransactionDescription;
            selectedTransactionCode = model.codeValue;
        };
    } else if ([segue.identifier isEqualToString:kPaymentModeSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        PaymentModeViewController* vc =  nav.viewControllers.firstObject;
        vc.url = sender;
        vc.updateHandler = ^(PaymentModeModel *model) {
            _mode.text = model.strDescription;
            modeCode = model.codeValue;
        };
    }
}

@end
