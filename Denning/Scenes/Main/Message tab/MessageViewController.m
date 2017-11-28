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
//#import "ClientContactViewController.h"
#import "FavoriteViewController.h"
#import "MainTabBarController.h"

typedef NS_ENUM(NSInteger, DIChatTabIndex) {
    DIChatRecentTab,
    DIChatFavoriteTab,
    DIChatGroupTab,
    DIChatStaffTab,
    DIChatClientTab
};

@interface MessageViewController ()
{
    NSInteger   selectedIndex;
}

@property (weak, nonatomic) IBOutlet UIView *myPageViwer;
@property (strong, nonatomic) NSArray* viewControllers;
@property (strong, nonatomic) NSArray* viewControllerIdentifiers;
@property (weak, nonatomic) IBOutlet UIButton *chatRecentBtn;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (weak, nonatomic) IBOutlet UIButton *groupChatBtn;
@property (weak, nonatomic) IBOutlet UIButton *staffBtn;
@property (weak, nonatomic) IBOutlet UIButton *clientBtn;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self prepareUI];
    [self addView:self.viewControllers[0]];
    [self setDefaultImageForButtons];
    [self.chatRecentBtn setImage:[UIImage imageNamed:@"icon_message_selected"]
                        forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeTitle];
   
    [self configureBackBtnWithImageName:@"Back" withSelector:@selector(popupScreen:)];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
 
    [self hideTabBar];
}

- (void) changeTitle {
    self.tabBarController.navigationItem.titleView = nil;
    self.tabBarController.navigationItem.title = @"Chats";
}

- (void) prepareUI
{
    [self configureBackBtnWithImageName:nil withSelector:@selector(popupScreen:)];
    
    self.viewControllerIdentifiers = @[@"DenningContactViewController", @"FavoriteViewController",
        @"QMNewMessageViewController", @"QMDialogsViewController"];
    
    QMDialogsViewController* recentVC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"QMDialogsViewController"];
    
    FavoriteViewController *favVC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"FavoriteViewController"];
    
    QMNewMessageViewController *groupVC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"QMNewMessageViewController"];
    
    DenningContactViewController *denningContactVC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil] instantiateViewControllerWithIdentifier:@"DenningContactViewController"];
    self.viewControllers = @[recentVC, favVC, groupVC, denningContactVC];
    
    // Set the recent chat to default
    selectedIndex = DIChatRecentTab;
    [self.chatRecentBtn setImage:[UIImage imageNamed:@"icon_message_selected"] forState:UIControlStateNormal];
    
    self.navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_chat"];
    self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_chat_selected"];
}

- (IBAction)didTapCompanyList:(id)sender {
    NSLog(@"asdfooooooasdf");
}

- (void) setDefaultImageForButtons {
    [self.chatRecentBtn setImage:[UIImage imageNamed:@"icon_message"] forState:UIControlStateNormal];
    [self.favoriteBtn setImage:[UIImage imageNamed:@"icon_favorite"] forState:UIControlStateNormal];
    [self.staffBtn setImage:[UIImage imageNamed:@"icon_contact"] forState:UIControlStateNormal];
}

- (IBAction)recentTabClicked:(id)sender {
    if (selectedIndex == DIChatRecentTab) return;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_CONNECTING", nil) duration:0];
    
    [self addView:self.viewControllers[DIChatRecentTab]];
    [self removeView:self.viewControllers[selectedIndex]];
    [(QMNavigationController*)self.navigationController dismissNotificationPanel];
    selectedIndex = DIChatRecentTab;
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
    if ([[DataManager sharedManager].user.userType isEqualToString:@"denning"]) {
        [self performSegueWithIdentifier:kGroupChatSegue sender:nil];
    } else {
        [QMAlert showAlertWithMessage:@"You can create a new group" actionSuccess:NO inViewController:self];
    }
}

- (IBAction)staffTabClicked:(id)sender {
    if (selectedIndex == DIChatStaffTab) return;
    [self addView:self.viewControllers[DIChatStaffTab]];
    [self removeView:self.viewControllers[selectedIndex]];
    selectedIndex = DIChatStaffTab;
    [self setDefaultImageForButtons];
    [self.staffBtn setImage:[UIImage imageNamed:@"icon_contact_selected"] forState:UIControlStateNormal];
}

- (IBAction)clientTabClicked:(id)sender {
    if (selectedIndex == DIChatClientTab) return;
    [self addView:self.viewControllers[DIChatClientTab]];
    [self removeView:self.viewControllers[selectedIndex]];
    selectedIndex = DIChatClientTab;
    [self setDefaultImageForButtons];
    [self.clientBtn setImage:[UIImage imageNamed:@"icon_client_selected"] forState:UIControlStateNormal];
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
