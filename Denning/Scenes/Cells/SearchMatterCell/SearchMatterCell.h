//
//  SearchMatterCell.h
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"
@protocol SearchMatterDelegate;

@interface SearchMatterCell : DIGeneralCell
@property (weak, nonatomic) id<SearchMatterDelegate> delegate;

- (void) configureCellWithSearchModel: (SearchResultModel*) model;
@end

@protocol SearchMatterDelegate <NSObject>

@optional

- (void) didTapFileFolder: (SearchMatterCell*) cell;

- (void) didTapLedger: (SearchMatterCell*) cell;

- (void) didTapFileNote: (SearchMatterCell*) cell;

- (void) didTapPaymentRecord: (SearchMatterCell*) cell fileNo:(NSString*) fileNo;

- (void) didTapUpload: (SearchMatterCell*) cell;

- (void) didTapTemplate: (SearchMatterCell*) cell withModel:(SearchResultModel*) model;

@end

