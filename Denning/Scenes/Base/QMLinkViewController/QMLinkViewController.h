//
//  QMLinkViewController.h
//  Q-municate
//
//  Created by Andrey Ivanov on 25.02.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMLinkViewController : UIViewController

/**
 * The name of the storyboard that should be linked.
 * This should be set in the Interface Builder identity inspector.
 */
@property (copy, nonatomic) IBInspectable NSString *storyboardName;

/**
 * (Optional) The identifier of the scene to show.
 * This should be set in the Interface Builder identity inspector.
 */
@property (copy, nonatomic) IBInspectable NSString *sceneIdentifier;

@property (assign, nonatomic) IBInspectable BOOL modal;

@end
