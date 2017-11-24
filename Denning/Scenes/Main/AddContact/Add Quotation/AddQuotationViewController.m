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
#import "AddLastTwoButtonsCell.h"
#import "SimpleMatterViewController.h"
#import "ListOfMatterViewController.h"
#import "PresetBillViewController.h"
#import "TaxInvoiceSelectionViewController.h"

@interface AddQuotationViewController ()<UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource, ContactListWithDescSelectionDelegate, UITextFieldDelegate, SWTableViewCellDelegate>
{
    NSString *titleOfList;
    NSString* nameOfField;
    NSURL* selectedDocument;
    __block NSString *isRental;
    __block NSNumber* issueToFirstCode;
    NSString* selectedMatterCode, *selectedPresetCode;
    __block BOOL isLoading;
    __block BOOL isSaved;
    __block BOOL isCalcDone;
}

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSArray *headers;
@property (nonatomic, strong) TaxInvoiceCalcModel* taxModel;

@property (strong, nonatomic)
NSMutableDictionary* keyValue;

@end

@implementation AddQuotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNib];
}
- (void) prepareUI {
    issueToFirstCode = @(0);
    selectedPresetCode = selectedMatterCode = @"";
    isRental = @"0";
    self.keyValue = [@{
                       @(0): @(1), @(1):@(0)
                       } mutableCopy];
    NSArray* temp = @[
                      @[@[@"Quotation No (Auto assinged)", @""], @[@"File No.", @""], @[@"Matter", @""], @[@"Quotation to", @""], @[@"Preset Code", @""], @[@"Price", @""], @[@"Loan", @""], @[@"Month", @""], @[@"Rental", @""]],
                      @[@[@"Professional Fees", @""], @[@"Disb. with GST", @""], @[@"Disbursements", @""], @[@"GST", @""], @[@"Total.", @""]
                        ],
                      ];
    _contents = [temp mutableCopy];
    
    _headers = @[@"Quotation Details", @"Quotation Analysis"
                 ];
    
    isRental = @"0";
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath != nil) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Info"
                                      message:@"Do you want to clear the input"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self replaceContentForSection:indexPath.section InRow:indexPath.row withValue:@""];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveQuotaion:(id)sender {
    if (selectedMatterCode.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the matter." actionSuccess:NO inViewController:self];
        return;
    }
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
                           @"relatedDocumentNo": @"",
                           @"spaPrice": [self getValidValue:_contents[0][5][1]],
                           @"spaLoan": [self getValidValue:_contents[0][6][1]],
                           @"rentalMonth": [self getValidValue:_contents[0][7][1]],
                           @"rentalPrice": [self getValidValue:_contents[0][8][1]]
                           };
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] saveBillorQuotationWithParams:data inURL:QUOTATION_SAVE_URL WithCompletion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
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
    return [self.contents[section] count] + 1;
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

- (void)displayDocument:(NSURL*)document {
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:document];
    documentInteractionController.delegate = self;
    [documentInteractionController presentPreviewAnimated:YES];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controlle
{
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[selectedDocument path] error:&error];
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", [DataManager sharedManager].user.serverAPI, REPORT_VIEWER_PDF_QUATION_URL, _contents[0][0][1]];
    NSURL *url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[DataManager sharedManager].user.email  forHTTPHeaderField:@"webuser-id"];
    [request setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    
    [SVProgressHUD show];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                           inDomain:NSUserDomainMask
                                                                  appropriateForURL:nil
                                                                             create:NO error:nil];
        
        NSString* newPath = [[documentsDirectory absoluteString] stringByAppendingString:[NSString stringWithFormat:@"DenningIT%@/", [DIHelpers randomTime]]];
        if (![FCFileManager isDirectoryItemAtPath:newPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:newPath  withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        return [documentsDirectory URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [SVProgressHUD dismiss];
        if (filePath != nil) {
            selectedDocument = filePath;
            [self displayDocument:filePath];
        }
    }];
    [downloadTask resume];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 9) {
        AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
        cell.calculateHandler = ^{
            [self calcTax];
        };
        return cell;
    }
    
    if (indexPath.section == 1 && indexPath.row == 5) {
        AddLastTwoButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastTwoButtonsCell cellIdentifier] forIndexPath:indexPath];
        cell.viewHandler = ^{
            if (!isSaved) {
                [QMAlert showAlertWithMessage:@"Please save your quotaion first to view" actionSuccess:NO inViewController:self];
                
                return;
            }
            [self viewQuotation];
        };
        cell.saveHandler = ^{
            [self saveQuotaion:nil];
        };
        cell.convertHandler = ^{
            [self performSegueWithIdentifier:kAddReceiptSegue sender:nil];
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
    cell.floatingTextField.delegate = self;
    cell.floatingTextField.inputAccessoryView = accessoryView;
    cell.floatingTextField.tag = [self calcTag:indexPath];
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.floatingTextField.userInteractionEnabled = YES;
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
    }
    
    if (indexPath.section == 1) {
        cell.floatingTextField.userInteractionEnabled = NO;
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

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 5 || textField.tag == 6 || textField.tag == 7 || textField.tag == 8) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        textField.text = [DIHelpers formatDecimal:text];
    }
    
    return NO;
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
        } else if (indexPath.row == 2) {
            [self performSegueWithIdentifier:kMatterCodeSegue sender:MATTER_LIST_GET_URL];
        } else if (indexPath.row == 4) {
            [self performSegueWithIdentifier:kPresetBillSegue sender:PRESET_BILL_GET_URL];
        }
    } else {
        if  (isCalcDone) {
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
            [self replaceContentForSection:0 InRow:2 withValue:model.matterCode];
            isRental = model.isRental;
        };
    } else if ([segue.identifier isEqualToString:kSimpleMatterSegue]) {
        SimpleMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterSimple *model) {
            [self replaceContentForSection:0 InRow:1 withValue:model.systemNo];
            
            if (model.partyGroupArray.count > 0) {
                PartyGroupModel* partyGroup = model.partyGroupArray[0];
                issueToFirstCode = [NSNumber numberWithInteger: [((ClientModel*)partyGroup.partyArray[0]).clientCode integerValue]];
                
                NSString *issueToName = @"";
                
                for(ClientModel* party in partyGroup.partyArray) {
                    issueToName = [NSString stringWithFormat:@"%@ %@ ", issueToName, party.name];
                }
                
                [self replaceContentForSection:0 InRow:3 withValue:issueToName];
            }
            [self replaceContentForSection:0 InRow:4 withValue:model.presetBill.descriptionValue];
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
        vc.listOfTax = @[_taxModel.Fees, _taxModel.DisbGST, _taxModel.Disb, _taxModel.GST];
        vc.selectedPage = sender;
    }
}

@end
