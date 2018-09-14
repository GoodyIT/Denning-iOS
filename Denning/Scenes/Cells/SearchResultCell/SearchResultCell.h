//
//  SearchResultCell.h
//  Denning
//
//  Created by DenningIT on 20/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

typedef void(^TapContactFolderHandler)(SearchResultModel* model);
typedef void(^TapUploadHandler)(SearchResultModel* model);

@protocol SearchDelegate;


@interface SearchResultCell : DIGeneralCell

@property (weak, nonatomic) id<SearchDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *matterBtn;
@property (weak, nonatomic) IBOutlet UIButton *contactFolderBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;

@property (strong, nonatomic) TapContactFolderHandler contactHandler;
@property (strong, nonatomic) TapUploadHandler uploadHandler;

- (void) configureCellWithSearchModel: (SearchResultModel*) searchResult;

@end

@protocol SearchDelegate <NSObject>

@optional

- (void) didTapMatter: (SearchResultCell*) cell;

- (IBAction)didTapUpload:(id)sender;

- (IBAction)didTapContactFolder:(id)sender;

@end
