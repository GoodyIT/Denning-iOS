//
//  BaseViewController.m
//  Reach-iOS
//
//  Created by MaksymRachytskyy on 11/21/15.
//  Copyright © 2015 Maksym Rachytskyy. All rights reserved.
//

#import "BaseViewController.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];    
}

- (void)removeKeyboardObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)__unused notification{
  
}

- (void)keyboardWillHide:(NSNotification *) __unused notification{
    
}



@end
