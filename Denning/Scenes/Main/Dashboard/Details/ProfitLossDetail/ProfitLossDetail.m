
//
//  ProfitLossDetail.m
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ProfitLossDetail.h"
#import "TwoColumnSecondCell.h"

@interface ProfitLossDetail ()<UITableViewDelegate, UITableViewDataSource>
{
    __block BOOL isFirstLoading;
    __block BOOL isLoading;
    NSString* curYear, *baseUrl;
}
@property (weak, nonatomic) IBOutlet UILabel *topYear;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ProfitLossDetailModel* model;

@end

@implementation ProfitLossDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self parseUrl];
    [self prepareUI];
    [self registerNibs];
    [self getList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
//    [self.navigationController dismissNotificationPanel];
    [super viewWillDisappear:animated];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) prepareUI
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (void)registerNibs {
    [TwoColumnSecondCell registerForReuseInTableView:self.tableView];
}

- (void) parseUrl {
    NSRange range =  [_url rangeOfString:@"/" options:NSBackwardsSearch];
    baseUrl = [_url substringToIndex:range.location+1];
    curYear = [_url substringFromIndex:range.location+1];
    _topYear.text = curYear;
}

- (void) getList{
    if (isLoading) return;
    isLoading = YES;
    __weak UINavigationController *navigationController = self.navigationController;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    _url = [baseUrl stringByAppendingString:curYear];
    @weakify(self)
    [[QMNetworkManager sharedManager] getProfitLossDetailWithURL:_url withCompletion:^(ProfitLossDetailModel * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        isLoading = NO;
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            _model = result;
            [self.tableView reloadData];
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
    }];
}


- (IBAction)didTapPrev:(id)sender {
    curYear = [NSString stringWithFormat:@"%ld", [curYear integerValue] - 1];
    _topYear.text = curYear;
    [self getList];
}

- (IBAction)didTapNext:(id)sender {
    curYear = [NSString stringWithFormat:@"%ld", [curYear integerValue] + 1];
    _topYear.text = curYear;
    [self getList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TwoColumnSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:[TwoColumnSecondCell cellIdentifier] forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.leftLabel.text = @"Revenue";
        cell.rightLabel.text = [DIHelpers addThousandsSeparatorWithDecimal:_model.revenue];
    } else if (indexPath.row == 1) {
        cell.leftLabel.text = @"Expenses";
        cell.rightLabel.text = [DIHelpers addThousandsSeparatorWithDecimal:_model.expenses];
    } else {
        cell.leftLabel.text = @"Profit/Loss";
        cell.rightLabel.text = [DIHelpers addThousandsSeparatorWithDecimal:_model.profitLoss];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
