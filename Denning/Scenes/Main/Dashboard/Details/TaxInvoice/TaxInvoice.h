//
//  TaxInvoice.h
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateTaxInvoiceHandler)(TaxInvoiceModel* model);

@interface TaxInvoice : UIViewController <UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) NSString* url;

@property (strong, nonatomic) UpdateTaxInvoiceHandler  updateHandler;

@property (strong, nonatomic) NSString* fileNo;

@end
