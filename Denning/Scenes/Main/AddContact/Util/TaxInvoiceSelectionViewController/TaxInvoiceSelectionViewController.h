//
//  TaxInvoiceSelectionViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-23.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxInvoiceSelectionViewController : UIViewController

@property (nonatomic, strong) TaxInvoiceCalcModel* taxModel;
@property (strong, nonatomic) NSArray<NSArray*>* listOfTax;
@property (strong, nonatomic) NSArray* listOfTotalPrice;
@property (strong, nonatomic) NSNumber* selectedPage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSString* titleString;

@end
