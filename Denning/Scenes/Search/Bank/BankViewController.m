//
//  BankViewController.m
//  Denning
//
//  Created by DenningIT on 27/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "BankViewController.h"
#import "CommonTextCell.h"
#import "ContactCell.h"
#import "RelatedMatterViewController.h"

@interface BankViewController ()
{
    __block BOOL isLoading;
}
@end

@implementation BankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];

    [self gotoRelatedMatterSection];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) gotoRelatedMatterSection
{
    if ([self.gotoRelatedMatter isEqualToString:@"Matter"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow: ([self.tableView numberOfRowsInSection:([self.tableView numberOfSections]-2)]-1) inSection:([self.tableView numberOfSections]-2)];
            
            if (self.bankModel.relatedMatter.count > 0) {
                indexPath = [NSIndexPath indexPathForRow: 0 inSection:([self.tableView numberOfSections]-1)];
            }
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

- (void) popupScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)registerNibs {
    
    [ContactCell registerForReuseInTableView:self.tableView];
    [CommonTextCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 5;
    }
    
    return self.bankModel.relatedMatter.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        if (isLoading) return;
        isLoading = YES;
        SearchResultModel* model = self.bankModel.relatedMatter[indexPath.row];
        [SVProgressHUD showWithStatus:@"Loading"];
        @weakify(self);
        [[QMNetworkManager sharedManager] loadRelatedMatterWithCode:model.key completion:^(RelatedMatterModel * _Nonnull relatedModel, NSError * _Nonnull error) {
            
            @strongify(self);
            self->isLoading = false;
            [SVProgressHUD dismiss];
            if (error == nil) {
                [self performSegueWithIdentifier:kRelatedMatterSegue sender:relatedModel];
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"";
            break;
        case 1:
            sectionName = @"Main Information";
            break;
        case 2:
            sectionName = @"Related matter";
            break;

            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell cellIdentifier] forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell configureCellWithContact:self.bankModel.name text:@""];
        } else {
            [cell configureCellWithContact:self.bankModel.IDNo text:@""];
        }
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [cell configureCellWithContact:@"Telephone" text:self.bankModel.tel];
        } else if (indexPath.row == 1) {
            [cell configureCellWithContact:@"mobile" text:self.bankModel.mobile];
        } else if (indexPath.row == 2) {
            [cell configureCellWithContact:@"office" text:self.bankModel.office];
        } else if (indexPath.row == 3) {
            [cell configureCellWithContact:@"email" text:self.bankModel.email];
        } else if (indexPath.row == 4) {
            [cell configureCellWithContact:@"address" text:self.bankModel.address];
        }
        return cell;
    } else {
        SearchResultModel *matterModel = self.bankModel.relatedMatter[indexPath.row];
        NSArray* matter = [DIHelpers removeFileNoAndSeparateFromMatterTitle: matterModel.title];
        [cell configureCellWithContact:matter[0] text:matter[1]];
        [cell setEnableRightBtn:NO image:nil];
        
        return cell;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kRelatedMatterSegue]){
        RelatedMatterViewController* relatedMatterVC = segue.destinationViewController;
        relatedMatterVC.relatedMatterModel = sender;
        relatedMatterVC.previousScreen = @"Bank";
    }
}


@end
