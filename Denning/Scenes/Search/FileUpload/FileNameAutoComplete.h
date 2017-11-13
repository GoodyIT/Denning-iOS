//
//  FileNameAutoComplete.h
//  Denning
//
//  Created by Ho Thong Mee on 08/11/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^UpdateFileNameAutocompletHandler)(NSString* model);

@interface FileNameAutoComplete : UIViewController
@property (strong, nonatomic) NSString* url;

@property (strong, nonatomic) UpdateFileNameAutocompletHandler updateHandler;
@end
