//
//  AddReceiptViewController.h
//  Denning
//
//  Created by DenningIT on 18/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddReceiptViewController : UITableViewController

@property (strong, nonatomic) ReceiptModel* model;

@property (strong, nonatomic) NSString* isUpdate;

@end
