//
//  DateTimeViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-20.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^UpdateDateTimeHandler)(NSString *date);

@interface DateTimeViewController : UIViewController

@property (strong, nonatomic) UpdateDateTimeHandler updateHandler;
@property (strong, nonatomic) NSString* initialDate;

@end
