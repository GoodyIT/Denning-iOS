//
//  ContactViewController.m
//  Denning
//
//  Created by DenningIT on 08/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactHeaderCell.h"
#import "ContactCell.h"
#import "CommonTextCell.h"
#import "NewContactHeaderCell.h"
#import "RelatedMatterViewController.h"
#import "AddContactViewController.h"
#import <MessageUI/MessageUI.h>

@interface ContactViewController ()<ContactCellDelegate, NewContactHeaderCellDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate>
{
    __block BOOL isLoading;
}

@end

@implementation ContactViewController
@synthesize contactModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    if (self.previousScreen.length != 0) {
        [self prepareUI];
    }
    [self showOnlyMatter];
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

- (void) showOnlyMatter
{
    if ([self.gotoRelatedMatter isEqualToString:@"Matter"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow: ([self.tableView numberOfRowsInSection:([self.tableView numberOfSections]-2)]-1) inSection:([self.tableView numberOfSections]-2)];
            
            if (self.contactModel.relatedMatter.count > 0) {
                indexPath = [NSIndexPath indexPathForRow: 0 inSection:([self.tableView numberOfSections]-1)];
            }
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
        
        self.title = @"Related Matters";
    }
}

- (void) prepareUI {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 23)];
    [backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popupScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self.navigationItem setLeftBarButtonItems:@[backButtonItem] animated:YES];
}

- (void) addContact {
    
}

- (IBAction) dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) popupScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)registerNibs {
    [ContactHeaderCell registerForReuseInTableView:self.tableView];
    [NewContactHeaderCell registerForReuseInTableView:self.tableView];
    [CommonTextCell registerForReuseInTableView:self.tableView];
    [ContactCell registerForReuseInTableView:self.tableView];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT/2;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self.gotoRelatedMatter isEqualToString:@"Matter"]) {
        return 2;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1 && ![self.gotoRelatedMatter isEqualToString:@"Matter"]) {
        return 11;
    }
    return self.contactModel.relatedMatter.count;
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
            if (self.gotoRelatedMatter.length == 0) {
                sectionName = @"Main Information";
            } else {
                sectionName = @"Related Matters";
            }
            
            break;
        case 2:
            sectionName = @"Related matters";
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

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell cellIdentifier] forIndexPath:indexPath];
    if (indexPath.section == 0) {
        NewContactHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[NewContactHeaderCell cellIdentifier] forIndexPath:indexPath];
        [cell configureCellWithInfo:contactModel.name number:contactModel.IDNo image:[UIImage imageNamed:@"icon_client"]];
        cell.delegate = self;
        return cell;
    } else if (indexPath.section == 1 && ![self.gotoRelatedMatter isEqualToString:@"Matter"]) {
        [cell setEnableRightBtn:NO image:nil];
        if (indexPath.row == 0) {
            [cell configureCellWithContact:@"Date Of Birth" text:contactModel.dateOfBirth];
        } else if (indexPath.row == 1) {
            [cell configureCellWithContact:@"Citizenship" text:contactModel.citizenShip];
        } else if (indexPath.row == 2) {
            [cell configureCellWithContact:@"Phone (mobile)" text:contactModel.mobilePhone];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            cell.tag = 1;
        } else if (indexPath.row == 3) {
            [cell configureCellWithContact:@"Phone (office)" text:contactModel.officePhone];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            cell.tag = 1;
        } else if (indexPath.row == 4) {
            [cell configureCellWithContact:@"Phone (home)" text:contactModel.homePhone];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            cell.tag = 1;
        } else if (indexPath.row == 5) {
            [cell configureCellWithContact:@"Fax" text:contactModel.fax];
        } else if (indexPath.row == 6) {
            [cell configureCellWithContact:@"Email" text:contactModel.email withLower:YES];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_email_red"]];
            cell.tag = 2;
        } else if (indexPath.row == 7) {
            [cell configureCellWithContact:@"Tax File No" text:contactModel.tax];
        } else if (indexPath.row == 8) {
            [cell configureCellWithContact:@"IRD Branch" text:contactModel.IRDBranch.descriptionValue];
        } else if (indexPath.row == 9) {
            [cell configureCellWithContact:@"Occupation" text:contactModel.occupation.descriptionValue];
        }  else if (indexPath.row == 10) {
            [cell configureCellWithContact:@"Address" text:contactModel.address.fullAddress];
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_location"]];
        }
        cell.delegate = self;
        return cell;
    } else {
        SearchResultModel *matterModel = self.contactModel.relatedMatter[indexPath.row];
        NSArray* matter = [DIHelpers removeFileNoAndSeparateFromMatterTitle: matterModel.title];
        [cell configureCellWithContact:matter[0] text:matter[1]];
        [cell setEnableRightBtn:NO image:nil];
      
        return cell;
    }
}

#pragma mark - NewContactHeaderCellDelegate
- (void) didTapMessage:(NewContactHeaderCell *)cell
{
    // Go to message
}

- (void) didTapEdit:(NewContactHeaderCell *)cell
{
    [self performSegueWithIdentifier:kAddContactSegue sender:self.contactModel];
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

- (void) loadRelatedMatter:(NSIndexPath*) indexPath {
    if (isLoading) return;
    isLoading = YES;
    SearchResultModel* model = self.contactModel.relatedMatter[indexPath.row];
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

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.gotoRelatedMatter isEqualToString:@"Matter"] &&indexPath.section == 2) {
        [self loadRelatedMatter:indexPath];
    } else if ([self.gotoRelatedMatter isEqualToString:@"Matter"] &&indexPath.section == 1) {
        [self loadRelatedMatter:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kRelatedMatterSegue]){
        RelatedMatterViewController* relatedMatterVC = segue.destinationViewController;
        relatedMatterVC.relatedMatterModel = sender;
        relatedMatterVC.previousScreen = @"Contact";
    }
    
    if ([segue.identifier isEqualToString:kAddContactSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        AddContactViewController* addVC = nav.viewControllers.firstObject;
        addVC.viewType = @"Update";
        addVC.title = @"Update Contact";
        addVC.contactModel = sender;
    }
}

@end
