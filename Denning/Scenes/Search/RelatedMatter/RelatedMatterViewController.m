//
//  RelatedMatterViewController.m
//  Denning
//
//  Created by DenningIT on 08/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "RelatedMatterViewController.h"
#import "ContactCell.h"
#import "ContactHeaderCell.h"
#import "ThreeFieldsCell.h"
#import "MatterLastCell.h"
#import "PropertyViewController.h"
#import "LedgerViewController.h"
#import "NewLedgerViewController.h"
#import "BankViewController.h"
#import "ContactViewController.h"
#import "LegalFirmViewController.h"
#import "DocumentViewController.h"
#import "MatterPropertyCell.h"
#import "SearchMatterCodeDetail.h"
#import "AddPropertyViewController.h"
#import "CommonTextCell.h"

@interface RelatedMatterViewController ()<MatterLastCellDelegate>
{
    __block BOOL isLoading;
}

@end

@implementation RelatedMatterViewController
@synthesize relatedMatterModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerNibs];
    if (self.previousScreen.length != 0) {
        [self prepareUI];
    }
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
    [ThreeFieldsCell registerForReuseInTableView:self.tableView];
    [ContactHeaderCell registerForReuseInTableView:self.tableView];
    [CommonTextCell registerForReuseInTableView:self.tableView];
    [ContactCell registerForReuseInTableView:self.tableView];
    [MatterLastCell registerForReuseInTableView:self.tableView];
    [MatterPropertyCell registerForReuseInTableView:self.tableView];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT/2;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 10;
}

- (NSDictionary*) getPartySectionInfo:(int) row {
    int count = 0;
    NSDictionary* info = [NSDictionary new];
    for (int i = 0; i < relatedMatterModel.partyGroupArray.count; i++) {
        PartyGroupModel* partyGroup = relatedMatterModel.partyGroupArray[i];
        if (partyGroup.partyArray.count == 0) {
            continue;
        }
        info = @{@"group":[NSNumber numberWithInt:i],
                 @"party":[NSNumber numberWithInt:row-count]
                 };
        count += partyGroup.partyArray.count;
        if (row < count) {
            break;
        }
    }
    
    return info;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = 0;
    switch (section) {
        case 0:
            return 6;
            break;
        case 1:
            if (relatedMatterModel.court == nil) {
                return 0;
            }
            return 5;
            break;
        case 2:
            for (int i = 0; i < relatedMatterModel.partyGroupArray.count; i++) {
                PartyGroupModel* partyGroup = relatedMatterModel.partyGroupArray[i];
                count += partyGroup.partyArray.count;
            }
            return count;
            break;
        case 3:
            return relatedMatterModel.solicitorGroupArray.count;
            break;
        case 4:
            return relatedMatterModel.propertyGroupArray.count;
            break;
        case 5:
            return relatedMatterModel.bankGroupArray.count;
            break;
        case 6:
            return relatedMatterModel.RMGroupArray.count;
            break;
        case 7:
            return relatedMatterModel.dateGroupArray.count;
            break;
        case 8:
            return relatedMatterModel.textGroupArray.count;
            break;
        case 9: // File Folder & Ledger
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) { // Contact client
            if (isLoading) return;
            isLoading = YES;
            [SVProgressHUD showWithStatus:@"Loading"];
            @weakify(self);
            [[QMNetworkManager sharedManager] loadContactFromSearchWithCode:relatedMatterModel.contactCode completion:^(ContactModel * _Nonnull contactModel, NSError * _Nonnull error) {
                
                @strongify(self);
                self->isLoading = false;
                [SVProgressHUD dismiss];
                if (error == nil) {
                    [self performSegueWithIdentifier:kContactSearchSegue sender:contactModel];
                } else {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }
            }];
        } else if (indexPath.row == 4) {
            [self performSegueWithIdentifier:kMatterCodeSegue sender:relatedMatterModel.matter];
        }
    }
    
    if (indexPath.section == 2) {
        NSDictionary* partySectionInfo = [self getPartySectionInfo:(int)indexPath.row];
        PartyGroupModel* partyGroup = relatedMatterModel.partyGroupArray[[[partySectionInfo objectForKey:@"group"] integerValue]];
        PartyModel* party = partyGroup.partyArray[[[partySectionInfo objectForKey:@"party"] integerValue]];
        if (isLoading) return;
        isLoading = YES;
        [SVProgressHUD showWithStatus:@"Loading"];
        @weakify(self);
        [[QMNetworkManager sharedManager] loadContactFromSearchWithCode:party.partyCode completion:^(ContactModel * _Nonnull contactModel, NSError * _Nonnull error) {
            
            @strongify(self);
            self->isLoading = false;
            [SVProgressHUD dismiss];
            if (error == nil) {
                [self performSegueWithIdentifier:kContactSearchSegue sender:contactModel];
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }];
    }
    
    
    if (indexPath.section == 3) { // Solicitor, Legal Firm
        if (isLoading) return;
        isLoading = YES;
        SolicitorGroup* solicitorGroup = self.relatedMatterModel.solicitorGroupArray[indexPath.row];
        [SVProgressHUD showWithStatus:@"Loading"];
        @weakify(self);
        [[QMNetworkManager sharedManager] loadLegalFirmWithCode:solicitorGroup.solicitorCode completion:^(LegalFirmModel * _Nonnull legalFirmModel, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            @strongify(self);
            self->isLoading = false;
            if (error == nil) {
                [self performSegueWithIdentifier:kLegalFirmSearchSegue sender:legalFirmModel];
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }];
    }
    
    if (indexPath.section == 4) { // property
        if (isLoading) return;
        isLoading = YES;
        PropertyModel* model = self.relatedMatterModel.propertyGroupArray[indexPath.row];
        [SVProgressHUD showWithStatus:@"Loading"];
        @weakify(self);
        [[QMNetworkManager sharedManager] loadPropertyfromSearchWithCode:model.key completion:^(AddPropertyModel * _Nonnull propertyModel, NSError * _Nonnull error) {
            
            @strongify(self);
            self->isLoading = false;
            [SVProgressHUD dismiss];
            if (error == nil) {
                [self performSegueWithIdentifier:kAddPropertySegue sender:propertyModel];
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }];
    }
    if (indexPath.section == 5) { // Bank
        if (isLoading) return;
        isLoading = YES;
        BankGroupModel *bankGroupModel = self.relatedMatterModel.bankGroupArray[indexPath.row];
        if (bankGroupModel.bankCode.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"Couldn't get the detail"];
            
        } else {
            [SVProgressHUD showWithStatus:@"Loading"];
            @weakify(self);
            [[QMNetworkManager sharedManager] loadBankFromSearchWithCode:bankGroupModel.bankCode completion:^(BankModel * _Nonnull bankModel, NSError * _Nonnull error) {
                
                @strongify(self);
                self->isLoading = false;
                [SVProgressHUD dismiss];
                if (error == nil) {
                    [self performSegueWithIdentifier:kBankSearchSegue sender:bankModel];
                } else {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }
            }];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Matter Information";
            break;
        case 1:
            sectionName = @"Court Case Information";
            break;
        case 2:
            sectionName = @"Parties Group";
            break;
        case 3:
            sectionName = @"Solicitors";
            break;
        case 4:
            sectionName = @"Properties";
            break;
        case 5:
            sectionName = @"Banks";
            break;
        case 6:
            sectionName = @"Important RM";
            break;
        case 7:
            sectionName = @"Important Dates";
            break;
        case 8:
            sectionName = @"Other Information";
            break;
        case 9:
            sectionName = @"Files & Ledgers";
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

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell cellIdentifier] forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            NSString* string = @"";
            NSString* label = @"";
            if (relatedMatterModel.ref.length == 0) {
                string = relatedMatterModel.systemNo;
                label = @"File No";
            } else {
                string = [NSString stringWithFormat:@"%@(%@)", relatedMatterModel.systemNo, relatedMatterModel.ref];
                label = @"File No(Ref 2)";
            }
            [cell configureCellWithContact:label text:string];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 1) {
            [cell configureCellWithContact:@"Client" text:relatedMatterModel.clientName];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 2) {
            NSString* value = [NSString stringWithFormat:@"%@ / %@ / %@", [DIHelpers getOnlyDateFromDateTime:relatedMatterModel.openDate], relatedMatterModel.fileStatus.descriptionValue, relatedMatterModel.dateClose];
            [cell configureCellWithContact:@"Open Date / Status / Closed Date" text:value];
        } else if (indexPath.row == 3) {
            NSString* value = [NSString stringWithFormat:@"%@ / %@ / %@", relatedMatterModel.locationPhysical, relatedMatterModel.locationBox, relatedMatterModel.locationPocket];
            [cell configureCellWithContact:@"File Location / Box / Pocket" text:value];
        } else if (indexPath.row == 4) {
            [cell configureCellWithContact:@"Matter" text:relatedMatterModel.matter.matterDescription];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 5) {
            NSString *string = [NSString stringWithFormat:@"%@ / %@ / %@", relatedMatterModel.partner.nickName, relatedMatterModel.legalAssistant.nickName, relatedMatterModel.clerk.nickName];
            [cell configureCellWithContact:@"Partner / LA / Clerk" text:string];
        }
    } else if (indexPath.section == 1) { // Court Case information
        if (indexPath.row == 0) {
            [cell configureCellWithContact:@"Court" text:relatedMatterModel.court.court];
        } else if (indexPath.row == 1) {
            [cell configureCellWithContact:@"Place" text:relatedMatterModel.court.place];
        } else if (indexPath.row == 2) {
            [cell configureCellWithContact:@"Case No" text: relatedMatterModel.court.caseNumber];
        } else if (indexPath.row == 3) {
            [cell configureCellWithContact:@"Judge" text:relatedMatterModel.court.judge];
        } else if (indexPath.row == 4) {
            [cell configureCellWithContact:@"SAR" text:relatedMatterModel.court.SAR];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.section == 2) { // Party Group
        NSDictionary* partySectionInfo = [self getPartySectionInfo:(int)indexPath.row];
        PartyGroupModel* partyGroup = relatedMatterModel.partyGroupArray[[[partySectionInfo objectForKey:@"group"] integerValue]];
        ClientModel* party = partyGroup.partyArray[[[partySectionInfo objectForKey:@"party"] integerValue]];
        if ([[partySectionInfo objectForKey:@"party"] integerValue] == 0) {
            ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContactCell cellIdentifier] forIndexPath:indexPath];
           [cell configureCellWithContact:partyGroup.partyGroupName text:party.name];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        } else {
            CommonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[CommonTextCell cellIdentifier] forIndexPath:indexPath];
            [cell configureCellWithString:party.name];
            cell.valueLabel.font = [UIFont fontWithName:@"SFUIText-Light" size:13];
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
             return cell;
        }
    } else if (indexPath.section == 3) { // Solicitor
        ThreeFieldsCell *cell = [tableView dequeueReusableCellWithIdentifier:[ThreeFieldsCell cellIdentifier] forIndexPath:indexPath];
        SolicitorGroup* solicitorGroup = relatedMatterModel.solicitorGroupArray[indexPath.row];
        [cell configureCellWithValue1:solicitorGroup.solicitorGroupName value2:solicitorGroup.solicitorName value3:solicitorGroup.solicitorReference];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else if (indexPath.section == 4) { //Property
        PropertyModel* propertyModel = relatedMatterModel.propertyGroupArray[indexPath.row];
       MatterPropertyCell* cell = [tableView dequeueReusableCellWithIdentifier:[MatterPropertyCell cellIdentifier] forIndexPath:indexPath];
        [cell configureCellWithFullTitle:propertyModel.fullTitle withAddress:propertyModel.address inNumber:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else if (indexPath.section == 5) { // Bank
        BankGroupModel* bankGroupModel = relatedMatterModel.bankGroupArray[indexPath.row];
        [cell configureCellWithContact:bankGroupModel.bankGroupName text:bankGroupModel.bankName];
        if (bankGroupModel.bankName.length != 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.section == 6) { // Important RM
        GeneralGroup* RMGroup = relatedMatterModel.RMGroupArray[indexPath.row];
        [cell configureCellWithContact:RMGroup.label text:RMGroup.value];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.section == 7) { // Important Date
        GeneralGroup* dateGroup = relatedMatterModel.dateGroupArray[indexPath.row];
        [cell configureCellWithContact:dateGroup.label text:[DIHelpers convertDateToCustomFormat:dateGroup.value]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.section == 8) { // TextGroup Information
        GeneralGroup* otherInfo = relatedMatterModel.textGroupArray[indexPath.row];
        [cell configureCellWithContact:otherInfo.label text:otherInfo.value];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.section == 9) { // Other Information
        
        MatterLastCell *cell = [tableView dequeueReusableCellWithIdentifier:[MatterLastCell cellIdentifier] forIndexPath:indexPath];
        
        cell.matterLastCellDelegate = self;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }

    return cell;
}

#pragma mark - LastTableCellDelegate
- (void) didTapFileFolder:(MatterLastCell *)cell
{
    if (isLoading) return;
    isLoading = YES;
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self);
    [[QMNetworkManager sharedManager]loadDocumentWithCode:relatedMatterModel.systemNo completion:^(DocumentModel * _Nonnull documentModel, NSError * _Nonnull error) {
        @strongify(self);
        self->isLoading = false;
        [SVProgressHUD dismiss];
        if (error == nil) {
            [self performSegueWithIdentifier:kDocumentSearchSegue sender:documentModel];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) didTapAccounts:(MatterLastCell *)cell
{
    if (isLoading) return;
    isLoading = YES;
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self);
    [[QMNetworkManager sharedManager] loadLedgerWithCode:self.relatedMatterModel.systemNo completion:^(NewLedgerModel * _Nonnull newLedgerModel, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = false;
        [SVProgressHUD dismiss];
        if (error == nil) {
            [self performSegueWithIdentifier:kLedgerSearchSegue sender:newLedgerModel];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kAddPropertySegue]){
        UINavigationController* navC = segue.destinationViewController;
        AddPropertyViewController* propertyVC = [navC viewControllers].firstObject;
        propertyVC.propertyModel = sender;
        propertyVC.viewType = @"view";
    }
    
    if ([segue.identifier isEqualToString:kLedgerSearchSegue]){
        LedgerViewController* ledgerVC = segue.destinationViewController;
        ledgerVC.ledgerModel = sender;
        ledgerVC.previousScreen = @"Matter";
        ledgerVC.matterCode = relatedMatterModel.systemNo;
    }
    
    if ([segue.identifier isEqualToString:kBankSearchSegue]){
        BankViewController* bankVC = segue.destinationViewController;
        bankVC.bankModel = sender;
        bankVC.previousScreen = @"Back";
    }
    
    if ([segue.identifier isEqualToString:kContactSearchSegue]){
        ContactViewController* contactVC = segue.destinationViewController;
        contactVC.contactModel = sender;
        contactVC.previousScreen = @"Back";
    }
    
    if ([segue.identifier isEqualToString:kLegalFirmSearchSegue]){
        LegalFirmViewController* legalFirmVC = segue.destinationViewController;
        legalFirmVC.legalFirmModel = sender;
        legalFirmVC.previousScreen = @"Back";
    }
    
    if ([segue.identifier isEqualToString:kDocumentSearchSegue]){
        DocumentViewController* documentVC = segue.destinationViewController;
        documentVC.documentModel = sender;
        documentVC.previousScreen = @"Back";
    }
    
    if ([segue.identifier isEqualToString:kMatterCodeSegue]){
        SearchMatterCodeDetail* vc = segue.destinationViewController;
        vc.model = sender;
    }
}

@end
