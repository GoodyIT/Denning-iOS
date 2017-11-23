//
//  QMGroupAddUsersSearchDataProvider.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/21/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMGroupAddUsersSearchDataProvider : QMSearchDataProvider

@property (copy, nonatomic, nullable) NSArray *excludedUserIDs;
@property (strong, nonatomic, readonly) NSArray *users;

- (nullable instancetype)initWithExcludedUserIDs:(NSArray *)excludedUserIDs;

@end

NS_ASSUME_NONNULL_END
