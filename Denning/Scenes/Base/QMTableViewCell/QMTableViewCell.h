//
//  QMTableViewCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMTableViewCell : UITableViewCell

+ (void)registerForReuseInTableView:(UITableView *)tableView;
+ (NSString *)cellIdentifier;
+ (CGFloat)height;

- (void)setTitle:(NSString *)title
       avatarUrl:(NSString *)avatarUrl;

- (void)setTitle:(NSString *)title;
- (void)setBody:(NSString *)body;
- (void) setPosition:(NSString*) position;

// Custom
- (void) configureCellWithUser: (QBUUser*) user;
- (void) configureCellWithChatDialog:(QBChatDialog*) dialog;

@property (copy, nonatomic) void (^didTapAvatar)(QMTableViewCell *cell);

@end
