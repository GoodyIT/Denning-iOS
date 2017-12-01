//
//  TaxInvoiceCell.h
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface TaxInvoiceCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *taxInvoiceNo;
@property (weak, nonatomic) IBOutlet UILabel *fileNo;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *invoiceTo;
@property (weak, nonatomic) IBOutlet UILabel *fileName;

- (void) configureCellWithModel:(TaxInvoiceModel*) model;
- (void) configureCellWithTaxModel:(TaxModel*) model;
@end
