//
//  SearchContactCell.h
//  Denning
//
//  Created by Ho Thong Mee on 27/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

typedef void(^TapMatterHandler)(SearchResultModel* model);
typedef void(^TapContactFolderHandler)(SearchResultModel* model);
typedef void(^TapUploadHandler)(SearchResultModel* model);

@interface SearchContactCell : DIGeneralCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *indexData;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *matterBtn;
@property (weak, nonatomic) IBOutlet UIButton *contactFolderBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;


@property (strong, nonatomic) TapMatterHandler matterHandler;
@property (strong, nonatomic) TapContactFolderHandler contactHandler;
@property (strong, nonatomic) TapUploadHandler uploadHandler;


- (void) configureCellWithModel:(SearchResultModel*) model;
@end
