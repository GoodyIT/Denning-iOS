//
//  Attendance.m
//  Denning
//
//  Created by Ho Thong Mee on 27/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "Attendance.h"

@interface Attendance ()
@property (weak, nonatomic) IBOutlet UILabel *spentTime;
@property (weak, nonatomic) IBOutlet UILabel *today;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userRole;
@property (weak, nonatomic) IBOutlet UILabel *totalHour;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnClock;
@property (weak, nonatomic) IBOutlet UIButton *btnBreak;


@end

@implementation Attendance

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareUI {
    self.today.text = [DIHelpers getDateInShortForm:[DIHelpers todayWithTime]];
    self.userName.text = [DataManager sharedManager].user.username;
//    _userRole.text = [DataManager sharedManager].user.className;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [UIView new];
}

- (IBAction)didTapClock:(id)sender {
}

- (IBAction)didTapBreak:(id)sender {
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
