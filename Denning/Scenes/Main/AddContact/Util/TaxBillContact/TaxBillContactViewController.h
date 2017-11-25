//
//  TaxBillContactViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateContactHandler)(ClientModel* model);

@interface TaxBillContactViewController : UIViewController

@property (strong, nonatomic) NSString* url;

@property (strong, nonatomic) UpdateContactHandler updateHandler;


@end
