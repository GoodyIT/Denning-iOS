//
//  DynamicAddTableViewController.m
//  Denning
//
//  Created by Denning IT on 2018-10-20.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import "DynamicAddTableViewController.h"
#import "AddMenuCell.h"
#import "AddDiaryViewController.h"
#import "Attendance.h"

@interface DynamicAddTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSArray<AddMenu*>* menuArray;

@end

@implementation DynamicAddTableViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureBackBtnWithImageName:@"Back" withSelector:@selector(popupScreen)];
    [self changeTitle];
    
    [self performSelector:@selector(hideTabBar) withObject:nil afterDelay:1.0];
    [self loadMenu];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self setTabBarVisible:YES animated:NO completion:nil];
    [super viewWillDisappear:animated];
}


- (void) changeTitle {
    self.tabBarController.navigationItem.titleView = nil;
    self.tabBarController.navigationItem.title = @"ADD";
    
    self.navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_add"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self registerNib];
}

- (void) registerNib {
    // Hide empty separators
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
 
    
    [AddMenuCell registerForReuseInTableView:self.tableView];
}

- (void) loadMenu {
    NSString* url = [NSString stringWithFormat:@"%@%@", [DataManager sharedManager].user.serverAPI, ADD_DYNAMIC_MENU];
    [SVProgressHUD showWithStatus:@"Loading"];
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        [SVProgressHUD dismiss];
        if (error == nil) {
            self.menuArray = [AddMenu getAddMenuArray:(NSArray*)result];
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
    //    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.menuArray.count;
//    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((AddMenu*)self.menuArray[section]).items.count;
//    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     AddMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:[AddMenuCell cellIdentifier] forIndexPath:indexPath];
    
    AddMenu* menu = self.menuArray[indexPath.section].items[indexPath.row];
    cell.icon.image = [UIImage imageNamed:menu.ios_icon];
    [cell.menuTitle setText:menu.title];
    // Configure the cell...
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AddMenu* menu = self.menuArray[indexPath.section].items[indexPath.row];
    if ([menu.openForm isEqualToString:@"add_contact"]) {
        [self performSegueWithIdentifier:kAddContactSegue sender:nil];
    } else if ([menu.openForm isEqualToString:@"add_property"]) {
        [self performSegueWithIdentifier:kAddPropertySegue sender:nil];
    } else if ([menu.openForm isEqualToString:@"add_matter"]) {
        [self performSegueWithIdentifier:kAddMatterSegue sender:nil];
    } else if ([menu.openForm isEqualToString:@"add_court"]) {
        [self performSegueWithIdentifier:kAddCourtSegue sender:nil];
    } else if ([menu.openForm isEqualToString:@"add_office"]) {
        [self performSegueWithIdentifier:kAddCourtSegue sender:@"OfficeDiary"];
    } else if ([menu.openForm isEqualToString:@"add_leave"]) {
        [self performSegueWithIdentifier:kAddLeaveAppSegue sender:nil];
    } else if ([menu.openForm isEqualToString:@"add_quotation"]) {
        [self performSegueWithIdentifier:kAddQuotationSegue sender:nil];
    } else if ([menu.openForm isEqualToString:@"add_invoice"]) {
        [self performSegueWithIdentifier:kAddTaxInvoiceSegue sender:nil];
    } else if ([menu.openForm isEqualToString:@"add_receipt"]) {
        [self performSegueWithIdentifier:kAddReceiptSegue sender:nil];
    } else if ([menu.openForm isEqualToString:@"add_attendance"]) {
        [self getAttendance];
    }
}

- (void) getAttendance {
    if (![DataManager sharedManager].isStaff){
        [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ACCESS_DENIED_REGISTER", nil) withTitle:@"Access Restricted" actionSuccess:NO inViewController:self withCallback:^{
            [self performSegueWithIdentifier:kAuthSegue sender:nil];
        }];
    } else if ([CLLocationManager locationServicesEnabled] == NO) {
        [(AppDelegate*)[UIApplication sharedApplication].delegate showDeniedLocation];
    } else {
        [SVProgressHUD show];
        
        [[QMNetworkManager sharedManager] getAttendanceListWithCompletion:^(AttendanceModel * _Nonnull result, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            [self handleResponse:result error:error];
        }];
    }
}

- (void) handleResponse:(AttendanceModel*) result error:(NSError*) error {
    if (!error) {
        [self performSegueWithIdentifier:kAttendanceSegue sender:result];
    } else {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeClear];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kAddCourtSegue] && sender != nil) {
        UINavigationController* nav = segue.destinationViewController;
        AddDiaryViewController* diaryVC = nav.viewControllers.firstObject;
        diaryVC.type = sender;
    } else if ([segue.identifier isEqualToString:kAttendanceSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        Attendance* vc = navVC.viewControllers.firstObject;
        vc.attendanceModel = sender;
    }
}

@end
