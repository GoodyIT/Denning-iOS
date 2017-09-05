//
//  ContactListViewController.h
//  Denning
//
//  Created by Ho Thong Mee on 29/08/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StaffModel;
typedef void (^UpdateContactHandler)(StaffModel* model);

@interface ContactListViewController : UIViewController

@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) UpdateContactHandler updateHandler;
@end
