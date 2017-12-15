//
//  ViewQuotation.m
//  Denning
//
//  Created by Denning IT on 2017-12-01.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ViewQuotation.h"
#import "AddBillViewController.h"
#import "AddReceiptViewController.h"
#import "TaxInvoiceSelectionViewController.h"

@interface ViewQuotation ()
<UITextFieldDelegate, SWTableViewCellDelegate>
{
     NSURL* selectedDocument;
    __block BOOL isLoading;
}

@property (weak, nonatomic) IBOutlet SWTableViewCell *quotationNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *fileNoCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *matterCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *quotationToCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *presetCodeCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *priceCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *loanCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *monthCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *rentalCell;

@property (weak, nonatomic) IBOutlet SWTableViewCell *proFeesCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *dsbWithGSTCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *disbCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *GSTCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *totalCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *viewDocCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *taxInvoiceCell;
@property (weak, nonatomic) IBOutlet SWTableViewCell *issueReceiptCell;

@property (weak, nonatomic) IBOutlet UITextField *quotationNo;
@property (weak, nonatomic) IBOutlet UITextField *fileNo;
@property (weak, nonatomic) IBOutlet UITextField *matter;
@property (weak, nonatomic) IBOutlet UITextField *quotationTo;
@property (weak, nonatomic) IBOutlet UITextField *presetCode;
@property (weak, nonatomic) IBOutlet UITextField *price;
@property (weak, nonatomic) IBOutlet UITextField *loan;
@property (weak, nonatomic) IBOutlet UITextField *month;
@property (weak, nonatomic) IBOutlet UITextField *rental;

@property (weak, nonatomic) IBOutlet UITextField *proFees;
@property (weak, nonatomic) IBOutlet UITextField *dsbWithGST;
@property (weak, nonatomic) IBOutlet UITextField *disb;
@property (weak, nonatomic) IBOutlet UITextField *GST;
@property (weak, nonatomic) IBOutlet UITextField *total;



@end

@implementation ViewQuotation

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateData];
}

- (IBAction)dismissScreen:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateData {
    _quotationNo.text = _model.documentNo;
    _fileNo.text = _model.fileNo;
    _matter.text = _model.matter.matterDescription;
    _quotationTo.text = _model.primaryClient;
    _presetCode.text = _model.presetCode.billDescription;
    _price.text = _model.spaPrice;
    _loan.text = _model.spaLoan;
    _month.text = _model.rentalMonth;
    _rental.text = _model.rentalPrice;
    
    _proFees.text = _model.analysis.decFees;
    _dsbWithGST.text = _model.analysis.decDisbGST;
    _disb.text = _model.analysis.decDisb;
    _GST.text = _model.analysis.decGST;
    _total.text = _model.analysis.decTotal;
}

- (IBAction)viewDocument:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", [DataManager sharedManager].user.serverAPI, REPORT_VIEWER_PDF_QUATION_URL, _model.documentNo];
    NSURL *url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    [[DIDocumentManager shared] viewDocument:url inViewController:self withCompletion:^(NSURL *filePath) {
        selectedDocument = filePath;
    }];
}

- (NSDictionary*) buildParam {
    NSDictionary* data = @{
                           @"documentNo":_model.documentNo,
                           @"fileNo": _model.fileNo,
                           @"isRental": _model.isRental,
                           @"issueDate": [DIHelpers todayWithTime],
                           @"issueTo1stCode": @{
                                   @"code": @"0"
                                   },
                           @"issueToName": _model.primaryClient,
                           @"matter": @{
                                   @"code": _model.matter.matterCode
                                   },
                           @"presetCode": @{
                                   @"code": _model.presetCode.billCode
                                   },
                           @"relatedDocumentNo": _model.relatedDocumentNo,
                           @"spaPrice": _model.spaPrice,
                           @"spaLoan": _model.spaLoan,
                           @"rentalMonth": _model.rentalMonth,
                           @"rentalPrice": _model.rentalPrice
                           };
    return data;
}
- (IBAction)gotoTaxInvoice:(id)sender {
    if (isLoading) return;
    isLoading = YES;
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:INVOICE_FROM_QUOTATION];
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivatePostWithURL:url params:[self buildParam] completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
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

- (IBAction)gotoIssueReceipt:(id)sender {
    if (isLoading) return;
    isLoading = YES;
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:RECEIPT_FROM_QUOTATION];
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivatePostWithURL:url params:[self buildParam] completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        self->isLoading = NO;
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            [self performSegueWithIdentifier:kAddReceiptSegue sender:[ReceiptModel getReeipt:result]];
            
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 7;
    }
    return 8;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if  (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return _quotationNoCell;
        }
        if (indexPath.row == 1) {
            return _fileNoCell;
        }
        if (indexPath.row == 2) {
            return _matterCell;
        }
        if (indexPath.row == 3) {
            return _quotationToCell;
        }
        if (indexPath.row == 4) {
            return _presetCodeCell;
        }
        if ([_model.isRental integerValue] == 0) {
            if (indexPath.row == 5) {
                return _priceCell;
            }
            if (indexPath.row == 6) {
                return _loanCell;
            }
        } else {
            if (indexPath.row == 5) {
                return _monthCell;
            }
            if (indexPath.row == 6) {
                return _rentalCell;
            }
        }
        
    } else {
        if (indexPath.row == 0) {
            return _proFeesCell;
        }
        if (indexPath.row == 1) {
            return _dsbWithGSTCell;
        }
        if (indexPath.row == 2) {
            return _disbCell;
        }
        if (indexPath.row == 3) {
            return _GSTCell;
        }
        if (indexPath.row == 4) {
            return _totalCell;
        }
        if (indexPath.row == 5) {
            return _viewDocCell;
        }
        if (indexPath.row == 6) {
            return _taxInvoiceCell;
        }
        if (indexPath.row == 7) {
            return _issueReceiptCell;
        }
    }
    
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row <= 3) {
            [self performSegueWithIdentifier:kTaxSelectionSegue sender:[NSNumber numberWithInteger:indexPath.row]];
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kAddBillSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        AddBillViewController* vc = nav.viewControllers.firstObject;
        vc.model = sender;
    } else if ([segue.identifier isEqualToString:kAddReceiptSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        AddReceiptViewController* vc = nav.viewControllers.firstObject;
        vc.model = sender;
    } else if ([segue.identifier isEqualToString:kTaxSelectionSegue]) {
        TaxInvoiceSelectionViewController* vc = segue.destinationViewController;
        vc.taxModel = _model.analysis;
        vc.titleString = [NSString stringWithFormat:@"Quotation-%@", _model.documentNo];
        vc.selectedPage = sender;
    }
}


@end
