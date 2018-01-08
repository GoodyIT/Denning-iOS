//
//  DICustomViewController.m
//  Denning
//
//  Created by DenningIT on 20/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DICustomViewController.h"
#import "MainTabBarController.h"

@interface DICustomViewController ()
<MEVFloatingButtonDelegate>

@end

@implementation DICustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self hideTabBar];
}

- (void) hideTabBar {
    [self setTabBarVisible:NO animated:YES completion:nil];
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

- (void) configureMenuRightBtnWithImagename:(NSString*) imageName withSelector:(SEL) action
{
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:action];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.tabBarController.navigationItem setRightBarButtonItems:@[backButtonItem] animated:YES];
}

- (void) configureBackBtnWithImageName:(NSString*) imageName withSelector:(SEL) action {
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:action];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.tabBarController.navigationItem setLeftBarButtonItems:@[backButtonItem] animated:YES];
}

- (void) popupScreen:(id)sender {
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[0];
    
    [self setTabBarVisible:YES animated:NO completion:nil];
    [self configureBackBtnWithImageName:@"icon_user" withSelector:@selector(gotoLogin)];
}

- (void) gotoLogin {
    MainTabBarController *mainTabBarController = (MainTabBarController*)self.tabBarController;
    [mainTabBarController tapLogin:nil];
}

- (void) gotoMenu {
    MainTabBarController *mainTabBarController = (MainTabBarController*)self.tabBarController;
    [mainTabBarController tapMenu:nil];
}


- (void) setupFloatingButton {
    MEVFloatingButton *button = [[MEVFloatingButton alloc] init];
    button.displayMode = MEVFloatingButtonDisplayModeWhenScrolling;
    button.animationType = MEVFloatingButtonAnimationNone;
    button.position = MEVFloatingButtonPositionBottomRight;
    button.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.9];
    button.horizontalOffset = -12.0f;
    button.verticalOffset = -30.0f;
    button.image = [UIImage imageNamed:@"Icon2"];
    button.rounded = NO;
    button.hideWhenScrollToTop = YES;
    [self.tableView setFloatingButtonView:button];
    [self.tableView setFloatingButtonDelegate:self];
}

#pragma mark - MEScrollToTopDelegate Methods

- (void)floatingButton:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    NSLog(@"didTapButton");
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)floatingButtonWillAppear:(UIScrollView *)scrollView {
    NSLog(@"floatingButtonWillAppear");
}

- (void)floatingButtonDidAppear:(UIScrollView *)scrollView {
    NSLog(@"floatingButtonDidAppear");
}

- (void)floatingButtonWillDisappear:(UIScrollView *)scrollView {
    NSLog(@"floatingButtonWillDisappear");
}

- (void)floatingButtonDidDisappear:(UIScrollView *)scrollView; {
    NSLog(@"floatingButtonDidDisappear");
}

@end
