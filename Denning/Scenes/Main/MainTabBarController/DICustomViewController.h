//
//  DICustomViewController.h
//  Denning
//
//  Created by DenningIT on 20/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICustomViewController : UIViewController

- (void) hideTabBar;

- (void) configureBackBtnWithImageName:(NSString*) imageName withSelector:(SEL) action;

- (void) configureMenuRightBtnWithImagename:(NSString*) imageName withSelector:(SEL) action;

- (void) popupScreen:(id)sender;

- (void) gotoLogin;

- (void) gotoMenu;

- (void) setupFloatingButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
