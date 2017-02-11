//
//  QMNewMessageContactListViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMMessageContactListViewController;

@protocol QMMessageContactListViewControllerDelegate <NSObject>

- (void)messageContactListViewController:(QMMessageContactListViewController *)messageContactListViewController didSelectUser:(QBUUser *)selectedUser;
- (void)messageContactListViewController:(QMMessageContactListViewController *)messageContactListViewController didDeselectUser:(QBUUser *)deselectedUser;
- (void)messageContactListViewController:(QMMessageContactListViewController *)messageContactListViewController didScrollContactList:(UIScrollView *)scrollView;

@end

@interface QMMessageContactListViewController : UITableViewController

@property (weak, nonatomic) id <QMMessageContactListViewControllerDelegate>delegate;

- (void)deselectUser:(QBUUser *)user;

- (void)performSearch:(NSString *)searchText;

@end
