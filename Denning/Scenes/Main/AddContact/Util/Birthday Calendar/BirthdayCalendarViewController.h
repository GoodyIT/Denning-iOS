//
//  CalendarViewController.h
//  Pile
//
//  Created by Admin on 2016-11-14.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddContactViewController.h"

typedef void (^UpdateDateHandler)(NSString *date);

@interface BirthdayCalendarViewController : UIViewController

@property (strong, nonatomic) UpdateDateHandler updateHandler;
@property (strong, nonatomic) NSString* initialDate;

@end
