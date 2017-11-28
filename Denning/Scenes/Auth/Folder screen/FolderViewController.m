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
    if (documentModel.folders.count == 0) {
        [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
    }
    
    self.navigationController.navigationBarHidden = YES;
}

- (void) prepareUI {

}

- (void)registerNibs {
    [BranchHeaderCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

#pragma mark - BranchHeaderDelegate
- (void) didBackBtnTapped:(BranchHeaderCell *)cell
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 120;
    }
    return 71;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return documentModel.folders.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        BranchHeaderCell *branchCell = [tableView dequeueReusableCellWithIdentifier:[BranchHeaderCell cellIdentifier] forIndexPath:indexPath];
        [branchCell configureCellWithTitle:@"Select a Folder"];
        branchCell.delegate = self;
        return branchCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCell" forIndexPath:indexPath];
    
    UIButton *folderBtn = [cell viewWithTag:1];
    folderBtn.tag = indexPath.row-1;
    FolderModel* folder = documentModel.folders[indexPath.row-1];
    [folderBtn setTitle:folder.name forState:UIControlStateNormal];
    
    return cell;
}

- (IBAction) gotoDocument: (UIButton*) sender
{
    FolderModel* folder = documentModel.folders[sender.tag];
    
    [self performSegueWithIdentifier:kDocumentSegue sender:folder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kDocumentSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        PersonalDocumentViewController* personalDocVC = nav.viewControllers.firstObject;
        personalDocVC.folderModel = sender;
    }
}

@end
