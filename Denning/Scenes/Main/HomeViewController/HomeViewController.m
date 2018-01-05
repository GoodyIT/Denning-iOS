//
//  HomeViewController.m
//  Denning
//
//  Created by DenningIT on 01/02/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "HomeViewController.h"
#import "NewsCell.h"
#import "EventCell.h"
#import "CalculatorSelectionViewController.h"
#import "EventViewController.h"
#import "NewsViewController.h"
#import "UpdateViewController.h"
#import "BranchViewController.h"
#import "DenningLabelCell.h"
#import "UITextField+LeftView.h"
#import "MenuCell.h"
#import "ChangeBranchViewController.h"
#import "MainTabBarController.h"
#import "Attendance.h"
#import "QMChatVC.h"
#import "FolderViewController.h"

@interface HomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate,
    UITextFieldDelegate,
iCarouselDataSource, iCarouselDelegate>
{
    BOOL hideCells;
    NSArray* homeIconArray;
    NSArray* homeLabelArray;
    __block BOOL isLoading;
    NSInteger sliderCount;
    
    CGSize adsSize;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *headerWrapper;
@property (weak, nonatomic) IBOutlet UILabel *firmName;
@property (weak, nonatomic) IBOutlet UILabel *firmCity;

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (strong, nonatomic) NSTimer *carouselTimer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfCarousel;
@property (nonatomic, strong) NSMutableArray<AdsModel*> *items;
@property (weak, nonatomic) IBOutlet UITextField_LeftView *searchTextField;
@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *branchHeightContraint;

@property (strong, nonatomic) id observerWillEnterForeground;

@end

@implementation HomeViewController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillEnterForeground];
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self loadsAds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showTabBar {
    [self setTabBarVisible:YES animated:NO completion:nil];
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
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

- (void) changeUIBasedOnUserType {
    CGFloat branchHeight = 50;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat searchBarHeight = 56;
    CGFloat bottomBarHeight = self.tabBarController.tabBar.frame.size.height;
    if ([DataManager sharedManager].isStaff) {
        branchHeight = 50;
        homeIconArray = @[@"icon_news", @"icon_updates", @"icon_market", @"icon_delivery", @"icon_calculator", @"icon_shared", @"icon_forum", @"icon_products", @"icon_attendance", @"icon_upload", @"icon_calendar", @"icon_topup"];
        homeLabelArray = @[@"News", @"Updates", @"Market", @"Delivery", @"Calculators", @"Shared", @"Forum", @"Products", @"Attendance", @"Upload", @"Calendar", @"Top-Up"];
    } else {
        branchHeight = 0;
        homeIconArray = @[@"icon_news", @"icon_calculator", @"icon_shared", @"icon_forum", @"icon_products",  @"icon_upload"];
        homeLabelArray = @[@"News", @"Calculators", @"Shared", @"Forum", @"Products", @"Upload",];
    }
    
    CGFloat menuContainerHeight = (self.view.frame.size.width/4-2) * (homeLabelArray.count/4);
    CGFloat intrinsicHeight = self.view.frame.size.height  - statusBarHeight - navHeight - branchHeight - searchBarHeight - bottomBarHeight;
    
    _heightOfCarousel.constant = intrinsicHeight - MAX(menuContainerHeight, intrinsicHeight/2);
    _branchHeightContraint.constant = branchHeight;
    [self.collectionView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showTabBar];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeTitle];
    
    [self configureBackBtnWithImageName:@"icon_user" withSelector:@selector(gotoLogin)];
    [self configureMenuRightBtnWithImagename:@"icon_menu" withSelector:@selector(gotoMenu)];
    [self changeUIBasedOnUserType];
    [self displayBranchInfo];
}

- (void) loadsAds {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[QMNetworkManager sharedManager] getAdsWithCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        _carousel.type = iCarouselTypeLinear;
        _carousel.pagingEnabled = YES;
        sliderCount = 0;
        
        self.carouselTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(runMethod) userInfo:nil repeats:YES];
        
        _items = [result mutableCopy];
        for (int i = 0; i < result.count; i++) {
            NSURL *URL = [NSURL URLWithString:
                          [NSString stringWithFormat:@"data:application/octet-stream;base64,%@",
                           _items[i].imgData]];
            NSData* imageData = [NSData dataWithContentsOfURL:URL];
            UIImage* image = [UIImage imageNamed:@"law-firm.jpg"];
            if (imageData != nil) {
                image = [UIImage imageWithData:imageData];
            }
            _items[i].image = image;
        }
        
        [_carousel reloadData];
    }];
}

- (void) changeTitle {
    UIImage *img = [UIImage imageNamed:@"denning_logo"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 30, 30)];
    [imgView setImage:img];
    // setContent mode aspect fit
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.tabBarController.navigationItem.titleView = imgView;
    
    self.navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_home"];
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_home_selected"];
}

- (void) displayBranchInfo {
    self.firmName.text = [DataManager sharedManager].user.firmName;
    self.firmCity.text = [DataManager sharedManager].user.firmCity;
}

- (void) prepareUI
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
   
    
    
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* searchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search_gray"]];
    self.searchTextField.leftView = searchImageView;
    
    UITapGestureRecognizer *branchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBranch:)];
    branchTap.numberOfTapsRequired = 1;
    [self.headerWrapper addGestureRecognizer:branchTap];
    
    @weakify(self)
    self.observerWillEnterForeground = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                                                         object:nil
                                                                                          queue:nil
                                                                                     usingBlock:^(NSNotification * _Nonnull __unused note)
                                        {
                                            @strongify(self);
                                            [self showTabBar];
                                        }];
}

- (void) runMethod {
    [self.carousel scrollToItemAtIndex:sliderCount animated:YES];
    if(sliderCount == _items.count){
        sliderCount=0;
    }else{
        sliderCount++;
    }
}

- (void) alertAndLogin {
    [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ACCESS_DENIED_REGISTER", nil) withTitle:@"Access Restricted" actionSuccess:NO inViewController:self withCallback:^{
        [self performSegueWithIdentifier:kAuthSegue sender:nil];
    }];
}

- (IBAction)changeBranch:(id)sender {
    if ([DataManager sharedManager].isStaff) {
        [self alertAndLogin];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];

    [[QMNetworkManager sharedManager] userSignInWithEmail:[DataManager sharedManager].user.email password:[DataManager sharedManager].user.password withCompletion:^(BOOL success, NSError * _Nonnull error, NSInteger statusCode, NSDictionary* responseObject) {
        [SVProgressHUD dismiss];
        if (success){
           [[DataManager sharedManager] setUserInfoFromLogin:responseObject];
            if ([DataManager sharedManager].isStaff){
                 [self performSegueWithIdentifier:kChangeBranchSegue sender:[DataManager sharedManager].denningArray];
            } else if ([DataManager sharedManager].personalArray.count > 0) {
                [self performSegueWithIdentifier:kChangeBranchSegue sender:[DataManager sharedManager].personalArray];
            } else {
                [SVProgressHUD showErrorWithStatus:@"No more branches"];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:@"Only subscribed denning user can access it."];
        }
    }];
}


#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [_items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView *imageView = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIView alloc] initWithFrame:self.carousel.bounds];
        
        imageView = [[UIImageView alloc] initWithFrame:view.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = 1;
        [view addSubview:imageView];
    }
    else
    {
        //get a reference to the label in the recycled view
        imageView = (UIImageView *)[view viewWithTag:1];
    }
    
    imageView.image = _items[index].image;
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:_items[index].URL];
    
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:URL options:@{}
           completionHandler:^(BOOL success) {
               
           }];
    } else {
        [application openURL:URL];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return YES;
        }
        default:
        {
            return value;
        }
    }
}

#pragma mark - search

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self performSegueWithIdentifier:kMainSearchSegue sender:nil];
    return NO;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    [self performSegueWithIdentifier:kMainSearchSegue sender:nil];
    return NO;
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return homeIconArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCell" forIndexPath:indexPath];
    
    cell.centerLabel.text = homeLabelArray[[indexPath row]];
    cell.centerImageView.image = [UIImage imageNamed:homeIconArray[[indexPath row]]];;
    
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = self.collectionView.frame.size.width/4-2;
    return CGSizeMake(width, width);
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(1, 0, 1, 1);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 1.0;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (void) showComingSoon {
    [self performSegueWithIdentifier:kComingSoonSegue sender:nil];
//    [QMAlert showInformationWithMessage:@"Coming Soon. Thank you for your support." inViewController:self];
}

- (void) handleResponse:(AttendanceModel*) result error:(NSError*) error {
    if (!error) {
        [self performSegueWithIdentifier:kAttendanceSegue sender:result];
    } else {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeClear];
    }
}

- (void) getAttendance {
    if (![DataManager sharedManager].isStaff){
        [QMAlert showAlertWithMessage:@"This function is reserved for registered business user only." withTitle:@"RESTRICTED" actionSuccess:NO inViewController:self];
    } else if ([CLLocationManager locationServicesEnabled] == NO) {
        [(AppDelegate*)[UIApplication sharedApplication] showDeniedLocation];
    } else {
        [SVProgressHUD show];
        
        [[QMNetworkManager sharedManager] getAttendanceListWithCompletion:^(AttendanceModel * _Nonnull result, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            [self handleResponse:result error:error];
        }];
    }
}

#pragma mark -
#pragma mark UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    NSString* menu = homeLabelArray[indexPath.row];
    if ([menu isEqualToString:@"News"]) {
        [self getLatestNewsWithCompletion:^(NSArray *array) {
            [self performSegueWithIdentifier:kNewsSegue sender:array];
        }];
    } else if ([menu isEqualToString:@"Updates"]) {
        [self getLatestUpdatesWithCompletion:^(NSArray *array) {
            [self performSegueWithIdentifier:kUpdateSegue sender:array];
        }];
    } else if ([menu isEqualToString:@"Market"]) {
        [self showComingSoon];

    } else if ([menu isEqualToString:@"Delivery"]) {
        [self showComingSoon];
        
    } else if ([menu isEqualToString:@"Calculators"]) {
        [self performSegueWithIdentifier:kCalculateSegue sender:nil];
    } else if ([menu isEqualToString:@"Shared"]) {
        [self getSharedFolder];
    } else if ([menu isEqualToString:@"Forum"]) {
        [self showComingSoon];
        
    } else if ([menu isEqualToString:@"Products"]) {
        [self showComingSoon];
        
    } else if ([menu isEqualToString:@"Attendance"]) {
        [self getAttendance];
    } else if ([menu isEqualToString:@"Upload"]) {
        [self gotoUpload];
    } else if ([menu isEqualToString:@"Calendar"]) {
        [self gotoCalendar];
        
    } else if ([menu isEqualToString:@"Top-Up"]) {
        [self showComingSoon];
        
    }
    cell.backgroundColor = [UIColor whiteColor];
}

- (void) gotoCalendar {
    if ([DataManager sharedManager].isStaff){
        [self geteventsArrayWithCompletion:^(NSArray * array) {
            [self performSegueWithIdentifier:kEventSegue sender:array];
        }];
    } else {
        [QMAlert showAlertWithMessage:@"This function is reserved for registered business user only." withTitle:@"RESTRICTED" actionSuccess:NO inViewController:self];
    }
}

- (void) loginAndGotoBranch {
    if (isLoading) return;
    isLoading = YES;
    NSString* email = [DataManager sharedManager].user.email;
    NSString* password = [DataManager sharedManager].user.password;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    @weakify(self)
    [[QMNetworkManager sharedManager] userSignInWithEmail:email password:password withCompletion:^(BOOL success, NSError * _Nonnull error, NSInteger statusCode, NSDictionary * _Nonnull responseObject) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        if (success) {
            [[DataManager sharedManager] setSessionID:responseObject];
            
            [self performSegueWithIdentifier:kBranchSegue sender:[DataManager sharedManager].personalArray];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (BOOL) checkPossibility {
    if (![[DataManager sharedManager] isLoggedIn]) {
        [self alertAndLogin];
        return NO;
    }
    
    if (![[DataManager sharedManager] isClient]) {
        [QMAlert showAlertWithMessage:@"Sorry, only client can use this function" actionSuccess:NO inViewController:self];
        return NO;
    }
    return YES;
}

- (void) gotoUpload {
    if (![self checkPossibility]) {
        return;
    }
    
    [DataManager sharedManager].documentView = @"upload";
    [self loginAndGotoBranch];
}

- (void) getSharedFolder
{
    if (![self checkPossibility]) {
        return;
    }
    
    [DataManager sharedManager].documentView = @"shared";
    [self loginAndGotoBranch];
}

- (void) getLatestUpdatesWithCompletion: (void (^)(NSArray* array))completion
{
    if (isLoading) return;
    isLoading = YES;
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self);
    [[QMNetworkManager sharedManager] getLatestUpdatesWithCompletion:^(NSArray * _Nonnull updatesArray, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        @strongify(self);
        self->isLoading = NO;
        if (error == nil) {
            if (completion != nil) {
                completion(updatesArray);
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) getLatestNewsWithCompletion: (void (^)(NSArray* array))completion
{
    if (isLoading) return;
    isLoading = YES;
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self)
    [[QMNetworkManager sharedManager] getLatestNewsWithCompletion:^(NSArray * _Nonnull newsArray, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        @strongify(self)
        self->isLoading = NO;
        if (error == nil) {
            if (completion != nil) {
                completion(newsArray);
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqualToString:kEventSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        EventViewController* eventVC = navVC.viewControllers.firstObject;
        eventVC.originalArray = sender;
    } else if ([segue.identifier isEqualToString:kNewsSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        NewsViewController* newsVC = navVC.viewControllers.firstObject;
        newsVC.newsArray = sender;
    } else if ([segue.identifier isEqualToString:kUpdateSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        UpdateViewController* updatesVC = navVC.viewControllers.firstObject;
        updatesVC.updatesArray = sender;
    } else if ([segue.identifier isEqualToString:kBranchSegue]){
        UINavigationController* navVC = segue.destinationViewController;
        BranchViewController *branchVC = navVC.viewControllers.firstObject;
        branchVC.firmArray = sender;
    } else if ([segue.identifier isEqualToString:kChangeBranchSegue]){
        ChangeBranchViewController* changeBranchVC = segue.destinationViewController;
        changeBranchVC.branchArray = sender;
    } else if ([segue.identifier isEqualToString:kAttendanceSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        Attendance* vc = navVC.viewControllers.firstObject;
        vc.attendanceModel = sender;
    } else if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMNavigationController *chatNavigationController = segue.destinationViewController;
        chatNavigationController.currentAdditionalNavigationBarHeight =
        [(QMNavigationController *)self.navigationController currentAdditionalNavigationBarHeight];
        
        QMChatVC *chatViewController = (QMChatVC *)chatNavigationController.topViewController;
        chatViewController.chatDialog = sender;
    } 
}


@end
