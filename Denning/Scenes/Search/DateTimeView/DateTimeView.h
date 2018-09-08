//
//  DateTimeView.h
//  Denning
//
//  Created by Ho Thong Mee on 19/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateDateTimeHandler)(NSString *date);

@interface DateTimeView : UIViewController

@property (strong, nonatomic) UpdateDateTimeHandler updateHandler;
@property (strong,  nonatomic) NSString* initialDate;

@end
