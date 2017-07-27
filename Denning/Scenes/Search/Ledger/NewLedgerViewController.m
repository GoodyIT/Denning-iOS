//
//  NewLedgerViewController.m
//  Denning
//
//  Created by DenningIT on 19/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "NewLedgerViewController.h"
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "NewLedgerDetailCell.h"
#import "TransactionDetail.h"

@interface NewLedgerViewController ()<HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate, UITableViewDelegate, UITableViewDataSource>
{
    __block BOOL isLoading;
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UILabel *ledgerFileNo;
@property (weak, nonatomic) IBOutlet UILabel *ledgerFileName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *ledgerBalanceLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterForDebitOrCredit;
@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (nonatomic, strong) NSMutableArray* filterTitleArray;
@property (weak, nonatomic) IBOutlet UIView *topContrainer;

@property (strong, nonatomic) NSArray* selectedLedgerDetailArray;
@property (strong, nonatomic) NSArray* originalLedgerDetailArray;

@end

@implementation NewLedgerViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getSelectedIndex];
    
    [self displayTitleAndFooterInfo];
    
    [self loadDetailLedger:selectedIndex withCompletion:^{
        [self prepareUI];
        [self registerNibs];
    }];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadDetailLedger: (NSInteger) index withCompletion:(void(^)(void)) completion {
    if (isLoading) return;
    isLoading = YES;
    LedgerModel* model = self.ledgerModelNew.ledgerModelArray[index];
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self);
    [[QMNetworkManager sharedManager] loadLedgerDetailURL:model.urlDetail completion:^(NSArray * _Nonnull ledgerDetailModelArray, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = false;
        [SVProgressHUD dismiss];
        if (error == nil) {
            self.selectedLedgerDetailArray = ledgerDetailModelArray;
            self.originalLedgerDetailArray = ledgerDetailModelArray;
            if (completion != nil) {
                completion();
            }
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) displayTitleAndFooterInfo {
    self.ledgerFileNo.text = [NSString stringWithFormat:@"(%@)", self.ledgerModelNew.fileNo ];
    self.ledgerFileName.text = [NSString stringWithFormat:@"(%@)", self.ledgerModelNew.fileName];
    
    self.ledgerBalanceLabel.text = ((LedgerModel*)self.ledgerModelNew.ledgerModelArray[selectedIndex]).currentBalance;
}

- (void) updateFooterInfo {
    CGFloat currentBalance = 0;
    for (LedgerDetailModel* model in self.originalLedgerDetailArray) {
        if ([model.isDebit isEqualToString:@"1"]) {
            currentBalance += [[model.amountDR  stringByReplacingOccurrencesOfString:@"," withString:@""] floatValue];
        } else if ([model.isDebit isEqualToString:@"0"]) {
            currentBalance -= [[model.amountCR  stringByReplacingOccurrencesOfString:@"," withString:@""] floatValue];
        }
    }
    self.ledgerBalanceLabel.text = [DIHelpers addThousandsSeparatorWithDecimal:[NSString stringWithFormat:@"%.2lf", currentBalance]];
}

- (void) getSelectedIndex {
    self.filterTitleArray = [NSMutableArray new];
    
    for (NSInteger i = 0; i < self.ledgerModelNew.ledgerModelArray.count; i++) {
        LedgerModel* model = self.ledgerModelNew.ledgerModelArray[i];
        [self.filterTitleArray addObject:model.accountName];
        if ([model.accountName isEqualToString:self.selectedAccountName]) {
            selectedIndex = i;
        }
    }
}

- (void) prepareUI {

  //  self.navigationController.navigationBarHidden = YES;
    
    [self getSelectedIndex];
    
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
}

- (void)registerNibs {
    [NewLedgerDetailCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

- (IBAction)dismissScreen:(id)sender {
 //   self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)filterForDebitOrCredit:(id)sender {
    NSMutableArray* newArray = [NSMutableArray new];
    if (self.filterForDebitOrCredit.selectedSegmentIndex == 0) {
        self.selectedLedgerDetailArray = self.originalLedgerDetailArray;
    } else if (self.filterForDebitOrCredit.selectedSegmentIndex == 1) {
        for (LedgerDetailModel* model in self.originalLedgerDetailArray) {
            if ([model.isDebit isEqualToString:@"1"]) {
                [newArray addObject:model];
            }
        }
        self.selectedLedgerDetailArray = [newArray copy];
    } else {
        for (LedgerDetailModel* model in self.originalLedgerDetailArray) {
            if ([model.isDebit isEqualToString:@"0"]) {
                [newArray addObject:model];
            }
        }
        self.selectedLedgerDetailArray = [newArray copy];
    }
    [self.tableView reloadData];
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
    [self loadDetailLedger:index withCompletion:nil];
    
    selectedIndex = index;
    [self displayTitleAndFooterInfo];
    
    self.filterForDebitOrCredit.selectedSegmentIndex = 0;
    
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectedLedgerDetailArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:kAccountDetailSegue sender:self.selectedLedgerDetailArray[indexPath.row]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewLedgerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[NewLedgerDetailCell cellIdentifier] forIndexPath:indexPath];
    
    [cell configureCellWithLedgerDetailModel:self.selectedLedgerDetailArray[indexPath.row]];
    
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
