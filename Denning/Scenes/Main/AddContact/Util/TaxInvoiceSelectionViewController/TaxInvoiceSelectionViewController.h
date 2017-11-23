//
//  TaxInvoiceSelectionViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-23.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxInvoiceSelectionViewController : UIViewController

@property (strong, nonatomic) NSArray<NSArray*>* listOfTax;
@property (strong, nonatomic) NSArray* listOfTotalPrice;
@property (strong, nonatomic) NSNumber* selectedPage;

@end
