//
//  ContactViewController.m
//  Denning
//
//  Created by DenningIT on 08/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactCell.h"
#import "CommonTextCell.h"
#import "SearchLastCell.h"
#import "NewContactHeaderCell.h"
#import "RelatedMatterViewController.h"
#import "AddContactViewController.h"
#import <MessageUI/MessageUI.h>

@interface ContactViewController ()<ContactCellDelegate, NewContactHeaderCellDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate>
{
    __block BOOL isLoading;
}
@property (weak, nonatomic) BFTask *addUserTask;

@property (weak, nonatomic) BFTask *task;

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
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popupScreen:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
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
    [NewContactHeaderCell registerForReuseInTableView:self.tableView];
    [CommonTextCell registerForReuseInTableView:self.tableView];
    [ContactCell registerForReuseInTableView:self.tableView];
    [SearchLastCell registerForReuseInTableView:self.tableView];
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
    return 44;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell cellIdentifier] forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0) {
        NewContactHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[NewContactHeaderCell cellIdentifier] forIndexPath:indexPath];
        [cell configureCellWithInfo:contactModel.name number:contactModel.IDNo image:[UIImage imageNamed:@"icon_client"]];
        cell.oldICLabel.text = contactModel.KPLama;
        cell.oldICLabel.hidden = NO;
        cell.delegate = self;
        return cell;
    } else if (indexPath.section == 1 && ![self.gotoRelatedMatter isEqualToString:@"Matter"]) {
        [cell setEnableRightBtn:NO image:nil];
        if (indexPath.row == 0) {
            [cell configureCellWithContact:@"Date Of Birth" text:[DIHelpers getDateInShortForm:contactModel.dateOfBirth]];
        } else if (indexPath.row == 1) {
            [cell configureCellWithContact:@"Citizenship" text:contactModel.citizenShip];
        } else if (indexPath.row == 2) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            [cell configureCellWithContact:@"Phone (mobile)" text:contactModel.mobilePhone];
            cell.tag = 1;
        } else if (indexPath.row == 3) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            [cell configureCellWithContact:@"Phone (office)" text:contactModel.officePhone];
            cell.tag = 1;
        } else if (indexPath.row == 4) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_phone_red"]];
            [cell configureCellWithContact:@"Phone (home)" text:contactModel.homePhone];
            cell.tag = 1;
        } else if (indexPath.row == 5) {
            [cell configureCellWithContact:@"Fax" text:contactModel.fax];
        } else if (indexPath.row == 6) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_email_red"]];
            [cell configureCellWithContact:@"Email" text:contactModel.email withLower:YES];
            cell.tag = 2;
            return cell;
        } else if (indexPath.row == 7) {
            [cell configureCellWithContact:@"Tax File No" text:contactModel.tax];
        } else if (indexPath.row == 8) {
            [cell configureCellWithContact:@"IRD Branch" text:contactModel.IRDBranch.descriptionValue];
        } else if (indexPath.row == 9) {
            [cell configureCellWithContact:@"Occupation" text:contactModel.occupation.descriptionValue];
        }  else if (indexPath.row == 10) {
            [cell setEnableRightBtn:YES image:[UIImage imageNamed:@"icon_location"]];
            [cell configureCellWithContact:@"Address" text:contactModel.address.fullAddress];
        }
        cell.delegate = self;
        return cell;
    } else {
        SearchResultModel *matterModel = self.contactModel.relatedMatter[indexPath.row];
        NSArray* matter = [DIHelpers removeFileNoAndSeparateFromMatterTitle: matterModel.title];
        
        SearchLastCell *cell = [tableView dequeueReusableCellWithIdentifier:[SearchLastCell cellIdentifier] forIndexPath:indexPath];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.topLabel.text = matter[0];
        cell.bottomLabel.text = matter[1];
        cell.rightLabel.text = [DIHelpers getDateInShortForm:matterModel.sortDate];
      
        return cell;
    }
}

- (void) inviteUserToDenning:(NSString*) email {
    [[QMNetworkManager sharedManager] setPublicHTTPHeader];
    NSDictionary* params = @{@"email": [QBSession currentSession].currentUser.email, @"favourite": email};
    NSString* url = INVITE_DENNING_URL;
    
    [[QMNetworkManager sharedManager] sendPostWithURL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        if (error == nil) {
            [SVProgressHUD showSuccessWithStatus:@"Successfully Done"];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Oops..."];
        }
    }];
}

- (void) revokeChat:(QBUUser*) user {
    BOOL isRequestSent = [[QMCore instance].contactManager isContactListItemExistentForUserWithID:user.ID];
    
    if (![[QMCore instance].contactManager isFriendWithUserID: user.ID] && !isRequestSent) {
        @weakify(self);
        [self addToContact:user withCompletion:^{
            @strongify(self);
            [self gotoChat:user];
        }];
    } else {
        [self gotoChat:user];
    }
}

- (IBAction)addToContact:(QBUUser*) user withCompletion:(void(^)(void)) completion {
    
    if (self.addUserTask) {
        // task in progress
        return;
    }
    
    if (![[QMCore instance].contactManager isFriendWithUserID:user.ID]) {
        BOOL isRequestSent = [[QMCore instance].contactManager isContactListItemExistentForUserWithID:user.ID];
        if (isRequestSent) {
            if (completion != nil) {
                completion();
            }
            return;
        } else {
            [SVProgressHUD showWithStatus:@"Sending"];
            
            self.addUserTask = [[[QMCore instance].contactManager addUserToContactList:user] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                
                [SVProgressHUD dismiss];
                if (self == nil) return nil;
                if (!task.isFaulted) {
                    if (completion != nil) {
                        completion();
                    }
                }
                else {
                    [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil)
                                    actionSuccess:NO
                                 inViewController:self];
                }
                
                return nil;
            }];
        }
    }
}

- (void) gotoChat: (QBUUser*) user {
    
    QBChatDialog *privateChatDialog = [[QMCore instance].chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
    
    if (privateChatDialog) {
        
        [self performSegueWithIdentifier:kQMSceneSegueChat sender:privateChatDialog];
    }
    else {
        
        if (self.task) {
            // task in progress
            return;
        }
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        
        __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
        
        @weakify(self);
        self.task = [[[QMCore instance].chatService createPrivateChatDialogWithOpponentID:user.ID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
            
            @strongify(self);
            [navigationController dismissNotificationPanel];
            if (!task.isFaulted) {
                
                [self performSegueWithIdentifier:kQMSceneSegueChat sender:task.result];
            }
            
            return nil;
        }];
    }
}

#pragma mark - NewContactHeaderCellDelegate
- (void) didTapMessage:(NewContactHeaderCell *)cell
{
    // Go to message
    if (![QMCore instance].callManager.hasActiveCall && [QMCore instance].currentProfile != nil) {
        [[QMNetworkManager sharedManager] getChatContactsWithCompletion:^{
            
            NSArray* contactArray = [[DataManager sharedManager].staffContactsArray arrayByAddingObjectsFromArray:[DataManager sharedManager].clientContactsArray];
            QBUUser* __user = nil;
            for (ChatFirmModel* firmModel in contactArray) {
                for(QBUUser* user in firmModel.users) {
                    if ([user.email  isEqualToString:self.contactModel.email]) {
                        __user = user;
                        break;
                    }
                }
            }
            
            if (__user == nil) {
                [QMAlert showConfirmDialog:@"Do you want to invite this client?" inViewController:self completion:^(UIAlertAction * _Nonnull action) {
                    if  ([action.title isEqualToString:@"OK"]) {
                       [self inviteUserToDenning:self.contactModel.email];
                    }
                }];
            } else {
                [self revokeChat:__user];
            }
        }];
    }
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
    
    if (![self.gotoRelatedMatter isEqualToString:@"Matter"] && indexPath.section == 2) {
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
        addVC.updateHandler = ^(ContactModel *model) {
            self.contactModel = model;
            [self.tableView reloadData];
        };
        addVC.viewType = @"Update";
        addVC.title = @"Update Contact";
        addVC.contactModel = sender;
    } else if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        UINavigationController *navigationController = segue.destinationViewController;
        QMChatVC *chatViewController = [navigationController viewControllers].firstObject;
        chatViewController.chatDialog = sender;
        //        chatViewController.firmCode = selectedFirmCode;
    }
}

@end
