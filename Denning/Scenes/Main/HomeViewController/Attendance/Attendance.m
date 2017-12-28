//
//  Attendance.m
//  Denning
//
//  Created by Ho Thong Mee on 27/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "Attendance.h"
#import "AttendanceItemCell.h"

@interface Attendance ()<UITableViewDelegate, UITableViewDataSource>
{
   __block BOOL isAttended, isBreaking;
}
@property (weak, nonatomic) IBOutlet UILabel *spentTime;
@property (weak, nonatomic) IBOutlet UILabel *today;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userRole;
@property (weak, nonatomic) IBOutlet UILabel *totalHour;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnClock;
@property (weak, nonatomic) IBOutlet UIButton *btnBreak;
@property (weak, nonatomic) IBOutlet UIView *headerBackground;

@end

@implementation Attendance

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNibs];
    [self updateHeader];
//    [self.tableView reloadData];
//    [self getAttendanceModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateHeader {
    NSArray *array = [_attendanceModel.dtDate componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    self.today.text = [DIHelpers getDateInShortForm: _attendanceModel.dtDate];
    _spentTime.text = array[1];
    self.userName.text = _attendanceModel.clsStaff.strName;
    _userRole.text = _attendanceModel.clsStaff.strPositionTitle;
    _totalHour.text = _attendanceModel.totalWorkingHours;
    
    [_btnClock setTitle:_attendanceModel.btnLeft forState:UIControlStateNormal];
    if (_attendanceModel.btnRight.length != 0) {
        [_btnBreak setTitle:_attendanceModel.btnRight forState:UIControlStateNormal];
    }
    
    if ([_attendanceModel.btnRight isEqualToString:@"END BREAK"]) {
        isBreaking = YES;
    } else {
        isBreaking = NO;
    }
    
    if ([_attendanceModel.btnLeft isEqualToString:@"CLOCK-OUT"]) {
        isAttended = YES;
        [_btnClock setBackgroundColor:[UIColor redColor]];
        _headerBackground.backgroundColor = [UIColor babyBlue];
    } else {
        isAttended = NO;
        [_btnClock setBackgroundColor:[UIColor babyBlue]];
        _headerBackground.backgroundColor = [UIColor redColor];
    }
    
    if (!isBreaking) {
        [_btnBreak setTitle:@"Start Break" forState:UIControlStateNormal];
    }
    
    _btnBreak.enabled = isAttended;
}

- (void) prepareUI {
    isAttended = NO;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (void)registerNibs {
    
    [AttendanceItemCell registerForReuseInTableView:self.tableView];
}

- (void) handleResponse:(AttendanceModel*) result error:(NSError*) error {
     [SVProgressHUD dismiss];
    if (!error) {
        _attendanceModel = result;
        [self updateHeader];
        [self.tableView reloadData];
    } else {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeClear];
    }
}

- (IBAction)didTapClock:(id)sender {
    [SVProgressHUD show];
    if (!isAttended) {
        [[QMNetworkManager sharedManager] attendanceClockIn:^(AttendanceModel * _Nonnull result, NSError * _Nonnull error) {
            [self handleResponse:result error:error];
        }];
    } else {
        [[QMNetworkManager sharedManager] attendanceClockOut:^(AttendanceModel * _Nonnull result, NSError * _Nonnull error) {
            [self handleResponse:result error:error];
        }];
    }
}

- (IBAction)didTapBreak:(id)sender {
    if (_attendanceModel && _attendanceModel.btnRight.length != 0 && !isBreaking) {
        [SVProgressHUD show];
        [[QMNetworkManager sharedManager] attendanceStartBreak:^(AttendanceModel * _Nonnull result, NSError * _Nonnull error) {
            [self handleResponse:result error:error];
        }];
    } else if (_attendanceModel && isBreaking) {
        [SVProgressHUD show];
        [[QMNetworkManager sharedManager] attendanceEndBreak:^(AttendanceModel * _Nonnull result, NSError * _Nonnull error) {
            [self handleResponse:result error:error];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    return [_attendanceModel.theListing count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendanceItemCell *cell = [tableView dequeueReusableCellWithIdentifier:[AttendanceItemCell cellIdentifier] forIndexPath:indexPath];
    
    [cell configureCellWithModel:_attendanceModel.theListing[indexPath.row]];
    
    return cell;
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
