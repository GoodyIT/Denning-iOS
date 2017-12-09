//
//  AddQuotationViewController.m
//  Denning
//
//  Created by DenningIT on 11/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddQuotationViewController.h"
#import "FloatingTextCell.h"
#import "AddLastOneButtonCell.h"
#import "SimpleMatterViewController.h"
#import "ListOfMatterViewController.h"
#import "PresetBillViewController.h"
#import "TaxInvoiceSelectionViewController.h"
#import "TaxBillContactViewController.h"
#import "AddLastTwoButtonsCell.h"
#import "AddBillViewController.h"
#import "AddReceiptViewController.h"
#import "DashboardContact.h"

@interface AddQuotationViewController ()<UITableViewDelegate, UITableViewDataSource, ContactListWithDescSelectionDelegate, UITextFieldDelegate, SWTableViewCellDelegate>
{
    NSString *titleOfList;
    NSString* nameOfField;
    NSURL* selectedDocument;
    __block NSString *isRental;
    __block NSString* issueToFirstCode;
    NSString* selectedMatterCode, *selectedPresetCode;
    __block BOOL isLoading;
    __block BOOL isSaved;
    __block BOOL isCalcDone;
    
    CGPoint originalContentOffset;
    CGRect originalFrame;
}

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSArray *headers;
@property (nonatomic, strong) TaxInvoiceCalcModel* taxModel;

@property (strong, nonatomic)
NSMutableDictionary* keyValue;
@property (strong, nonatomic) NSIndexPath* textFieldIndexPath;
@end

@implementation AddQuotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNib];
}
- (void) prepareUI {
    issueToFirstCode = @"";
    selectedPresetCode = selectedMatterCode = @"";
    isRental = @"0";
    self.keyValue = [@{
                       @(0): @(1), @(1):@(0)
                       } mutableCopy];
    NSArray* temp = @[
                      @[@[@"Quotation No (Auto assinged)", @""], @[@"File No.", @""], @[@"Matter", @""], @[@"Quotation to", @""], @[@"Preset Code", @""], @[@"Price", @""], @[@"Loan", @""], @[@"Month", @""], @[@"Rental", @""], @[@"Convert", @""]],
                      @[@[@"Professional Fees", @""], @[@"Disb. with GST", @""], @[@"Disbursements", @""], @[@"GST", @""], @[@"Total.", @""], @[@"Save & Invoice", @""], @[@"Issue Receipt", @""]
                        ],
                      ];
    _contents = [temp mutableCopy];
    
    _headers = @[@"Quotation Details", @"Quotation Analysis"
                 ];
    
    isRental = @"0";
}

- (void)keyboardWillShow:(NSNotification *)notification{
    NSValue* keyboardFrameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    
    CGFloat tableViewHeight = CGRectGetMinY(keyboardFrame) - CGRectGetMinY(self.view.bounds);
    
    originalContentOffset = _tableView.contentOffset;
    originalFrame = _tableView.frame;
    
    // Get the duration of the animation.
    NSValue* animationDurationValue = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:self.textFieldIndexPath];
    CGFloat minCellOffsetY = CGRectGetMaxY(cellRect) - tableViewHeight + 10.0; // Add a small margin below the row
    CGFloat maxCellOffsetY = CGRectGetMinY(cellRect) - 10.0; // Add a small margin above the row
    maxCellOffsetY = MAX(0.0, maxCellOffsetY);
    CGFloat maxContentOffsetY = self.tableView.contentSize.height - tableViewHeight;
    CGFloat scrollOffsetY = self.tableView.contentOffset.y;
    if (scrollOffsetY < minCellOffsetY)
    {
        scrollOffsetY = minCellOffsetY;
    }
    else if (scrollOffsetY > maxCellOffsetY)
    {
        scrollOffsetY = maxCellOffsetY;
    }
    scrollOffsetY = MIN(scrollOffsetY, maxContentOffsetY);
    CGPoint updatedContentOffset = CGPointMake(self.tableView.contentOffset.x, scrollOffsetY);
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.tableView.contentOffset = updatedContentOffset;
                     }
                     completion:^(BOOL finished) {
                         self.tableView.frame = CGRectMake(CGRectGetMinX(self.tableView.frame), CGRectGetMinY(self.tableView.frame),
                                                           CGRectGetWidth(self.tableView.frame), tableViewHeight);
                     }];
}

- (void)keyboardWillHide:(NSNotification *) __unused notification{
    // Get the duration of the animation.
    NSValue *animationDurationValue = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                     }
                     completion:^(BOOL finished) {
                         self.tableView.frame = originalFrame;
                         self.tableView.contentOffset = originalContentOffset;
                         [self.tableView layoutIfNeeded];
                     }
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary*) buildParam {
    NSDictionary* data = @{
                           @"fileNo": _contents[0][1][1],
                           @"isRental": isRental,
                           @"issueDate": [DIHelpers todayWithTime],
                           @"issueTo1stCode": @{
                                   @"code": issueToFirstCode
                                   },
                           @"issueToName": _contents[0][3][1],
                           @"matter": @{
                                   @"code": selectedMatterCode
                                   },
                           @"presetCode": @{
                                   @"code": selectedPresetCode
                                   },
                           @"relatedDocumentNo": [self getValidValue:_contents[0][0][1]],
                           @"spaPrice": [self getValidValue:_contents[0][5][1]],
                           @"spaLoan": [self getValidValue:_contents[0][6][1]],
                           @"rentalMonth": [self getValidValue:_contents[0][7][1]],
                           @"rentalPrice": [self getValidValue:_contents[0][8][1]]
                           };
    return data;
}
- (IBAction)saveQuotaion:(id)sender {
//    if (!_contents[0][1][1]) {
//        [QMAlert showAlertWithMessage:@"Please select the file no." actionSuccess:NO inViewController:self];
//        return;
//    }
    if (selectedPresetCode.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the preset." actionSuccess:NO inViewController:self];
        return;
    }
    
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] saveBillorQuotationWithParams:[self buildParam] inURL:QUOTATION_SAVE_URL WithCompletion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully saved" duration:1.0];
            self->isSaved = YES;
            [self updateWholeData:result];
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) registerNib {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT*2;

    self.tableView.allowMultipleSectionsOpen = YES;
    self.tableView.initialOpenSections = [NSSet setWithObjects:@(0), @(1), nil];
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [FloatingTextCell registerForReuseInTableView:self.tableView];
    [AddLastOneButtonCell registerForReuseInTableView:self.tableView];
    [AddLastTwoButtonsCell registerForReuseInTableView:self.tableView];
   
    [self.tableView registerNib:[UINib nibWithNibName:@"AccordionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kAccordionHeaderViewReuseIdentifier];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contents[section] count];
}

- (void) updateWholeData: (NSDictionary*) result {
    NSString* documentNo = [result valueForKeyNotNull:@"documentNo"];
    
    [self replaceContentForSection:0 InRow:0 withValue:documentNo];
    
    _taxModel = [TaxInvoiceCalcModel getTaxInvoiceCalcFromResponse:[result objectForKeyNotNull:@"analysis"]];
    [self updateBelowViewWithData];
}

- (void) updateBelowViewWithData {
    
    [self replaceContentForSection:1 InRow:0 withValue:_taxModel.decFees];
    [self replaceContentForSection:1 InRow:1 withValue:_taxModel.decDisbGST];
    [self replaceContentForSection:1 InRow:2 withValue:_taxModel.decDisb];
    [self replaceContentForSection:1 InRow:3 withValue:_taxModel.decGST];
    [self replaceContentForSection:1 InRow:4 withValue:_taxModel.decTotal];
    
}

- (NSString*) getValidValue: (NSString*) value
{
    value = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    if ([value isKindOfClass:[NSNumber class]]) {
        value = [((NSNumber*)value) stringValue];
    }
    if (value.length == 0) {
        return @"0";
    }
    else {
        return [value stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    
    return value;
}

- (NSInteger) calcTag: (NSIndexPath*) indexPath {
    NSInteger tag = 0;
    for (int i = 0; i < [_contents count]; i++) {
        if (i < indexPath.section) {
            tag += [_contents[i] count];
        }
    }
    
    tag += indexPath.row;
    
    return tag;
}

- (void) calcTax {
    NSDictionary* data = @{
                           @"isRental": isRental,
                           @"spaPrice": [self getValidValue:_contents[0][5][1]],
                           @"spaLoan": [self getValidValue:_contents[0][6][1]],
                           @"rentalMonth": [self getValidValue:_contents[0][7][1]],
                           @"rentalPrice": [self getValidValue:_contents[0][8][1]],
                           @"presetCode": @{
                                   @"code": selectedPresetCode
                                   }
                           };
    
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] calculateTaxInvoiceWithParams:data withCompletion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            self->isCalcDone = YES;
            [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:2.0];
            _taxModel = [TaxInvoiceCalcModel getTaxInvoiceCalcFromResponse:result];
            [self updateBelowViewWithData];
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:2.0];
        }
    }];
}

- (void) viewQuotation {
    if (!isSaved) {
        [QMAlert showAlertWithMessage:@"Please save your bill to view" actionSuccess:NO inViewController:self];
        
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", [DataManager sharedManager].user.serverAPI, REPORT_VIEWER_PDF_QUATION_URL, _contents[0][0][1]];
    NSURL *url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    [self viewDocument:url withCompletion:^(NSURL *filePath) {
        selectedDocument = filePath;
    }];
}

- (void) gotoInvoice {
    if (!isSaved) {
        [QMAlert showAlertWithMessage:@"Please save the quotation first" actionSuccess:NO inViewController:self];
        return;
    }
    
    if (isLoading) return;
    isLoading = YES;
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:INVOICE_FROM_QUOTATION];
    NSMutableDictionary* data = [@{@"documentNo":_contents[0][0][1]} mutableCopy];
    [data addEntriesFromDictionary:[self buildParam]];
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivatePostWithURL:url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        self->isLoading = NO;
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            [self performSegueWithIdentifier:kAddBillSegue sender:[BillModel getBill:result]];
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}


- (void) gotoReceipt {
    if (!isSaved) {
        [QMAlert showAlertWithMessage:@"Please save the quotation first" actionSuccess:NO inViewController:self];
        return;
    }
    
    if (isLoading) return;
    isLoading = YES;
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:RECEIPT_FROM_QUOTATION];
    NSMutableDictionary* data = [@{@"documentNo":_contents[0][0][1]} mutableCopy];
    [data addEntriesFromDictionary:[self buildParam]];
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivatePostWithURL:url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        self->isLoading = NO;
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            //            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully done" duration:1.0];
            [self performSegueWithIdentifier:kAddReceiptSegue sender:[ReceiptModel getReeipt:result]];
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 9) {
        AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
        [cell.calculateBtn setTitle:@"Calculate"  forState:UIControlStateNormal];
        cell.calculateHandler = ^{
            [self calcTax];
        };
        return cell;
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 5) {
            AddLastTwoButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastTwoButtonsCell cellIdentifier] forIndexPath:indexPath];
            cell.viewHandler = ^{
               
                [self viewQuotation];
            };
            
            cell.saveHandler = ^{
                [self saveQuotaion:nil];
            };
            
            [cell.lastBtn setTitle:@"Convert To Tax Invoice" forState:UIControlStateNormal];
            cell.convertHandler = ^{
                [self gotoInvoice];
            };
           
            return cell;
        } else if (indexPath.row == 6) {
            AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
            [cell.calculateBtn setTitle:@"Issue Receipt"  forState:UIControlStateNormal];
            cell.calculateHandler = ^{
                [self gotoReceipt];
            };
            return cell;
        }
    }
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    
    FloatingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[FloatingTextCell cellIdentifier] forIndexPath:indexPath];
    
    int rows = (int)indexPath.row;
    cell.floatingTextField.placeholder = self.contents[indexPath.section][rows][0];
    cell.floatingTextField.text = [NSString stringWithFormat:@"%@", self.contents[indexPath.section][rows][1]];
    cell.floatingTextField.floatLabelActiveColor = cell.floatingTextField.floatLabelPassiveColor = [UIColor redColor];
    cell.floatingTextField.delegate = self;
    cell.floatingTextField.inputAccessoryView = accessoryView;
    cell.floatingTextField.tag = [self calcTag:indexPath];
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0) {
        if (indexPath.row >= 1 && indexPath.row <= 4) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.floatingTextField.userInteractionEnabled = NO;
        }
        
        cell.hidden = NO;
        if ([isRental integerValue] == 0) {
            if (indexPath.row == 5 || indexPath.row == 6) {
                cell.hidden = NO;
                cell.floatingTextField.keyboardType = UIKeyboardTypeDecimalPad;
            }
        } else {
            if (indexPath.row == 7 || indexPath.row == 8) {
                cell.hidden = YES;
                cell.floatingTextField.keyboardType = UIKeyboardTypeDecimalPad;
            }
        }
        if (((NSString*)_contents[0][2][1]).length > 0){
            if (indexPath.row >= 5 && indexPath.row <= 8) {
                cell.floatingTextField.userInteractionEnabled = NO;
            }
        } else {
            if (indexPath.row >= 5 && indexPath.row <= 8) {
                cell.floatingTextField.userInteractionEnabled = YES;
            }
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 4) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
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
     [self replaceContentForSection:indexPath.section InRow:indexPath.row withValue:@""];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self replaceContentForSection:0 InRow:textField.tag withValue:textField.text];
}

- (NSString*) getActualNumber: (NSString*) formattedNumber
{
    return [formattedNumber stringByReplacingOccurrencesOfString:@"," withString:@""];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 5 || textField.tag == 6 || textField.tag == 7 || textField.tag == 8) {
        _textFieldIndexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
        return YES;
    }
    return NO;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length > 14) {
        return NO;
    }
    if (textField.tag == 5 || textField.tag == 6 || textField.tag == 7 || textField.tag == 8) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        textField.text = [DIHelpers formatDecimal:text];
        return NO;
    }
    
    return YES;
}

#pragma mark - UITableView Datasource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && (indexPath.row == 5 || indexPath.row == 6)) {
        if ([isRental integerValue] == 0) {
            return 60;
        } else {
            return 0;
        }
    } else if (indexPath.section == 0 && (indexPath.row == 7 || indexPath.row == 8)) {
        if ([isRental integerValue] == 0) {
            return 0;
        } else {
            return 60;
        }
    }
    
    if (indexPath.section == 1 && indexPath.row == 5) {
        return 120;
    }
    
    return 60.0f;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kDefaultAccordionHeaderViewHeight;
}

- (void)reloadHeaders {
    for (NSInteger i = 0; i < [self numberOfSectionsInTableView:self.tableView]; i++) {
        AccordionHeaderView *headerView = (AccordionHeaderView *)[self.tableView headerViewForSection:i];
        if ([self.keyValue[[NSNumber numberWithInteger:i]] integerValue] == 0) {
            [UIView animateWithDuration:0.1f animations:^{
                
                headerView.expandImage.image = [UIImage imageNamed:@"expandableImage"];
                
            } completion:nil];
        } else {
            [UIView animateWithDuration:0.1f animations:^{
                
                headerView.expandImage.image = [UIImage imageNamed:@"expandableImage_reverse"];
                
            } completion:nil];
        }
    }
}

- (AccordionHeaderView*) updateCustomSectionHeaderInSection:(NSInteger) section withTableView:(UITableView*) tableView {
    AccordionHeaderView* headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kAccordionHeaderViewReuseIdentifier];
    headerView.headerTitle.text = self.headers[section];
    
    if ([self.keyValue[[NSNumber numberWithInteger:section]] integerValue] == 0) {
        [UIView animateWithDuration:0.1f animations:^{
            
            headerView.expandImage.image = [UIImage imageNamed:@"expandableImage"];
            
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            
            headerView.expandImage.image = [UIImage imageNamed:@"expandableImage_reverse"];
            
        } completion:nil];
    }
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self updateCustomSectionHeaderInSection:section withTableView:tableView];
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:kSimpleMatterSegue sender:MATTERSIMPLE_GET_URL];
        }
        if (((NSString*)_contents[0][1][1]).length == 0){
            if (indexPath.row == 2) {
                [self performSegueWithIdentifier:kMatterCodeSegue sender:MATTER_LIST_GET_URL];
            }
            if (indexPath.row == 3) {
                [self performSegueWithIdentifier:kDashboardContactSegue sender:GENERAL_CONTACT_URL];
            }
        } else {
            if (indexPath.row == 3) {
                [self performSegueWithIdentifier:kTaxBillContactSegue sender:_contents[0][1][1]];
            }
        }
       
        if (indexPath.row == 4) {
            [self performSegueWithIdentifier:kPresetBillSegue sender:PRESET_BILL_GET_URL];
        }
    } else {
        if  (isCalcDone && indexPath.row <= 3) {
            [self performSegueWithIdentifier:kTaxSelectionSegue sender:[NSNumber numberWithInteger:indexPath.row]];
        }
    }
}

#pragma mark - <FZAccordionTableViewDelegate> -

- (void)tableView:(FZAccordionTableView *)tableView willOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    self.keyValue[[NSNumber numberWithInteger:section]] = @(1);
    [self reloadHeaders];
}

- (void)tableView:(FZAccordionTableView *)tableView didOpenSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

- (void)tableView:(FZAccordionTableView *)tableView willCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
    self.keyValue[[NSNumber numberWithInteger:section]] = @(0);
    [self reloadHeaders];
}

- (void)tableView:(FZAccordionTableView *)tableView didCloseSection:(NSInteger)section withHeader:(UITableViewHeaderFooterView *)header {
    
}

#pragma mark - ContactListWithDescriptionDelegate
- (void) didSelectListWithDescription:(UIViewController *)listVC name:(NSString*) name withString:(NSString *)description
{
    for (int i = 0; i < self.tableView.numberOfSections; i ++) {
        int rows = (int)[self.tableView numberOfRowsInSection:i];
        if (i == 3) {
            rows += 1;
        }
        for (int j = 0; j < rows; j++) {
            if ([name isEqualToString:_contents[i][j][0]]) {
                [self replaceContentForSection:i InRow:j withValue:description];
            }
        }
    }
}

- (void) replaceContentForSection:(NSInteger) section InRow:(NSInteger) row withValue:(NSString*) value{
    if (value == nil) {
        value = @"";
    }
    
    NSMutableArray *newArray = [NSMutableArray new];
    for (int i = 0; i < self.tableView.numberOfSections; i++) {
        newArray[i] = [NSMutableArray new];
        
        for (int j = 0; j < [_contents[i] count]; j++) {
            newArray[i][j] = [NSMutableArray new];
            [newArray[i][j] addObject:_contents[i][j][0]];
            if (i == section && j == row) {
                [newArray[i][j] addObject:value];
            } else {
                [newArray[i][j] addObject:_contents[i][j][1]];
            }
        }
    }
    
    self.contents = [newArray copy];
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kQuotationSegue]) {
        ListOfMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterCodeModel *model) {
            [self replaceContentForSection:0 InRow:2 withValue:model.matterDescription];
            selectedMatterCode = model.matterCode;
            isRental = model.isRental;
        };
    } else if ([segue.identifier isEqualToString:kSimpleMatterSegue]) {
        SimpleMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterSimple *model) {
            self->isRental = model.matter.isRental;
            if (model.partyGroupArray.count > 0) {
                PartyGroupModel* partyGroup = model.partyGroupArray[0];
                issueToFirstCode = ((ClientModel*)partyGroup.partyArray[0]).clientCode;
                
                NSString *issueToName = @"";
                
                for(ClientModel* party in partyGroup.partyArray) {
                    issueToName = [NSString stringWithFormat:@"%@ %@ ", issueToName, party.name];
                }
                
                [self replaceContentForSection:0 InRow:3 withValue:issueToName];
            }
            [self replaceContentForSection:0 InRow:1 withValue:model.systemNo];
            [self replaceContentForSection:0 InRow:2 withValue:model.matter.matterDescription];
            [self replaceContentForSection:0 InRow:4 withValue:model.presetBill.strDescription];
            [self replaceContentForSection:0 InRow:5 withValue:model.spaPrice];
            [self replaceContentForSection:0 InRow:6 withValue:model.spaLoan];
            [self replaceContentForSection:0 InRow:7 withValue:model.rentalMonth];
            [self replaceContentForSection:0 InRow:8 withValue:model.rentalPrice];
            
            selectedMatterCode = model.matter.matterCode;
            selectedPresetCode = model.presetBill.codeValue;
        };
    } else if ([segue.identifier isEqualToString:kMatterCodeSegue]) {
        ListOfMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterCodeModel *model) {
            [self replaceContentForSection:0 InRow:2 withValue:model.matterDescription];
            isRental = model.isRental;
            selectedMatterCode = model.matterCode;
        };
        
    } else if ([segue.identifier isEqualToString:kPresetBillSegue]) {
        PresetBillViewController* billVC = segue.destinationViewController;
        billVC.updateHandler = ^(PresetBillModel *model) {
            [self replaceContentForSection:0 InRow:4 withValue:model.billDescription];
            selectedPresetCode = model.billCode;
        };
    } else if ([segue.identifier isEqualToString:kTaxSelectionSegue]) {
        TaxInvoiceSelectionViewController* vc = segue.destinationViewController;
        vc.selectedPage = sender;
        vc.taxModel = _taxModel;
        vc.titleString = [NSString stringWithFormat:@"Quotation-%@", _contents[0][1][1]];
    } else if ([segue.identifier isEqualToString:kTaxBillContactSegue]) {
        TaxBillContactViewController* vc = segue.destinationViewController;
        vc.filter = sender;
        vc.updateHandler = ^(ClientModel *model) {
            [self replaceContentForSection:0 InRow:3 withValue:model.name];
        };
    } else if ([segue.identifier isEqualToString:kAddReceiptSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        AddReceiptViewController* vc = nav.viewControllers.firstObject;
        vc.model = sender;
    } else if ([segue.identifier isEqualToString:kAddBillSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        AddBillViewController* vc = nav.viewControllers.firstObject;
        vc.model = sender;
    } else if ([segue.identifier isEqualToString:kDashboardContactSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        DashboardContact* vc = nav.viewControllers.firstObject;
        vc.url = sender;
        vc.callback = @"callback";
        vc.updateHandler = ^(SearchResultModel *model) {
            [self replaceContentForSection:0 InRow:3 withValue:[model.JsonDesc objectForKey:@"name"]];
        };
    }
}

@end
