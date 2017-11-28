//
//  TaxBillContactViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateBillContactHandler)(ClientModel* model);

@interface TaxBillContactViewController : UIViewController

@property (strong, nonatomic) NSString* url;
@property (copy, nonatomic) NSString *filter;

@property (strong, nonatomic) UpdateBillContactHandler updateHandler;


@end
