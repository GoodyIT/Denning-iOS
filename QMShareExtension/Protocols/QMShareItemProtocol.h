//
//  QMSharerableItem.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/12/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

@protocol QMShareItemProtocol <NSCopying, NSObject>

@property (nonatomic, copy, nullable, readonly) NSString *title;
@property (nonatomic, copy, nullable, readonly) NSString *imageURL;
@property (nonatomic, strong, nullable, readonly) NSDate *updatedAt;

@end
