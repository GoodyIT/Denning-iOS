//
//  QMUpdateUserViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMExpandableTableViewController.h"


typedef NS_ENUM(NSUInteger, QMUpdateUserField) {
    
    QMUpdateUserFieldUserName,
    QMUpdateUserFieldPhone,
    QMUpdateUserFieldEmail,
    QMUpdateUserFieldStatus
};

@interface QMUpdateUserViewController : QMExpandableTableViewController

@property (assign, nonatomic) QMUpdateUserField updateUserField;

@end
