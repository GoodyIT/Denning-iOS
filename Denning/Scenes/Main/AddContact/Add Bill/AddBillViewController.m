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

@interface AddBillViewController ()<UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource, ContactListWithDescSelectionDelegate, UITextFieldDelegate, SWTableViewCellDelegate>
{
    NSString *titleOfList;
    NSString* nameOfField;
    NSURL *selectedDocument;
    __block NSString *isRental;
    __block NSNumber* issueToFirstCode;
    NSString* selectedMatterCode, *selectedPresetCode;
    __block BOOL isLoading;
    __block BOOL isSaved;
    
    NSInteger selectedRow;
}

@property (weak, nonatomic) IBOutlet FZAccordionTableView *tableView;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSArray *headers;

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
    issueToFirstCode = @(0);
    isRental = @"0";
    
    self.keyValue = [@{
                       @(0): @(1), @(1):@(0)
                       } mutableCopy];
    NSArray* temp = @[
                      @[@[@"Convert Quotation", @""], @[@"Bill No (System Auto-assinged)", @""], @[@"File No.", @""], @[@"Matter", @""], @[@"Bill to", @""], @[@"Preset Code", @""], @[@"Price", @""], @[@"Loan", @""], @[@"Month", @""], @[@"Rental", @""]],
                      @[@[@"Professional Fees", @""], @[@"Disb. with GST", @""], @[@"Disbursements", @""], @[@"GST", @""], @[@"Total.", @""]
                        ],
                      ];
    _contents = [temp mutableCopy];
    
    _headers = @[@"Bill Details", @"Bill Analysis"
                 ];
    
    isRental = @"0";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveBill:(id)sender {
    NSDictionary* data = @{
                           @"fileNo": _contents[0][2][1],
                           @"isRental": isRental,
                           @"issueDate": [DIHelpers todayWithTime],
                           @"issueTo1stCode": @{
                                   @"code": issueToFirstCode
                                   },
                           @"issueToName": _contents[0][4][1],
                           @"matter": @{
                                   @"code": selectedMatterCode
                                   },
                           @"presetCode": @{
                                   @"code": selectedPresetCode
                                   },
                           @"relatedDocumentNo": _contents[0][0][1],
                           @"spaPrice": [self getActualNumber: [self getValidValue:_contents[0][6][1]]],
                           @"spaLoan": [self getActualNumber:[self getValidValue:_contents[0][7][1]]],
                           @"rentalMonth": [self getValidValue:_contents[0][8][1]],
                           @"rentalPrice": [self getActualNumber:[self getValidValue:_contents[0][9][1]]]
                           };
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] saveBillorQuotationWithParams:data inURL:TAXINVOICE_SAVE_URL WithCompletion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        [navigationController dismissNotificationPanel];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully saved" duration:1.0];
            self->isSaved = YES;
            [self updateWholeData:result];
            
        } else {
            [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
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
    
    [self replaceContentForSection:0 InRow:1 withValue:documentNo];
    
    [self updateBelowViewWithData:[result objectForKeyNotNull:@"analysis"]];
}

- (void) updateBelowViewWithData: (NSDictionary*) result {
    NSString* iFee =  [result objectForKeyNotNull:@"iFee"];
    NSString* iDisbTax = [result objectForKeyNotNull:@"iDisbTax"];
    NSString* iDisbOnly = [result objectForKeyNotNull:@"iDisbOnly"];
    NSString* iGST = [result objectForKeyNotNull:@"iGST"];
    NSString* iTotal = [result objectForKeyNotNull:@"iTotal"];
    
    [self replaceContentForSection:1 InRow:0 withValue:iFee];
    [self replaceContentForSection:1 InRow:1 withValue:iDisbTax];
    [self replaceContentForSection:1 InRow:2 withValue:iDisbOnly];
    [self replaceContentForSection:1 InRow:3 withValue:iGST];
    [self replaceContentForSection:1 InRow:4 withValue:iTotal];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 10) {
        AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
        cell.calculateHandler = ^{
            NSDictionary* data = @{
                                   @"isRental": isRental,
                                   @"spaPrice": [self getValidValue:_contents[0][6][1]],
                                   @"spaLoan": [self getValidValue:_contents[0][7][1]],
                                   @"rentalMonth": [self getValidValue:_contents[0][8][1]],
                                   @"rentalPrice": [self getValidValue:_contents[0][9][1]],
                                   @"presetCode": @{
                                           @"code": _contents[0][5][1]
                                           }
                                   };
            
            if (isLoading) return;
            isLoading = YES;
            [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
            __weak UINavigationController *navigationController = self.navigationController;
            @weakify(self);
            [[QMNetworkManager sharedManager] calculateTaxInvoiceWithParams:data withCompletion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
                
                [navigationController dismissNotificationPanel];
                @strongify(self)
                self->isLoading = NO;
                if (error == nil) {
                    [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:2.0];
                    [self updateBelowViewWithData:result];
                    
                } else {
                    [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:2.0];
                }
                
            }];
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
        cell.convertHandler = ^{
            NSString *urlString = [NSString stringWithFormat:@"%@%@%@", [DataManager sharedManager].user.serverAPI, REPORT_VIEWER_PDF_QUATION_URL, _contents[0][0][1]];
            NSURL *url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[DataManager sharedManager].user.email  forHTTPHeaderField:@"webuser-id"];
            [request setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
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
                if (filePath != nil) {
                    selectedDocument = filePath;
                    [self displayDocument:filePath];
                }
            }];
            [downloadTask resume];
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
    cell.floatingTextField.tag = indexPath.row;
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.floatingTextField.userInteractionEnabled = YES;
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
            }
        } else {
            if (indexPath.row == 9 || indexPath.row == 8) {
                cell.hidden = YES;
                cell.floatingTextField.keyboardType = UIKeyboardTypeDecimalPad;
            }
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

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    string = string.uppercaseString;
    if (textField.tag == 6 || textField.tag == 7 || textField.tag == 8 || textField.tag == 9) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [DIHelpers formatDecimal:text];
    }
    return NO;
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
        if (indexPath.row == 0 || indexPath.row == 4) {
            selectedRow = indexPath.row;
            [self performSegueWithIdentifier:kQuotationSegue sender:QUOTATION_GET_LIST_URL];
        } else if (indexPath.row == 2) {
            [self performSegueWithIdentifier:kSimpleMatterSegue sender:MATTERSIMPLE_GET_URL];
        } else if (indexPath.row == 3) {
            [self performSegueWithIdentifier:kMatterCodeSegue sender:MATTER_LIST_GET_URL];
        } else if (indexPath.row == 5) {
            [self performSegueWithIdentifier:kPresetBillSegue sender:PRESET_BILL_GET_URL];
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
            if (selectedRow == 0) {
               [self replaceContentForSection:0 InRow:0 withValue:model.documentNo];
            } else {
                [self replaceContentForSection:0 InRow:4 withValue:model.issueToName];
            }
            
         //   [self replaceContentForSection:0 InRow:1 withValue:model.documentNo];
        };
    }
    
    if ([segue.identifier isEqualToString:kSimpleMatterSegue]) {
        SimpleMatterViewController* matterVC = segue.destinationViewController;
        matterVC.updateHandler = ^(MatterSimple *model) {
            PartyGroupModel* partyGroup = model.partyGroupArray[0];
            issueToFirstCode = [NSNumber numberWithInteger: [((ClientModel*)partyGroup.partyArray[0]).clientCode integerValue]];
            
            NSString *issueToName = @"";
            
            for (PartyGroupModel* partyGroup in model.partyGroupArray) {
                if (partyGroup.partyArray.count > 0) {
                    ClientModel* party = partyGroup.partyArray[0];
                    issueToName = [NSString stringWithFormat:@"%@ %@ ", issueToName, party.name];
                }
            }

            
            [self replaceContentForSection:0 InRow:2 withValue:model.systemNo];
            
            
            [self replaceContentForSection:0 InRow:4 withValue:issueToName];
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
    }
}

@end
