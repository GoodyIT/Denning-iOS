//
//  BaseViewController.m
//  Reach-iOS
//
//  Created by MaksymRachytskyy on 11/21/15.
//  Copyright © 2015 Maksym Rachytskyy. All rights reserved.
//

#import "BaseViewController.h"
#import "MainTabBarController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self removeKeyboardObservers];
    [super viewWillDisappear:animated];
    
    [[QMNetworkManager sharedManager] cancelAllOperations];
    
    [SVProgressHUD dismiss];
    [self.view endEditing:YES];
    if ([self.navigationController isKindOfClass:[QMNavigationController class]]) {
        [(QMNavigationController*)self.navigationController dismissNotificationPanel];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addKeyboardObservers];
}

#pragma mark - Keyboard Observers

- (void)addKeyboardObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)__unused notification{
  
}

- (void)keyboardWillBeHidden:(NSNotification *) __unused notification{
    
}

- (void) hideTabBar {
    [self setTabBarVisible:NO animated:NO completion:^(BOOL finished) {
    }];
}

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

- (void) popupScreen {
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[0];
    
    [self setTabBarVisible:YES animated:NO completion:nil];
    [self configureBackBtnWithImageName:@"icon_user" withSelector:@selector(gotoLogin)];
}

- (void) gotoLogin {
    MainTabBarController *mainTabBarController = (MainTabBarController*) self.tabBarController;
    [mainTabBarController tapLogin:nil];
}

- (void) gotoMenu {
    MainTabBarController *mainTabBarController = (MainTabBarController*)self.tabBarController;
    [mainTabBarController tapMenu:nil];
}

@end
