//
//  GeneralContactCell.h
//  Denning
//
//  Created by DenningIT on 11/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWTableViewCell;
@interface GeneralContactCell : SWTableViewCell
+ (void)registerForReuseInTableView:(UITableView *)tableView;
+ (NSString *)cellIdentifier;
+ (CGFloat)height;
@end
