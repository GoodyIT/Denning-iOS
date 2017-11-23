//
//  TaxInvoiceSelectionViewController.m
//  Denning
//
//  Created by Denning IT on 2017-11-23.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TaxInvoiceSelectionViewController.h"
#import "TwoColumnSecondCell.h"

@interface TaxInvoiceSelectionViewController ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

@end

@implementation TaxInvoiceSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) registerNibs {
    [TwoColumnSecondCell registerForReuseInTableView:self.tableView];
}

- (void) prepareUI {
    [self calaTotalPrice];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
    
    // Tying up the segmented control to a scroll view
    HMSegmentedControl *selectionList = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 86, self.view.frame.size.width, 34)];
    selectionList.sectionTitles = @[@"Fees",  @"Disb GST", @"Disb", @"GST"];
    selectionList.selectedSegmentIndex = [self.selectedPage integerValue];
    selectionList.backgroundColor = [UIColor blackColor];
    selectionList.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    selectionList.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"SFUIText-Regular" size:17]};
    selectionList.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"FF3B2F"], NSFontAttributeName: [UIFont fontWithName:@"SFUIText-SemiBold" size:17]};
    selectionList.selectionIndicatorColor = [UIColor colorWithHexString:@"FF3B2F"];
    selectionList.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    [selectionList addTarget:self action:@selector(topFilterChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:selectionList];
}

- (void) calaTotalPrice {
    int total = 0;
    for (TaxInvoiceItemModel* model in _listOfTax[[self.selectedPage integerValue]]) {
        total += [model.amount integerValue];
    }
    
    _totalPrice.text = [NSString stringWithFormat:@"%d", total];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (selectedPage == 0) {
//        return 0;
//    }
//    return 33;
        return 0;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    LeaveRecordHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[LeaveRecordHeaderCell cellIdentifier]];
//
//    return cell;
//}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TwoColumnSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:[TwoColumnSecondCell cellIdentifier] forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    TaxInvoiceItemModel* model = _listOfTax[[self.selectedPage integerValue]][indexPath.row];
    cell.leftLabel.text = model.descriptionValue;
    cell.rightLabel.text = model.amount;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listOfTax[[self.selectedPage integerValue]].count;
}

- (void) topFilterChanged: (HMSegmentedControl*) control {
    self.selectedPage = [NSNumber numberWithInteger:control.selectedSegmentIndex];
    [self calaTotalPrice];
    [self.tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
