//
//  ContactViewController.m
//  Denning
//
//  Created by DenningIT on 03/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "MainContactViewController.h"
#import "MainTabBarController.h"
#import "AddDiaryViewController.h"
#import "Attendance.h"

@interface MainContactViewController ()

@end

@implementation MainContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTapGesture];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) changeTitle {
    self.tabBarController.navigationItem.titleView = nil;
    self.tabBarController.navigationItem.title = @"ADD";
    
    self.navigationController.tabBarItem.image = [UIImage imageNamed:@"icon_add"];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self setTabBarVisible:YES animated:NO completion:nil];
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureBackBtnWithImageName:@"Back" withSelector:@selector(popupScreen:)];
    [self changeTitle];
    
    [self performSelector:@selector(hideTabBar) withObject:nil afterDelay:1.0];
}

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void) handleTap {
    [self showTabBar];
}

- (void) hideTabBar {
    [self setTabBarVisible:NO animated:NO completion:^(BOOL finished) {
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

- (void) configureMenuRightBtnWithImagename:(NSString*) imageName withSelector:(SEL) action {
    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 23)];
    [menuBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    [self.tabBarController.navigationItem setRightBarButtonItems:@[menuButtonItem] animated:YES];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 3) {
        return 1;
    }
    return 3;
}

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        [self performSegueWithIdentifier:kDiarySegue sender:@"OfficeDiary"];
    }
    
    if (indexPath.section == 3 && indexPath.row == 0) {
        [self getAttendance];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ACCESS_DENIED_REGISTER", nil) withTitle:@"Access Restricted" actionSuccess:NO inViewController:self withCallback:^{
            [self performSegueWithIdentifier:kAuthSegue sender:nil];
        }];
    } else if ([CLLocationManager locationServicesEnabled] == NO) {
        [(AppDelegate*)[UIApplication sharedApplication].delegate showDeniedLocation];
    } else {
        [SVProgressHUD show];
        
        [[QMNetworkManager sharedManager] getAttendanceListWithCompletion:^(AttendanceModel * _Nonnull result, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            [self handleResponse:result error:error];
        }];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kDiarySegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        AddDiaryViewController* diaryVC = navVC.viewControllers.firstObject;
        diaryVC.type = sender;
    } else if ([segue.identifier isEqualToString:kAttendanceSegue]) {
        UINavigationController* navVC = segue.destinationViewController;
        Attendance* vc = navVC.viewControllers.firstObject;
        vc.attendanceModel = sender;
    } 
}


@end
