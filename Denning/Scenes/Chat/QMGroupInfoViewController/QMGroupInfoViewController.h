//
//  QMGroupInfoViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^UpdateChatDialog)(QBChatDialog *chatDialog);

@interface QMGroupInfoViewController : QMViewController

@property (strong, nonatomic) QBChatDialog *chatDialog;

@property (strong, nonatomic) UpdateChatDialog updateChatDialog;

@end

NS_ASSUME_NONNULL_END
