//
//  GovernmentOfficesViewController.m
//  Denning
//
//  Created by DenningIT on 27/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "GovernmentOfficesViewController.h"
#import "CommonTextCell.h"
#import "ContactCell.h"
#import "NewContactHeaderCell.h"
#import "SearchLastCell.h"
#import "RelatedMatterViewController.h"

@interface GovernmentOfficesViewController ()
{
    __block BOOL isLoading;
}
@end

@implementation GovernmentOfficesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    if (self.previousScreen.length != 0) {
        [self prepareUI];
    }
    
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
            
            if (self.govOfficeModel.relatedMatter.count > 0) {
                indexPath = [NSIndexPath indexPathForRow: 0 inSection:([self.tableView numberOfSections]-1)];
            }
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

- (void) prepareUI {
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popupScreen:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];;
    
    [self.navigationItem setLeftBarButtonItems:@[backButtonItem] animated:YES];
}

- (void) popupScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)registerNibs {
    [NewContactHeaderCell registerForReuseInTableView:self.tableView];
    [ContactCell registerForReuseInTableView:self.tableView];
    [CommonTextCell registerForReuseInTableView:self.tableView];
    [SearchLastCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 5;
    }
    return self.govOfficeModel.relatedMatter.count;
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
    if (section == 0) {
        return 0;
    }
    return 10;
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        if (isLoading) return;
        isLoading = YES;
        SearchResultModel* model = self.govOfficeModel.relatedMatter[indexPath.row];
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell cellIdentifier] forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == 0) {
        NewContactHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[NewContactHeaderCell cellIdentifier] forIndexPath:indexPath];
        [cell configureCellWithInfo:self.govOfficeModel.name number:self.govOfficeModel.IDNo image:[UIImage imageNamed:@"icon_client"]];
        cell.chatBtn.hidden = YES;
        cell.editBtn.hidden = YES;
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [cell configureCellWithContact:@"Telephone" text:self.govOfficeModel.tel];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
        } else if (indexPath.row == 1) {
            [cell configureCellWithContact:@"mobile" text:self.govOfficeModel.mobile];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
        } else if (indexPath.row == 2) {
            [cell configureCellWithContact:@"office" text:self.govOfficeModel.office];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
        } else if (indexPath.row == 3) {
            [cell configureCellWithContact:@"email" text:self.govOfficeModel.email];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_email_red"]];
        } else if (indexPath.row == 4) {
            [cell configureCellWithContact:@"address" text:self.govOfficeModel.address];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_location"]];
        }
        return cell;
    } else {
        SearchResultModel *matterModel = self.govOfficeModel.relatedMatter[indexPath.row];
        NSArray* matter = [DIHelpers removeFileNoAndSeparateFromMatterTitle: matterModel.title];
        SearchLastCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchLastCell cellIdentifier] forIndexPath:indexPath];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.topLabel.text = matter[0];
        cell.bottomLabel.text = matter[1];
        cell.rightLabel.text = [DIHelpers getDateInShortForm:matterModel.sortDate];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kRelatedMatterSegue]){
        RelatedMatterViewController* relatedMatterVC = segue.destinationViewController;
        relatedMatterVC.relatedMatterModel = sender;
        relatedMatterVC.previousScreen = @"Gov Offices";
    }
}


@end
