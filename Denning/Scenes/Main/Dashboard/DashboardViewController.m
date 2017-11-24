//
//  DashboardViewController.m
//  Denning
//
//  Created by DenningIT on 20/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DashboardViewController.h"
#import "MainTabBarController.h"
#import "DashboardTodayCell.h"
#import "DashboardFirstCell.h"
#import "DashboardSecondCell.h"
#import "DashboardSecondHeaderCell.h"
#import "DashboardThirdCell.h"
#import "DashboardThirdHeaderCell.h"
#import "DashboardForthCell.h"

#import "DashboardContact.h"
#import "DashboardFileListing.h"
#import "DashboardDueTask.h"
#import "DashboarMyDueTask.h"
#import "ViewDepositCollection.h"
#import "BankRecon.h"
#import "FileLedger.h"
#import "BankAndCashBalance.h"
#import "TrialBalance.h"
#import "TaxInvoice.h"
#import "FeesTransfer.h"
#import "ProfitAndLoss.h"
#import "StaffOnline.h"
#import "DashboardAttendance.h"
#import "FeeAndMatterGrowth.h"
#import "CompletionDateTracking.h"
#import "DashboardFileListing.h"
#import "EventViewController.h"
#import "StaffLeaveViewController.h"

@interface DashboardViewController ()
<UIDocumentInteractionControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, SWTableViewCellDelegate, UITabBarControllerDelegate>
{
    NSString *titleOfList;
    NSString* nameOfField;
    __block BOOL isLoading;
    __block BOOL isSaved;
}

@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSMutableArray *headers;

@property (strong, nonatomic) DashboardMainModel* mainModel;

@property (strong, nonatomic)
NSMutableDictionary* keyValue;

@end

@implementation DashboardViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self registerNib];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareUI {
    self.navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_overview"];
    
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
//    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void) addItemToContentsInIndex: (NSNumber*) index withItem: (NSArray*) item
{
    NSMutableArray* newConents = [NSMutableArray new];
    if (_contents.count == 0) {
        [newConents addObjectsFromArray:item];
    } else {
        BOOL isAdded = NO;
        for (NSArray* obj in _contents) {
            if ([obj[0] integerValue] == [index integerValue]) {
                isAdded = YES;
                [newConents addObjectsFromArray:item];
            } else {
                [newConents addObjectsFromArray:@[obj]];
            }
        }
        if (!isAdded) {
            [newConents addObjectsFromArray:item];
        }
    }

    _contents = [newConents mutableCopy];
}

- (void) makeHeaders:(NSArray*) main {
    _headers = [NSMutableArray new];
    for (VisibleModel* obj in main) {
        if ([obj.isVisible integerValue] == 1) {
            [_headers addObject:obj];
        }
    }
}

- (void) getMainDashboardWithCompletion: (void(^)(void)) completion
{
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] getDashboardMainWithCompletion:^(DashboardMainModel * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
            self.mainModel = result;
            
            if (completion != nil) {
                completion();
            }
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
    }];
}

- (void) changeTitle {
    self.tabBarController.navigationItem.titleView = nil;
    self.tabBarController.navigationItem.title = @"DASHBOARD";
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self setTabBarVisible:YES animated:NO completion:nil];
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self hideTabBar];
    [self configureBackBtnWithImageName:@"Back" withSelector:@selector(popupScreen:)];
    [self changeTitle];
    
    [self getMainDashboardWithCompletion:^{
        [self.collectionView reloadData];
    }];
}

- (void) hideTabBar {
    [self setTabBarVisible:NO animated:YES completion:^(BOOL finished) {
    }];
}

- (void) showTabBar {
    @weakify(self);
    [self setTabBarVisible:YES animated:YES completion:^(BOOL finished) {
        @strongify(self)
        [self performSelector:@selector(hideTabBar) withObject:nil afterDelay:2.0];
    }];
}

//Getter to know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
    
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.0 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

- (void) configureBackBtnWithImageName:(NSString*) imageName withSelector:(SEL) action {
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:action];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.tabBarController.navigationItem setLeftBarButtonItems:@[backButtonItem] animated:YES];
}

- (void) popupScreen:(id)sender {
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[0];
    
    [self configureBackBtnWithImageName:@"icon_user" withSelector:@selector(gotoLogin)];
}

- (void) gotoMenu {
    MainTabBarController *mainTabBarController = (MainTabBarController*)self.tabBarController;
    [mainTabBarController tapMenu:nil];
}

- (void) gotoLogin {
    MainTabBarController *mainTabBarController = (MainTabBarController*)self.tabBarController;
    [mainTabBarController tapLogin:nil];
}

- (void) registerNib {
    [self.collectionView registerNib:[UINib nibWithNibName:@"DashboardTodayCell" bundle:nil] forCellWithReuseIdentifier:@"DashboardTodayCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DashboardFirstCell" bundle:nil] forCellWithReuseIdentifier:@"DashboardFirstCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DashboardSecondCell" bundle:nil] forCellWithReuseIdentifier:@"DashboardSecondCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DashboardSecondHeaderCell" bundle:nil] forCellWithReuseIdentifier:@"DashboardSecondHeaderCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DashboardThirdCell" bundle:nil] forCellWithReuseIdentifier:@"DashboardThirdCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DashboardThirdHeaderCell" bundle:nil] forCellWithReuseIdentifier:@"DashboardThirdHeaderCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DashboardForthCell" bundle:nil] forCellWithReuseIdentifier:@"DashboardForthCell"];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 5;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (section == 0) {
        count = 1;
    } else if (section == 1) {
        count = _mainModel.s1.items.count;
    } else if (section == 2) {
        count = _mainModel.s2.items.count + 1;
    } else if (section == 3) {
        count = _mainModel.s3.items.count + 1;
    } else if (section == 4) {
        count = _mainModel.s4.items.count;
    }
    
    return count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DashboardTodayCell* cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"DashboardTodayCell" forIndexPath:indexPath];
        cell.today.text = [DIHelpers convertDateToCustomFormat:_mainModel.today];
        return cell;
    } else if (indexPath.section == 1) {
        DashboardFirstCell* cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"DashboardFirstCell" forIndexPath:indexPath];
        [cell configureCellWithModel:_mainModel.s1.items[indexPath.row]];
        return cell;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            DashboardSecondHeaderCell* cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"DashboardSecondHeaderCell" forIndexPath:indexPath];
            cell.headerLabel.text = _mainModel.s2.title;
            return cell;
        } else {
            DashboardSecondCell* cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"DashboardSecondCell" forIndexPath:indexPath];
            [cell configurecellWithModel:_mainModel.s2.items[indexPath.row-1]];
            return cell;
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            DashboardThirdHeaderCell* cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"DashboardThirdHeaderCell" forIndexPath:indexPath];
            cell.headerLabel.text = _mainModel.s3.title;
            return cell;
        } else {
            DashboardThirdCell* cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"DashboardThirdCell" forIndexPath:indexPath];
            ThirdItemModel* model = _mainModel.s3.items[indexPath.row-1];
            cell.centerValue.text = model.label;
            cell.badgeValue.text = model.value;
            
            return cell;
        }
    } else if (indexPath.section == 4) {
        DashboardForthCell* cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"DashboardForthCell" forIndexPath:indexPath];
        FirstItemModel* model = _mainModel.s4.items[indexPath.row];
        cell.topLabel.text = model.title;
        cell.topLabel.textColor = [UIColor colorWithHexString:model.titleColor];
        cell.bottomImage.image = [UIImage imageNamed:model.icon];
        cell.backgroundColor = [UIColor colorWithHexString:model.background];
        
        return cell;
    }
   
    return nil;
}

#pragma mark -
#pragma mark UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width, height;
    
    if (indexPath.section == 0) {
        width = self.collectionView.frame.size.width;
        height = 50;
    } else if (indexPath.section == 1){
        width = height = self.collectionView.frame.size.width/3-2;
    } else if (indexPath.section == 2){
       width = self.collectionView.frame.size.width;
        if (indexPath.row == 0) {
            height = 60;
        } else {
            height = 33;
        }
    } else if (indexPath.section == 3){
        if (indexPath.row == 0) {
            width = self.collectionView.frame.size.width;
            height = 40;
        } else {
            width = height =self.collectionView.frame.size.width/4-1;
        }
    } else {
        width = height =self.collectionView.frame.size.width/3-1;
    }
    return CGSizeMake(width, height);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 1.0;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}


- (void) geteventsArrayWithCompletion: (void (^)(NSArray* array))completion
{
    if (isLoading) return;
    isLoading = YES;
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self)
    [[QMNetworkManager sharedManager] getLatestEventWithStartDate:[DIHelpers today] endDate:[DIHelpers today] filter:@"1court" search:@"" page:@(1) withCompletion:^(NSArray * _Nonnull eventsArray, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            if (completion != nil) {
                completion(eventsArray);
            }
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:kFileListingSegue sender:_mainModel.s1.items[indexPath.row].mainAPI];
        } else if (indexPath.row == 1) {
            [self geteventsArrayWithCompletion:^(NSArray *array) {
                [self performSegueWithIdentifier:kEventSegue sender:array];
            }];
        } else if (indexPath.row == 2){
            [self performSegueWithIdentifier:kMyDueTaskSegue sender:_mainModel.s1.items[indexPath.row]];
        } else if (indexPath.row == 3){
            [self performSegueWithIdentifier:kStaffLeaveSegue sender:_mainModel.s1.items[indexPath.row].mainAPI];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row > 0) {
            [self performSegueWithIdentifier:kDashboardCollectionSegue sender:_mainModel.s2.items[indexPath.row - 1]];
        }
    } else if (indexPath.section == 3)
        {
        [self performSegueWithIdentifier:kCompletionTrackingSegue sender:_mainModel.s3.items[indexPath.row-1]];
    } else if (indexPath.section == 4) {
        NSString* url = _mainModel.s4.items[indexPath.row].mainAPI;
        if (indexPath.row == 0) {
           [self performSegueWithIdentifier:kContactGetListSegue sender:url];
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:kBankReconSegue sender:url];
        } else if (indexPath.row == 2) {
            [self performSegueWithIdentifier:kDueTaskSegue sender:_mainModel.s1.items[indexPath.row].mainAPI];
        } else if (indexPath.row == 3) {
            [self performSegueWithIdentifier:kFileLedgerSegue sender:url];
        } else if (indexPath.row == 4) {
            [self performSegueWithIdentifier:kBankAndCashBalanceSegue sender:url];
        } else if (indexPath.row == 5) {
            [self performSegueWithIdentifier:kTrialBalanceSegue sender:url];
        } else if (indexPath.row == 6) {
            [self performSegueWithIdentifier:kTaxInvoiceSegue sender:url];
        } else if (indexPath.row == 7) {
            [self performSegueWithIdentifier:kFeesTransferSegue sender:url];
        } else if (indexPath.row == 8) {
            [self performSegueWithIdentifier:kProfitLossSegue sender:url];
        } else if (indexPath.row == 9) {
            [self performSegueWithIdentifier:kStaffOnlineSegue sender:url];
        } else if (indexPath.row == 10) {
            [self performSegueWithIdentifier:kAttendanceSegue sender:url];
        } else if (indexPath.row == 11) {
            [self performSegueWithIdentifier:kFeeMatterGrowthSegue sender:url];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kFileListingSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        DashboardFileListing* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kEventSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        EventViewController* eventVC = nav.viewControllers.firstObject;
        eventVC.originalArray = sender;
    }
    
    if ([segue.identifier isEqualToString:kDueTaskSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        DashboardDueTask* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kMyDueTaskSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        DashboarMyDueTask* vc = nav.viewControllers.firstObject;
        vc.url = ((FirstItemModel*)sender).mainAPI;
    }
    
    if ([segue.identifier isEqualToString:kCompletionTrackingSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        CompletionDateTracking* vc = nav.viewControllers.firstObject;
        vc.url = ((ThirdItemModel*)sender).api;
        vc.selHeaderId = ((ThirdItemModel*)sender).itemID;
    }
    
    if ([segue.identifier isEqualToString:kDashboardCollectionSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        ViewDepositCollection* vc = nav.viewControllers.firstObject;
        vc.url = ((SecondItemModel*)sender).api;
        vc.selectedID = ((SecondItemModel*)sender).itemId;
        vc.secondItem = sender;
    }
    
    if ([segue.identifier isEqualToString:kContactGetListSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        DashboardContact* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kBankReconSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        BankRecon* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kFileLedgerSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        FileLedger* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kBankAndCashBalanceSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        BankAndCashBalance* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kTrialBalanceSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        TrialBalance* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kFeesTransferSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        FeesTransfer* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }

    if ([segue.identifier isEqualToString:kProfitLossSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        ProfitAndLoss* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kStaffOnlineSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        StaffOnline* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kTaxInvoiceSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        TaxInvoice* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }

    if ([segue.identifier isEqualToString:kAttendanceSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        DashboardAttendance* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    }
    
    if ([segue.identifier isEqualToString:kFeeMatterGrowthSegue]) {
        UINavigationController* nav = segue.destinationViewController;
        FeeAndMatterGrowth* vc = nav.viewControllers.firstObject;
        vc.url = sender;
    } else if ([segue.identifier isEqualToString:kStaffLeaveSegue]) {
        StaffLeaveViewController* vc = segue.destinationViewController;
        vc.url = sender;
    }

}

@end
