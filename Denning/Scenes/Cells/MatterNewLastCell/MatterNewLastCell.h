//
//  MatterNewLastCell.h
//  Denning
//
//  Created by Denning IT on 2017-11-27.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@class MatterNewLastCell;
@protocol MatterNewLastCellDelegate <NSObject>

@optional

- (void) didTapPaymentRecord: (MatterNewLastCell*) cell;


- (void) didTapUpload: (MatterNewLastCell*) cell fileNo:(NSString*) fileNo;

- (void) didTapTemplate: (MatterNewLastCell*) cell withModel:(RelatedMatterModel*) model;
@end

@interface MatterNewLastCell : DIGeneralCell

@property (weak, nonatomic) IBOutlet UIButton *paymentRecordBtn;
@property (weak, nonatomic) id<MatterNewLastCellDelegate> matterNewLastCellDelegate;
@property (strong, nonatomic) RelatedMatterModel *model;

- (void) configureCellWithModfel: (RelatedMatterModel*) model;

@end
