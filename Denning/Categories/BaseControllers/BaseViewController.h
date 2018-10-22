//
//  BaseViewController.h
//  Reach-iOS
//
//  Created by MaksymRachytskyy on 11/21/15.
//  Copyright © 2015 Maksym Rachytskyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController< UIDocumentInteractionControllerDelegate>

- (void)addKeyboardObservers;
- (void)removeKeyboardObservers;

- (void) hideTabBar;

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion;

- (void) configureBackBtnWithImageName:(NSString*) imageName withSelector:(SEL) action;

- (void) popupScreen;

@end
