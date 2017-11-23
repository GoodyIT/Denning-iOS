//
//  QMBadgeView.h
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMBadgeView : UIView

@property (assign, nonatomic) IBInspectable NSUInteger badgeNumber;
@property (assign, nonatomic) IBInspectable BOOL hideOnZeroValue;

@end
