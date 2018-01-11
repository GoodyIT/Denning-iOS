//
//  LegalFirmViewController.m
//  Denning
//
//  Created by DenningIT on 13/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LegalFirmViewController.h"
#import "CommonTextCell.h"
#import "ContactCell.h"
#import "RelatedMatterViewController.h"
#import "NewContactHeaderCell.h"
#import <MessageUI/MessageUI.h>

@interface LegalFirmViewController ()<ContactCellDelegate, NewContactHeaderCellDelegate,  MFMailComposeViewControllerDelegate>
{
    __block BOOL isLoading;
}
@end

@implementation LegalFirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
            
            if (self.legalFirmModel.relatedMatter.count > 0) {
                indexPath = [NSIndexPath indexPathForRow: 0 inSection:([self.tableView numberOfSections]-1)];
            }
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
        
        self.title = @"Related Matters";
    }
}

- (void) prepareUI {
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popupScreen:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
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
        return 6;
    }
    
    return self.legalFirmModel.relatedMatter.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        if (isLoading) return;
        isLoading = YES;
        SearchResultModel* model = self.legalFirmModel.relatedMatter[indexPath.row];
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
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0) {
        NewContactHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[NewContactHeaderCell cellIdentifier] forIndexPath:indexPath];
        [cell configureCellWithInfo:self.legalFirmModel.name number:self.legalFirmModel.IDNo image:[UIImage imageNamed:@"icon_legalfirm"]];
        cell.chatLabel.hidden = cell.chatBtn.hidden = cell.editLabel.hidden = cell.editBtn.hidden = YES;
        return cell;
    } else if (indexPath.section == 1) {
        [cell setEnableRightBtn:NO image:nil];
        if (indexPath.row == 0) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            [cell configureCellWithContact:@"Phone 1" text:self.legalFirmModel.tel];
            cell.tag = 1;
        } if (indexPath.row == 1) {
             [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            [cell configureCellWithContact:@"Phone 2" text:self.legalFirmModel.fax];
            cell.tag = 1;
        } else if (indexPath.row == 2) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            [cell configureCellWithContact:@"Phone (mobile)" text:self.legalFirmModel.mobile];
            cell.tag = 1;
        } else if (indexPath.row == 3) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            [cell configureCellWithContact:@"Phone (office)" text:self.legalFirmModel.office];
            cell.tag = 1;
        } else if (indexPath.row == 4) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_email_red"]];
            [cell configureCellWithContact:@"email" text:self.legalFirmModel.email];
            cell.tag = 2;
        } else if (indexPath.row == 5) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_location"]];
            [cell configureCellWithContact:@"address" text:self.legalFirmModel.address];
            cell.tag = 3;
        }
        cell.delegate = self;
        return cell;
    } else {
        SearchResultModel *matterModel = self.legalFirmModel.relatedMatter[indexPath.row];
        NSArray* matter = [DIHelpers removeFileNoAndSeparateFromMatterTitle: matterModel.title];
        [cell configureCellWithContact:matter[0] text:matter[1]];
        [cell setEnableRightBtn:NO image:nil];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

#pragma mark - NewContactHeaderCellDelegate
- (void) didTapMessage:(NewContactHeaderCell *)cell
{
    // Go to message
}

#pragma mark - ContactCellDelegate
- (void) didTapRightBtn:(ContactCell *)cell value:(NSString *)value
{
    if (cell.tag == 1) { // phone call
        NSString *dialNumber =[@"telprompt://" stringByAppendingString:value];
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *url = [NSURL URLWithString:dialNumber];
        [app openURL:url];
    } else if (cell.tag == 2) { // email
        if (![MFMailComposeViewController canSendMail]) {
            [QMAlert showAlertWithMessage:@"Mail services are not available." actionSuccess:NO inViewController:self];
            return;
        }
        
        MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
        composeVC.mailComposeDelegate = self;
        [composeVC setToRecipients:[NSArray arrayWithObject:value]];
        
        // Configure the fields of the interface.
        [composeVC setSubject:@"Denning"];
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kRelatedMatterSegue]){
        RelatedMatterViewController* relatedMatterVC = segue.destinationViewController;
        relatedMatterVC.relatedMatterModel = sender;
        relatedMatterVC.previousScreen = @"Legal Firm";
    }
}


@end
