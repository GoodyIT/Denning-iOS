//
//  AddBillViewController.m
//  Denning
//
//  Created by DenningIT on 11/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddBillViewController.h"
#import "FloatingTextCell.h"
#import "AddLastOneButtonCell.h"
#import "AddLastTwoButtonsCell.h"
#import "SimpleMatterViewController.h"
#import "ListOfMatterViewController.h"
#import "PresetBillViewController.h"
#import "QuotationGetListViewController.h"
#import "AddReceiptViewController.h"
#import "TaxInvoiceSelectionViewController.h"
#import "TaxBillContactViewController.h"
#import "AddReceiptViewController.h"

@interface AddBillViewController ()< UITableViewDelegate, UITableViewDataSource, ContactListWithDescSelectionDelegate, UITextFieldDelegate, SWTableViewCellDelegate>
{
    NSString *titleOfList;
    NSString* nameOfField;
    NSURL *selectedDocument;
    __block NSString *isRental;
    __block NSString* issueToFirstCode;
    NSString* selectedMatterCode, *selectedPresetCode;
    __block BOOL isLoading;
    __block BOOL isSaved;
    __block BOOL isCalcDone;
    
    NSInteger selectedRow;
    CGPoint originalContentOffset;
    CGRect originalFrame;
}

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSArray *headers;

@property (nonatomic, strong) TaxInvoiceCalcModel* taxModel;
@property (strong, nonatomic) NSIndexPath* textFieldIndexPath;
@property (strong, nonatomic)
NSMutableDictionary* keyValue;

@end

@implementation AddBillViewController

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
                      @[@[@"Convert Quotation", @""], @[@"Bill No (System Auto-assinged)", @""], @[@"File No.", @""], @[@"Matter", @""], @[@"Bill to", @""], @[@"Preset Code", @""], @[@"Price", @""], @[@"Loan", @""], @[@"Month", @""], @[@"Rental", @""], @[@"Calculate", @""]],
                      @[@[@"Professional Fees", @""], @[@"Disb. with GST", @""], @[@"Disbursements", @""], @[@"GST", @""], @[@"Total.", @""], @[@"Save & View & Issue Receipt", @""]
                        ],
                      ];
    _contents = [temp mutableCopy];
    if (_model != nil) {
        isSaved = YES;
        isRental = _model.isRental;
        selectedMatterCode = _model.matter.matterCode;
        selectedPresetCode = _model.presetCode.billCode;
        _taxModel = _model.analysis;
        NSArray* temp = @[
                          @[@[@"Convert Quotation", _model.relatedDocumentNo], @[@"Bill No (System Auto-assinged)", @""], @[@"File No.", _model.fileNo], @[@"Matter", _model.matter.matterCode], @[@"Bill to", _model.issueToName], @[@"Preset Code", _model.presetCode.billCode], @[@"Price", _model.spaPrice], @[@"Loan", _model.spaLoan], @[@"Month", _model.rentalMonth], @[@"Rental", _model.rentalPrice]],
                          @[@[@"Professional Fees", _model.analysis.decFees], @[@"Disb. with GST", _model.analysis.decDisbGST], @[@"Disbursements", _model.analysis.decDisb], @[@"GST", _model.analysis.decGST], @[@"Total.", _model.analysis.decTotal], @[@"Save & View & Issue Receipt", @""]
                            ],
                          ];
        _contents = [temp mutableCopy];
    }
    
    _headers = @[@"Bill Details", @"Bill Analysis"
                 ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    CGPoint updatedContentOffset = CGPointMake(self.tableView.contentOffset.x, scrollOffsetY+50);
    
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

- (NSDictionary*) buildParam {
    NSMutableDictionary* data = [NSMutableDictionary new];
    [data addEntriesFromDictionary:@{@"issueDate": [DIHelpers todayWithTime]}];
    if (![_contents[0][2][1] isEqualToString: _model.fileNo]) {
        [data addEntriesFromDictionary:@{@"fileNo": _contents[0][2][1]}];
    }
    [data addEntriesFromDictionary:@{@"isRental": isRental}];
    //    if (![isRental isEqualToString: _model.isRental]) {
    //        [data addEntriesFromDictionary:@{@"isRental": isRental}];
    //    }
    //    if (![issueTo1stCode isEqualToString: _model.fileNo]) {
    //        [data addEntriesFromDictionary:@{@"fileNo": _contents[0][2][1]}];
    //    }
    if (![_contents[0][4][1] isEqualToString: _model.issueToName]) {
        [data addEntriesFromDictionary:@{@"issueToName": _contents[0][4][1]}];
    }
    if (![selectedMatterCode isEqualToString: _model.matter.matterCode]) {
        [data addEntriesFromDictionary:@{@"matter": @{
                                                 @"code": selectedMatterCode
                                                 }}];
    }
    if (![selectedPresetCode isEqualToString: _model.presetCode.billCode]) {
        [data addEntriesFromDictionary:@{@"presetCode": @{
                                                 @"code": selectedPresetCode
                                                 }}];
    }
    if (![_contents[0][0][1] isEqualToString: _model.relatedDocumentNo]) {
        [data addEntriesFromDictionary:@{@"relatedDocumentNo": _contents[0][0][1]}];
    }
    if (![_contents[0][6][1] isEqualToString: _model.spaPrice]) {
        [data addEntriesFromDictionary:@{@"spaPrice": [self getActualNumber: [self getValidValue:_contents[0][6][1]]]}];
    }
    if (![_contents[0][7][1] isEqualToString: _model.spaLoan]) {
        [data addEntriesFromDictionary:@{@"spaLoan": [self getActualNumber: [self getValidValue:_contents[0][7][1]]]}];
    }
    if (![_contents[0][8][1] isEqualToString: _model.rentalMonth]) {
        [data addEntriesFromDictionary:@{@"rentalMonth": [self getActualNumber: [self getValidValue:_contents[0][8][1]]]}];
    }
    if (![_contents[0][9][1] isEqualToString: _model.rentalPrice]) {
        [data addEntriesFromDictionary:@{@"rentalPrice": [self getActualNumber: [self getValidValue:_contents[0][9][1]]]}];
    }
    
    return data;
}

- (IBAction)saveBill:(id)sender {
    if (((NSString*)_contents[0][2][1]).length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the file no." actionSuccess:NO inViewController:self];
        return;
    }
    
    if (((NSString*)_contents[0][4][1]).length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the bill to." actionSuccess:NO inViewController:self];
        return;
    }
    
    if (selectedPresetCode.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the preset." actionSuccess:NO inViewController:self];
        return;
    }
    
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] saveBillorQuotationWithParams:[self buildParam] inURL:TAXINVOICE_SAVE_URL WithCompletion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        self->isCalcDone = YES;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully saved" duration:1.0];
            self->isSaved = YES;
            [self updateWholeData:result];
            
        } else {
            [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) registerNib {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    
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
    
    [self replaceContentForSection:0 InRow:1 withValue:documentNo];
    
    _taxModel = [TaxInvoiceCalcModel getTaxInvoiceCalcFromResponse:[result objectForKeyNotNull:@"analysis"]];
    
    [self updateBelowViewWithData];
}

- (void) updateBelowViewWithData{
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
    
    if (!value) {
        value = @"";
    }
    
    if (value.length == 0) {
        return @"0";
    }
    else {
        return [value stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    
    return value;
}

- (void) calcTax {
    if (selectedPresetCode.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select preset" actionSuccess:NO inViewController:self];
        return;
    }
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

- (void) viewTaxInvoice {
    if (!isSaved) {
        [QMAlert showAlertWithMessage:@"Please save your quotaion first to view" actionSuccess:NO inViewController:self];
        
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", [DataManager sharedManager].user.serverAPI, REPORT_VIEWER_PDF_TAXINVOICE_URL, _contents[0][1][1]];
    NSURL *url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    [self viewDocument:url withCompletion:^(NSURL *filePath) {
         selectedDocument = filePath;
    }];
}

- (void) gotoReceipt {
    if (!isSaved) {
        [QMAlert showAlertWithMessage:@"Please save the invoice first" actionSuccess:NO inViewController:self];
        return;
    }
    
    if (isLoading) return;
    isLoading = YES;
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:RECEIPT_FROM_TAXINVOICE];
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
    
    if (indexPath.section == 0 && indexPath.row == 10) {
        AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
        [cell.calculateBtn setTitle: _contents[0][10][0] forState:UIControlStateNormal];
        cell.calculateHandler = ^{
            [self calcTax];
        };
        return cell;
    }
    
    if (indexPath.section == 1 && indexPath.row == 5) {
        AddLastTwoButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastTwoButtonsCell cellIdentifier] forIndexPath:indexPath];
        cell.viewHandler = ^{
            if (!isSaved) {
                [QMAlert showAlertWithMessage:@"Please save your bill first to view" actionSuccess:NO inViewController:self];
                
                return;
            }
        };
        cell.saveHandler = ^{
            [self saveBill:nil];
        };
        cell.viewHandler = ^{
            [self viewTaxInvoice];
        };
        
        [cell.lastBtn setTitle:@"Issue Receipt" forState:UIControlStateNormal];
        cell.convertHandler = ^{
            [self gotoReceipt];
        };
        return cell;
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
    
    cell.floatingTextField.inputAccessoryView = accessoryView;
    cell.floatingTextField.tag = indexPath.section * 10 + indexPath.row;
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.floatingTextField.userInteractionEnabled = NO;
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3  || indexPath.row == 4  || indexPath.row == 5) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.floatingTextField.userInteractionEnabled = NO;
        }
        cell.hidden = NO;
        if ([isRental integerValue] == 0) {
            if (indexPath.row == 6 || indexPath.row == 7) {
                cell.hidden = NO;
                cell.floatingTextField.keyboardType = UIKeyboardTypeDecimalPad;
                cell.floatingTextField.delegate = self;
            }
        } else {
            if (indexPath.row == 9 || indexPath.row == 8) {
                cell.hidden = YES;
                cell.floatingTextField.keyboardType = UIKeyboardTypeDecimalPad;
                cell.floatingTextField.delegate = self;
            }
        }
        if (((NSString*)_contents[0][1][1]).length > 0){
            if (indexPath.row >= 6 && indexPath.row <= 9) {
                cell.floatingTextField.userInteractionEnabled = NO;
            }
        } else {
            if (indexPath.row >= 6 && indexPath.row <= 9) {
                cell.floatingTextField.userInteractionEnabled = YES;
            }
        }
    } else {
        cell.floatingTextField.userInteractionEnabled = NO;
        if (indexPath.row == 4) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)handleTap {
    [self.view endEditing:YES];
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
    if (textField.tag > 5 && textField.tag < 10) {
        _textFieldIndexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
        return NO;
    }
     return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length > 14) {
        return NO;
    }
    
    string = string.uppercaseString;
    if (textField.tag == 6 || textField.tag == 7 || textField.tag == 8 || textField.tag == 9) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [DIHelpers formatDecimal:text];
        return NO;
    }
    return YES;
}

#pragma mark - UITableView Datasource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && (indexPath.row == 7 || indexPath.row == 6)) {
        if ([isRental integerValue] == 0) {
            return 60;
        } else {
            return 0;
        }
    } else if (indexPath.section == 0 && (indexPath.row == 9 || indexPath.row == 8)) {
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
        if (indexPath.row == 0) {
            selectedRow = indexPath.row;
            [self performSegueWithIdentifier:kQuotationSegue sender:QUOTATION_GET_LIST_URL];
        }
        if (((NSString*)_contents[0][0][1]).length == 0) {
            if (indexPath.row == 2) {
                [self performSegueWithIdentifier:kSimpleMatterSegue sender:MATTERSIMPLE_GET_URL];
            } else if (indexPath.row == 3) {
//                [self performSegueWithIdentifier:kMatterCodeSegue sender:MATTER_LIST_GET_URL];
            }
        } else {
            if (indexPath.row == 3) {
                [self performSegueWithIdentifier:kMatterCodeSegue sender:MATTER_LIST_GET_URL];
            }
        }
        if (indexPath.row == 4) {
            if (((NSString*)_contents[0][2][1]).length != 0) {
                [self performSegueWithIdentifier:kTaxBillContactSegue sender:_contents[0][2][1]];
            }
        }
        if (indexPath.row == 5) {
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
        for (int j = 0; j < [_contents[i] count]; j++) {
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
        QuotationGetListViewController* quotationVC = segue.destinationViewController;
        quotationVC.updateHandler = ^(QuotationModel* model){
            self->isRental = model.isRental;
            _taxModel = model.analysis;
            
            [self replaceContentForSection:0 InRow:0 withValue:model.documentNo];
            [self replaceContentForSection:0 InRow:2 withValue:model.fileNo];
            [self replaceContentForSection:0 InRow:3 withValue:model.matter.matterDescription];
            [self replaceContentForSection:0 InRow:4 withValue:model.issueToName];
            [self replaceContentForSection:0 InRow:5 withValue:model.presetCode.descriptionValue];
            [self replaceContentForSection:0 InRow:6 withValue:model.spaPrice];
            [self replaceContentForSection:0 InRow:7 withValue:model.spaLoan];
            [self replaceContentForSection:0 InRow:8 withValue:model.rentalMonth];
            [self replaceContentForSection:0 InRow:9 withValue:model.rentalPrice];
            
            issueToFirstCode = model.issueTo1stCode;
            selectedMatterCode = model.matter.matterCode;
            selectedPresetCode = model.presetCode.codeValue;
        };
    }
    
    if ([segue.identifier isEqualToString:kSimpleMatterSegue]) {
        SimpleMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterSimple *model) {
            self->isRental = model.matter.isRental;
            [self replaceContentForSection:0 InRow:2 withValue:model.systemNo];
            [self replaceContentForSection:0 InRow:3 withValue:model.matter.matterDescription];
            [self replaceContentForSection:0 InRow:5 withValue:model.presetBill.strDescription];
            [self replaceContentForSection:0 InRow:6 withValue:model.spaPrice];
            [self replaceContentForSection:0 InRow:7 withValue:model.spaLoan];
            [self replaceContentForSection:0 InRow:8 withValue:model.rentalMonth];
            [self replaceContentForSection:0 InRow:9 withValue:model.rentalPrice];
            
            selectedMatterCode = model.matter.matterCode;
            selectedPresetCode = model.presetBill.codeValue;
            if (model.partyGroupArray.count > 0) {
                PartyGroupModel* partyGroup = model.partyGroupArray[0];
                issueToFirstCode = ((ClientModel*)partyGroup.partyArray[0]).clientCode;
                
                NSString *issueToName = @"";
                
                for(ClientModel* party in partyGroup.partyArray) {
                    issueToName = [NSString stringWithFormat:@"%@ %@ ", issueToName, party.name];
                }
                
                [self replaceContentForSection:0 InRow:4 withValue:issueToName];
            }
        };
    }
    
    if ([segue.identifier isEqualToString:kMatterCodeSegue]) {
        ListOfMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterCodeModel *model) {
            [self replaceContentForSection:0 InRow:3 withValue:model.matterDescription];
            isRental = model.isRental;
            selectedMatterCode = model.matterCode;
        };
        
    }
    
    if ([segue.identifier isEqualToString:kPresetBillSegue]) {
        PresetBillViewController* billVC = segue.destinationViewController;
        billVC.updateHandler = ^(PresetBillModel *model) {
            [self replaceContentForSection:0 InRow:5 withValue:model.billDescription];
            selectedPresetCode = model.billCode;
            
        };
    } else if ([segue.identifier isEqualToString:kTaxSelectionSegue]) {
        TaxInvoiceSelectionViewController* vc = segue.destinationViewController;
        vc.taxModel = _taxModel;
        vc.selectedPage = sender;
        vc.titleString = [NSString stringWithFormat:@"Quotation-%@", _contents[0][2][1]];
    } else if ([segue.identifier isEqualToString:kTaxBillContactSegue]) {
        TaxBillContactViewController* vc = segue.destinationViewController;
        vc.filter = sender;
        vc.updateHandler = ^(ClientModel *model) {
            [self replaceContentForSection:0 InRow:4 withValue:model.name];
        };
    } else if ([segue.identifier isEqualToString:kAddReceiptSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        AddReceiptViewController* vc = nav.viewControllers.firstObject;
        vc.model = sender;
    }
}

@end
