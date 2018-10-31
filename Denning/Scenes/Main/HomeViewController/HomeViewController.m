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
#import "QMChatVC.h"
#import "FolderViewController.h"
#import "MainTabBarController.h"

@interface HomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate,
    UITextFieldDelegate,
iCarouselDataSource, iCarouselDelegate>
{
    BOOL hideCells;
    BOOL isAdsLoaded;
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
    if ([((UINavigationController*)[self.tabBarController selectedViewController]).topViewController isKindOfClass:[HomeViewController class]]) {
        if ([self tabBarIsVisible] == YES) return;
        
        CGRect frame = self.tabBarController.tabBar.frame;
        CGFloat height = frame.size.height;
        CGFloat offsetY = -height;
        
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    }
}

//Getter to know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

- (void) changeUIBasedOnUserType {
    CGFloat branchHeight = 50;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat searchBarHeight = 56;
    CGFloat bottomBarHeight = self.tabBarController.tabBar.frame.size.height;
    if ([DataManager sharedManager].isStaff) {
        branchHeight = 50;
        homeIconArray = @[@"icon_news", @"icon_real_estate", @"icon_market", @"icon_services", @"icon_calculator", @"icon_jobs", @"icon_forum", @"icon_products", @"icon_shared", @"icon_upload", @"icon_calendar", @"icon_topup"];
        homeLabelArray = @[@"News", @"Property", @"Market", @"Services", @"Calculators", @"Jobs", @"Forum", @"Products", @"Shared", @"Upload", @"Calendar", @"Top-Up"];
    } else {
        branchHeight = 0;
        homeIconArray = @[@"icon_news", @"icon_calculator",  @"icon_forum", @"icon_products", @"icon_shared", @"icon_upload"];
        homeLabelArray = @[@"News", @"Calculators", @"Forum", @"Products", @"Shared",  @"Upload"];
    }
    
    CGFloat menuContainerHeight = (self.view.frame.size.width/4-2) * (homeLabelArray.count/4);
    CGFloat intrinsicHeight = self.view.frame.size.height   - navHeight - branchHeight - searchBarHeight - bottomBarHeight;
    
    _heightOfCarousel.constant = intrinsicHeight - MAX(menuContainerHeight, intrinsicHeight/2);
    _branchHeightContraint.constant = branchHeight;
    [self.collectionView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(showTabBar) withObject:nil afterDelay:1.0f];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeTitle];
    
    [self configureBackBtnWithImageName:@"icon_user" withSelector:@selector(gotoLogin)];
    [self configureMenuRightBtnWithImagename:@"icon_menu" withSelector:@selector(gotoMenu)];
    
    [self displayBranchInfo];
    [self changeUIBasedOnUserType];
    [(MainTabBarController*)self.tabBarController updateBadge];
}

- (void) loadsAds {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[QMNetworkManager sharedManager] getAdsWithCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        _carousel.type = iCarouselTypeLinear;
        _carousel.pagingEnabled = YES;
        sliderCount = 0;
        
        self.carouselTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(runMethod) userInfo:nil repeats:YES];
        
        _items = [result mutableCopy];
        if (_items.count > 0) {
            isAdsLoaded = true;
        }
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
                                             [self performSelector:@selector(showTabBar) withObject:nil afterDelay:1.0f];
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
    if (![DataManager sharedManager].isStaff) {
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

- (IBAction)tapAds:(id)sender {
    if (!isAdsLoaded) return;
    
    [self gotoAdsURL:0];
}

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

- (void) gotoAdsURL: (NSInteger) index{
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

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
//    [self gotoAdsURL:index];
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

- (BOOL) showSessionExpireAlertAndLogin {
    if ([DataManager sharedManager].isSessionExpired == YES) {
        [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_SESSION_EXPIRED", nil) withTitle:@"Warning" actionSuccess:NO inViewController:[DIHelpers topMostController] withCallback:^{
            [self performSegueWithIdentifier:kAuthSegue sender:nil];
        }];
        return NO;
    }
    
    return YES;
}

- (BOOL) gotoSearchView {
    if (![self showSessionExpireAlertAndLogin]) {
        return NO;
    }
    
    [self performSegueWithIdentifier:kMainSearchSegue sender:nil];
    return NO;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return [self gotoSearchView];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return [self gotoSearchView];
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

#pragma mark -
#pragma mark UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self showSessionExpireAlertAndLogin]) {
        return;
    }
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    NSString* menu = homeLabelArray[indexPath.row];
    if ([menu isEqualToString:@"News"]) {
        [self getLatestNewsWithCompletion:^(NSArray *array) {
            [self performSegueWithIdentifier:kNewsSegue sender:array];
        }];
    } else if ([menu isEqualToString:@"Property"]) {
        [self showComingSoon];
    } else if ([menu isEqualToString:@"Market"]) {
        [self showComingSoon];

    } else if ([menu isEqualToString:@"Services"]) {
        [self showComingSoon];
        
    } else if ([menu isEqualToString:@"Calculators"]) {
        [self performSegueWithIdentifier:kCalculateSegue sender:nil];
    } else if ([menu isEqualToString:@"Calculators"]) {
        [self performSegueWithIdentifier:kCalculateSegue sender:nil];
    } else if ([menu isEqualToString:@"Shared"]) {
        [self getSharedFolder];
    } else if ([menu isEqualToString:@"Forum"]) {
        [self showComingSoon];
    } else if ([menu isEqualToString:@"Products"]) {
        [self showComingSoon];
    } else if ([menu isEqualToString:@"Jobs"]) {
        [self showComingSoon];
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
        [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ACCESS_DENIED_REGISTER", nil) withTitle:@"Access Restricted" actionSuccess:NO inViewController:self withCallback:^{
            [self performSegueWithIdentifier:kAuthSegue sender:nil];
        }];
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
        [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ACCESS_RESTRICT_CLIENT", nil) withTitle:@"Access Restricted" actionSuccess:NO inViewController:self];
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
    } else if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMNavigationController *chatNavigationController = segue.destinationViewController;
        chatNavigationController.currentAdditionalNavigationBarHeight =
        [(QMNavigationController *)self.navigationController currentAdditionalNavigationBarHeight];
        
        QMChatVC *chatViewController = (QMChatVC *)chatNavigationController.topViewController;
        chatViewController.chatDialog = sender;
    } 
}


@end
