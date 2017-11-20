//
//  LeaveAppViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 15/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LeaveAppViewController.h"
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "LeaveRecordCell.h"
#import "LeaveRecordHeaderCell.h"
#import "AddLastOneButtonCell.h"
#import "BirthdayCalendarViewController.h"

@interface LeaveAppViewController ()<UITableViewDataSource, UITableViewDelegate,  HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>
{
    NSInteger selectedPage;
    NSString* nameOfField, *startDate, *endDate;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (strong, nonatomic) NSArray* topFilter, *listOfValsForApp;
@property (strong, nonatomic) NSMutableArray* listOfLeaveRecords;
@property (strong, nonatomic) NSNumber* page;
@property (weak, nonatomic) IBOutlet UILabel *staffName;

@end

@implementation LeaveAppViewController

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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) registerNibs {
    [AddLastOneButtonCell registerForReuseInTableView:self.tableView];
    [LeaveRecordCell registerForReuseInTableView:self.tableView];
    [LeaveRecordHeaderCell registerForReuseInTableView:self.tableView];
}

- (void) prepareUI {
    _staffName.text = [DataManager sharedManager].user.username;
    _listOfValsForApp = @[@"Start Date", @"End Date", @"Type Of Leave", @"No. of Days", @"Staff Remarks", @"Submitted By"];
    _page = @(1);
    selectedPage = 0;
    _listOfLeaveRecords = [NSMutableArray new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
    
    self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 76, self.view.frame.size.width, 44)];
    self.selectionList.delegate = self;
    self.selectionList.dataSource = self;
    self.selectionList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.selectionList.showsEdgeFadeEffect = YES;
    
    _topFilter = @[@"12", @"sdfs", @"sdf"];
    self.selectionList.selectionIndicatorColor = [UIColor colorWithHexString:@"FF3B2F"];
    [self.selectionList setTitleColor:[UIColor colorWithHexString:@"FF3B2F"] forState:UIControlStateHighlighted];
    [self.selectionList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-Regular" size:17] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-SemiBold" size:17]  forState:UIControlStateSelected];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-SemiBold" size:17] forState:UIControlStateHighlighted];
    
    [self.view addSubview:self.selectionList];
    self.selectionList.backgroundColor = [UIColor blackColor];
    self.selectionList.selectedButtonIndex = 0;
    self.selectionList.hidden = NO;
}

- (void) loadLeaveRecords {
    [SVProgressHUD show];
    [[QMNetworkManager sharedManager] getLeaveRecordsWithPage: _page completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [SVProgressHUD dismiss];
        if  (error == nil) {
            NSArray* array = [LeaveRecordModel getLEaveRecordArrayFromResponse:(NSArray*)result];
            if (array.count > 0) {
                _page = [NSNumber numberWithInteger:([_page integerValue] + 1)];
            }
            [_listOfValsForApp arrayByAddingObjectsFromArray:array];
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) saveLeaveApplication {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (selectedPage == 0) {
        return 0;
    }
    return 33;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LeaveRecordHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[LeaveRecordHeaderCell cellIdentifier]];
    
    return cell;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (selectedPage == 0) {
        if (indexPath.row == 6) {
            AddLastOneButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddLastOneButtonCell cellIdentifier] forIndexPath:indexPath];
            [cell.calculateBtn setTitle:@"Submit" forState:UIControlStateNormal];
            cell.calculateHandler = ^ {
                [self saveLeaveApplication];
            };
            
            return cell;
        }
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CodeDescCell" forIndexPath:indexPath];
        cell.textLabel.numberOfLines = 0;
        if (indexPath.row == 4 || indexPath.row == 5) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = _listOfValsForApp[indexPath.row];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = startDate;
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = endDate;
        } else {
             cell.detailTextLabel.text = @"";
        }
        return cell;
    }
    
    LeaveRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:[LeaveRecordCell cellIdentifier] forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.tag = indexPath.section;
    [cell configureCellWithModel:_listOfLeaveRecords[indexPath.row]];
    
    return cell;
}

- (void) showPopup: (UIViewController*) vc {
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:vc];
    [STPopupNavigationBar appearance].barTintColor = [UIColor blackColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.containerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    popupController.containerView.layer.shadowOffset = CGSizeMake(4, 4);
    popupController.containerView.layer.shadowOpacity = 1;
    popupController.containerView.layer.shadowRadius = 1.0;
    
    [popupController presentInViewController:self];
}

- (void) showCalendar {
    [self.view endEditing:YES];
    
    BirthdayCalendarViewController *calendarViewController = [[UIStoryboard storyboardWithName:@"AddContact" bundle:nil] instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        if ([nameOfField isEqualToString:@"startDate"]) {
            startDate = date;
        } else {
            endDate = date;
        }
    };
    
    [self showPopup:calendarViewController];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (selectedPage == 0) {
        
    } else {
        
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (selectedPage == 0) {
        return _listOfValsForApp.count + 1;
    }
    return _listOfLeaveRecords.count;
}

- (NSInteger)numberOfItemsInSelectionList:(nonnull HTHorizontalSelectionList *)selectionList {
    return _topFilter.count;
}

- (void)selectionList:(nonnull HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    
    selectedPage = index;
    if (selectedPage == 0) {
        [self.tableView reloadData];
    } else {
        [self loadLeaveRecords];
    }
}



@end
