//
//  MessageViewController.m
//  Denning
//
//  Created by DenningIT on 04/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MessageViewController.h"
#import "QMDialogsViewController.h"
#import "DenningContactViewController.h"
#import "QMNewMessageViewController.h"
#import "GroupChatsViewController.h"
#import "FavContactViewController.h"
#import "MainTabBarController.h"
#import "DenningSupportViewController.h"

typedef NS_ENUM(NSInteger, DIChatTabIndex) {
    DIChatRecentTab,
    DIChatFavoriteTab,
    DIChatGroupTab,
    DIChatStaffTab
};

@interface MessageViewController ()
{
    NSInteger   selectedIndex;
    BOOL isRecentShow;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarHeightContraint;
@property (weak, nonatomic) IBOutlet UIView *myPageViwer;
@property (strong, nonatomic) NSArray* viewControllers;
@property (strong, nonatomic) NSArray* viewControllerIdentifiers;
@property (weak, nonatomic) IBOutlet MIBadgeButton *chatRecentBtn;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (weak, nonatomic) IBOutlet UIButton *groupChatBtn;
@property (weak, nonatomic) IBOutlet UIButton *staffBtn;

@property (strong, nonatomic) id observerWillEnterForeground;
@end

@implementation MessageViewController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillEnterForeground];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNotificationForRecentView];
    [self prepareUI];
    
    [self _recentTabClicked];
    selectedIndex = DIChatRecentTab;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerNotificationForRecentView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRecentView) name:SHOW_RECENT_VIEW object:nil];
}

- (void) showRecentView {
    isRecentShow = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isRecentShow) {
        [self _recentTabClicked];
        selectedIndex = DIChatRecentTab;
        isRecentShow = NO;
    }
    
    if (![DataManager sharedManager].isStaff && ![DataManager sharedManager].isDenningUser) {
        _topBarHeightContraint.constant = 0;
    } else {
        _topBarHeightContraint.constant = 44;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeTitle];
    [self configureBackBtnWithImageName:@"Back" withSelector:@selector(popupScreen:)];
    [self configureMenuRightBtnWithImagename:@"support" withSelector:@selector(denningSupport)];
 
    [self hideTabBar];
}

- (void) denningSupport {
    [self performSegueWithIdentifier:kDenningSupportSegue sender:nil];
}

- (void) updateBadge {
    NSArray* unreadDialogs = [[[QMCore instance].chatService.dialogsMemoryStorage unreadDialogs] mutableCopy];
    
    if (unreadDialogs.count == 0) {
        [DataManager sharedManager].badgeValue = nil;
    } else {
        [DataManager sharedManager].badgeValue = [NSString stringWithFormat:@"%ld", (unsigned long)unreadDialogs.count];
    }
    
    _chatRecentBtn.badgeString = [DataManager sharedManager].badgeValue;
    _chatRecentBtn.badgeTextColor = [UIColor whiteColor];
    _chatRecentBtn.badgeBackgroundColor = [UIColor redColor];
    CGSize size = _chatRecentBtn.frame.size;
    [_chatRecentBtn setBadgeEdgeInsets:UIEdgeInsetsMake(20, 0, 0, size.width/2 - 18)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBadge" object:nil];
}

- (void) changeTitle {
    self.tabBarController.navigationItem.titleView = nil;
    self.tabBarController.navigationItem.title = @"Denning Chats";
}

- (void) prepareUI
{
    [self configureBackBtnWithImageName:nil withSelector:@selector(popupScreen:)];
    
    self.viewControllerIdentifiers = @[@"DenningContactViewController", @"FavContactViewController",
        @"GroupChatsViewController", @"QMDialogsViewController"];
    
    QMDialogsViewController* recentVC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"QMDialogsViewController"];
    
    FavContactViewController *favVC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FavContactViewController"];
    
    GroupChatsViewController *groupVC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupChatsViewController"];
    
    DenningContactViewController *denningContactVC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"DenningContactViewController"];
    self.viewControllers = @[recentVC, favVC, groupVC, denningContactVC];
    
    self.navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_chat"];
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_chat_selected"];
    
    @weakify(self)
    
    self.observerWillEnterForeground = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull __unused note)
     {
         @strongify(self);
         [self hideTabBar];
     }];
}

- (IBAction)didTapCompanyList:(id)sender {
    NSLog(@"asdfooooooasdf");
}

- (void) setDefaultImageForButtons {
    [self.chatRecentBtn setImage:[UIImage imageNamed:@"icon_message"] forState:UIControlStateNormal];
    [self.favoriteBtn setImage:[UIImage imageNamed:@"icon_favorite"] forState:UIControlStateNormal];
    [self.staffBtn setImage:[UIImage imageNamed:@"icon_contact"] forState:UIControlStateNormal];
    [self.groupChatBtn setImage:[UIImage imageNamed:@"icon_group"] forState:UIControlStateNormal];
}

- (IBAction)recentTabClicked:(id)sender {
    if (selectedIndex == DIChatRecentTab) return;
    [self _recentTabClicked];
    [self removeView:self.viewControllers[selectedIndex]];
    selectedIndex = DIChatRecentTab;
}

- (void) _recentTabClicked {
    [self addView:self.viewControllers[DIChatRecentTab]];
    [(QMNavigationController*)self.navigationController dismissNotificationPanel];
    [self setDefaultImageForButtons];
    [self.chatRecentBtn setImage:[UIImage imageNamed:@"icon_message_selected"] forState:UIControlStateNormal];
}

- (IBAction)favoriteTabClicked:(id)sender {
    if (selectedIndex == DIChatFavoriteTab) return;
    
    [self addView:self.viewControllers[DIChatFavoriteTab]];
    [self removeView:self.viewControllers[selectedIndex]];
    selectedIndex = DIChatFavoriteTab;
    [self setDefaultImageForButtons];
    [self.favoriteBtn setImage:[UIImage imageNamed:@"icon_favorite_selected"] forState:UIControlStateNormal];
}

- (IBAction)groupTabClicked:(id)sender {
    if (selectedIndex == DIChatGroupTab) return;
    
    [self addView:self.viewControllers[DIChatGroupTab]];
    [self removeView:self.viewControllers[selectedIndex]];
    selectedIndex = DIChatGroupTab;
    [self setDefaultImageForButtons];
    [self.groupChatBtn setImage:[UIImage imageNamed:@"icon_group_selected"] forState:UIControlStateNormal];
}

- (IBAction)staffTabClicked:(id)sender {
    if (selectedIndex == DIChatStaffTab) return;
    [self addView:self.viewControllers[DIChatStaffTab]];
    [self removeView:self.viewControllers[selectedIndex]];
    selectedIndex = DIChatStaffTab;
    [self setDefaultImageForButtons];
    [self.staffBtn setImage:[UIImage imageNamed:@"icon_contact_selected"] forState:UIControlStateNormal];
}

- (void) addView: (UIViewController*) viewController
{
    [self addChildViewController:viewController];
    [self.myPageViwer addSubview:viewController.view];
    viewController.view.frame = CGRectMake(0, 0, self.myPageViwer.frame.size.width, self.myPageViwer.frame.size.height);
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [viewController didMoveToParentViewController:self];
}

- (void) removeView: (UIViewController*) viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
