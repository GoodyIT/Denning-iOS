//
//  BankReconCell.h
//  Denning
//
//  Created by Ho Thong Mee on 14/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface BankReconCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *secondValue;
@property (weak, nonatomic) IBOutlet UILabel *firstValue;
@property (weak, nonatomic) IBOutlet UILabel *thirdValue;

- (void) configureCellWithModel: (BankReconModel*) model;

- (void) configureCellForFileLedger:(BankReconModel*) model;

- (void) configureCellForFeesTransfer: (FeeTranserModel*) model;

- (void) configureCellForBankBalance:(BankReconModel*) model;

- (void) configureCellWithDict:(NSDictionary*) dict;

@end
