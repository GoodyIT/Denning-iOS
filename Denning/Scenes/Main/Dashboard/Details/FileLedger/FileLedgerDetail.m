//
//  FileLedgerDetail.m
//  Denning
//
//  Created by Ho Thong Mee on 14/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileLedgerDetail.h"
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "NewLedgerDetailCell.h"
#import "TransactionDetail.h"

@interface FileLedgerDetail ()<HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSString* _url;
    NSInteger selectedIndex;
    NSString *curTopFilter, *curBalanceFilter, *baseUrl;
    __block BOOL isLoading;
}
@property (weak, nonatomic) IBOutlet UILabel *ledgerBalanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *fileNo;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UISegmentedControl *topFilterSegmented;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (nonatomic, strong) NSMutableArray* filterTitleArray;
@property (nonatomic, strong) NSArray* arrayOfFilter;
@property (nonatomic, strong) NSArray<LedgerDetailModel*>* listOfLedgers;
@property (strong, nonatomic) NSArray<LedgerDetailModel*>* listOfSelectedLedgers;
@end

@implementation FileLedgerDetail

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self parseUrl];
    [self displayTitleAndFooter];
    [self prepareUI];
    [self loadLedgersWithCompletion:^{
        [self registerNibs];
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void) parseUrl {
    NSRange range =  [_url rangeOfString:@"/" options:NSBackwardsSearch];
    baseUrl = [_url substringToIndex:range.location];
    curBalanceFilter = [_url substringFromIndex:range.location+1];
}

- (void) displayTitleAndFooter {
    NSMutableArray *items = [[_model.accountNo componentsSeparatedByString:@"/"] mutableCopy];
    
    if (items.count == 2) {
        _fileNo.text = items[0];
    } else {
        _fileNo.text = _model.accountNo;
    }
    _fileNo.text = _model.accountNo;
    _fileName.text = _model.accountName;
    if ([_model.credit floatValue] == 0) {
        _ledgerBalanceLabel.text = _model.debit;
    } else {
        _ledgerBalanceLabel.text = _model.credit;
    }
}

- (void) prepareUI {
    _filterTitleArray = [@[@"Client", @"Disbursment", @"FD", @"Advance", @"Other", @"Receivable"] mutableCopy];
    _arrayOfFilter = @[@"client", @"disb", @"fd", @"advance", @"other", @"recv"];
    self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 74, self.view.frame.size.width, 44)];
    self.selectionList.delegate = self;
    self.selectionList.dataSource = self;
    
    self.selectionList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.selectionList.showsEdgeFadeEffect = YES;
    
    self.selectionList.selectionIndicatorColor = [UIColor colorWithHexString:@"FF3B2F"];
    [self.selectionList setTitleColor:[UIColor colorWithHexString:@"FF3B2F"] forState:UIControlStateHighlighted];
    [self.selectionList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-Regular" size:17] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-SemiBold" size:17]  forState:UIControlStateSelected];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-SemiBold" size:17] forState:UIControlStateHighlighted];
    
    [self.view addSubview:self.selectionList];
    self.selectionList.backgroundColor = [UIColor clearColor];
    self.selectionList.selectedButtonIndex = selectedIndex;
    self.selectionList.hidden = NO;
    self.selectionList.selectedButtonIndex = [_filterTitleArray indexOfObject:curBalanceFilter];
}

- (void)registerNibs {
    [NewLedgerDetailCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

- (IBAction)dismissScreen:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)filterForDebitOrCredit:(id)sender {
    NSMutableArray* newArray = [NSMutableArray new];
    if (self.topFilterSegmented.selectedSegmentIndex == 0) {
        self.listOfSelectedLedgers = self.listOfLedgers;
    } else if (self.topFilterSegmented.selectedSegmentIndex == 1) {
        for (LedgerDetailModel* model in self.listOfLedgers) {
            if ([model.isDebit isEqualToString:@"1"]) {
                [newArray addObject:model];
            }
        }
        self.listOfSelectedLedgers = [newArray copy];
    } else {
        for (LedgerDetailModel* model in self.listOfLedgers) {
            if ([model.isDebit isEqualToString:@"0"]) {
                [newArray addObject:model];
            }
        }
        self.listOfSelectedLedgers = [newArray copy];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadLedgersWithCompletion:(void(^)(void)) completion{
    if (isLoading) return;
    isLoading = YES;
    
    _url = [NSString stringWithFormat:@"%@/%@", baseUrl, curBalanceFilter];
    
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self);
    [[QMNetworkManager sharedManager] loadLedgerDetailURL:_url completion:^(NSArray * _Nonnull ledgerDetailModelArray, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = false;
        [SVProgressHUD dismiss];
        if (error == nil) {
            self.listOfSelectedLedgers = ledgerDetailModelArray;
            self.listOfLedgers = ledgerDetailModelArray;
            if (completion != nil) {
                completion();
            }
            [self.tableView reloadData];
            if ([ledgerDetailModelArray count] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                });
            }
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    
    return self.filterTitleArray.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    
    return self.filterTitleArray[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    // update the view for the corresponding index
    curBalanceFilter = _arrayOfFilter[index];
    [self loadLedgersWithCompletion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listOfSelectedLedgers.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:kAccountDetailSegue sender:self.listOfSelectedLedgers[indexPath.row]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewLedgerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[NewLedgerDetailCell cellIdentifier] forIndexPath:indexPath];
    
    [cell configureCellWithLedgerDetailModel:self.listOfSelectedLedgers[indexPath.row]];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kAccountDetailSegue]){
        TransactionDetail* vc = segue.destinationViewController;
        vc.model = sender;
    }
}
@end
