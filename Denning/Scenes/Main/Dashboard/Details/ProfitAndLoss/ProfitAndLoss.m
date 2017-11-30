//
//  ProfitAndLoss.m
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ProfitAndLoss.h"
#import "TwoColumnSecondCell.h"
#import "ProfitLossDetail.h"

@interface ProfitAndLoss ()<UITableViewDelegate, UITableViewDataSource>
{
    __block BOOL isFirstLoading;
    __block BOOL isLoading;
    BOOL initCall;
    BOOL isAppending;
}

@property (strong, nonatomic) ThreeItemModel* profitLoss;
@property (strong, nonatomic) NSNumber* page;
@end

@implementation ProfitAndLoss

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self registerNibs];
    [self getList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareUI
{
    _page = @(1);
    isFirstLoading = YES;
    initCall = YES;
    isAppending = NO;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (void)registerNibs {
    [TwoColumnSecondCell registerForReuseInTableView:self.tableView];
}

- (void) getList{
    if (isLoading) return;
    isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    _url = [@"denningwcf/" stringByAppendingString:_url];
    @weakify(self)
    [[QMNetworkManager sharedManager] getDashboardThreeItmesInURL:_url withCompletion:^(ThreeItemModel * _Nonnull result, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        @strongify(self)
        if (error == nil) {
            _profitLoss = result;
            [self.tableView reloadData];
        }
        else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
        
        self->isLoading = NO;
//        [self performSelector:@selector(clean) withObject:nil afterDelay:1.0];;
    }];
}

- (void) clean {
    isLoading = NO;
    isFirstLoading = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _profitLoss.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemModel *model = _profitLoss.items[indexPath.row];
    
    TwoColumnSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:[TwoColumnSecondCell cellIdentifier] forIndexPath:indexPath];
    
    cell.leftLabel.text = model.label;
    cell.rightLabel.text = [DIHelpers addThousandsSeparatorWithDecimal: model.value];
    if ([model.value floatValue] > 0.0) {
        cell.rightLabel.textColor = [UIColor babyGreen];
    } else {
        cell.rightLabel.textColor = [UIColor redColor];
    }
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kProfitLossDetailSegue sender:_profitLoss.items[indexPath.row].api];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kProfitLossDetailSegue]) {
        ProfitLossDetail* vc = segue.destinationViewController;
        
        vc.url = sender;
    }
}
@end
