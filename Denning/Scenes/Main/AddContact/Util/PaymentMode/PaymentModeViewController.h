//
//  PaymentModeViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdatePaymentHandler)(PaymentModeModel* model);

@interface PaymentModeViewController : UIViewController

@property (strong, nonatomic) NSMutableArray<PaymentModeModel*>* listOfCodeDesc;
@property (strong, nonatomic) NSString* url;

@property (strong, nonatomic) UpdatePaymentHandler updateHandler;

@end
