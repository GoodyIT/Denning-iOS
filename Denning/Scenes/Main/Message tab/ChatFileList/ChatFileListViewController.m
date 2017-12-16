//
//  ChatFileListViewController.m
//  Denning
//
//  Created by Denning IT on 2017-12-16.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ChatFileListViewController.h"

@interface ChatFileListViewController ()<UISearchBarDelegate, UISearchControllerDelegate,UITableViewDelegate, UITableViewDataSource>
{
    NSInteger page;
    __block BOOL isAppending;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString* filter;
@property (strong, nonatomic) NSMutableArray* listOfFile;
@end

@implementation ChatFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self registerNib];
//    [self prepareUI];
//    [self getList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
