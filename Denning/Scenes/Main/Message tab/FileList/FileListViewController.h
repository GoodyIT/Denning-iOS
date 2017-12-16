//
//  FileListViewController.h
//  Denning
//
//  Created by Ho Thong Mee on 06/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResultModel;

typedef void (^UpdateFileHandler)(SearchResultModel* model);

@interface FileListViewController : UIViewController

@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) UpdateFileHandler updateHandler;

@end
