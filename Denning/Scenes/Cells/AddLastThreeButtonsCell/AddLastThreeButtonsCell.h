//
//  AddLastThreeButtonsCell.h
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

typedef void (^ViewHandler)(void);
typedef void (^SaveHandler)(void);
typedef void (^InvoiceHandler)(void);
typedef void (^ReceiptHandler)(void);
@interface AddLastThreeButtonsCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UIButton *invoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *receiptBtn;

@property (strong, nonatomic) ViewHandler viewHandler;
@property (strong, nonatomic) SaveHandler saveHandler;
@property (strong, nonatomic) InvoiceHandler invoiceHandler;
@property (strong, nonatomic) ReceiptHandler receiptHandler;
@end
