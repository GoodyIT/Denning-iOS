//
//  TimePickerViewController.h
//  Denning
//
//  Created by DenningIT on 09/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateTimeHandler)(NSString *date);

@interface TimePickerViewController : UIViewController

@property (strong, nonatomic) UpdateTimeHandler updateHandler;
@property (strong, nonatomic) NSString* initialTime;

@end
