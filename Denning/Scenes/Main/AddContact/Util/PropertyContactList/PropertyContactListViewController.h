//
//  PropertyContactListViewController.h
//  Denning
//
//  Created by DenningIT on 17/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

@class StaffModel;
#import <UIKit/UIKit.h>
typedef void (^UpdatePropertyContactHandler)(StaffModel* model);

@interface PropertyContactListViewController : UIViewController

@property (strong, nonatomic) UpdatePropertyContactHandler updateHandler;

@end
