//
//  BaseTableViewController.m
//  Denning
//
//  Created by Denning IT on 2017-12-08.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[QMNetworkManager sharedManager] cancelAllOperations];
    
    [SVProgressHUD dismiss];
    [self.view endEditing:YES];
    if ([self.navigationController isKindOfClass:[QMNavigationController class]]) {
        [(QMNavigationController*)self.navigationController dismissNotificationPanel];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return 0;
}

@end
