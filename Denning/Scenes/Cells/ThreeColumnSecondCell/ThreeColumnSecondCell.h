//
//  ThreeColumnSecondCell.h
//  Denning
//
//  Created by Ho Thong Mee on 28/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface ThreeColumnSecondCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *fileNo;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *invoiceNo;
@property (weak, nonatomic) IBOutlet UILabel *amount;

- (void) configureCellWithModel:(FeeUntransferModel*) model;

- (void) configureCellWithDict:(NSDictionary*) dict;

@end
