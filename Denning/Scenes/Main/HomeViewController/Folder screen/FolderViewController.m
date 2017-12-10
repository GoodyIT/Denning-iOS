//
//  FolderViewController.m
//  Denning
//
//  Created by DenningIT on 31/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FolderViewController.h"
#import "PersonalDocumentViewController.h"
#import "BranchHeaderCell.h"

@interface FolderViewController ()<BranchHeaderDelegate, UIDocumentInteractionControllerDelegate>

@end

@implementation FolderViewController
@synthesize documentModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNibs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) prepareUI {

}

- (void)registerNibs {
    [BranchHeaderCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

#pragma mark - BranchHeaderDelegate
- (IBAction) didBackBtnTapped:(id) sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return documentModel.folders.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCell" forIndexPath:indexPath];
    
    UIButton *folderBtn = [cell viewWithTag:1];
    folderBtn.tag = indexPath.row;
    DocumentModel* folder = documentModel.folders[indexPath.row];
    [folderBtn setTitle:folder.name forState:UIControlStateNormal];
    
    return cell;
}

- (IBAction) gotoDocument: (UIButton*) sender
{
    DocumentModel* folder = documentModel.folders[sender.tag];
    
    [self performSegueWithIdentifier:kDocumentSegue sender:folder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kDocumentSegue]) {
        PersonalDocumentViewController* personalDocVC = segue.destinationViewController;
        personalDocVC.folderModel = sender;
    }
}

@end
