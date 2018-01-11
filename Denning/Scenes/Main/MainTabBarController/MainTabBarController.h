//
//  MainTabBarController.h
//  Denning
//
//  Created by DenningIT on 02/02/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController
<UITabBarControllerDelegate>
- (IBAction)tapMenu:(id)sender;

- (IBAction)tapLogin:(id)sender;

- (void) removeTabbarBasedOnUserType;

- (void) updateBadge;

@end
