//
//  QMContactsDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMAlphabetizedDataSource.h"

@interface QMContactsDataSource : QMAlphabetizedDataSource


/**
 *  Add Favorite user block action.
 */
@property (copy, nonatomic) void (^didAddUserBlock)();

@end
