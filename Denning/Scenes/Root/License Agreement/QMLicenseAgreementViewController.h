//
//  QMLicenseAgreementViewController.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 10/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LicenceCompletionBlock)(BOOL accepted);

typedef void(^BackAction) (void);

@interface QMLicenseAgreementViewController : UIViewController

@property (copy, nonatomic) LicenceCompletionBlock licenceCompletionBlock;

@property (copy, nonatomic) BackAction backAction;

@property (strong, nonatomic) NSString* contents;

@end
