//
//  CalendarViewController.h
//  Pile
//
//  Created by Admin on 2016-11-14.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RealPropertyGainTaxViewController;

@interface CalendarViewController : UIViewController

@property (strong, nonatomic) RealPropertyGainTaxViewController* realVC;
@property (strong, nonatomic) NSString* typeOfDate;
@property (strong, nonatomic) NSString* minDate;
@end
