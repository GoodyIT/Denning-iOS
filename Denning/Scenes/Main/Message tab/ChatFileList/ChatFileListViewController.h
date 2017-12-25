//
//  ChatFileListViewController.h
//  Denning
//
//  Created by Denning IT on 2017-12-16.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateDocumentFile)(NSString* url);

@interface ChatFileListViewController : BaseViewController

@property (strong, nonatomic) NSString* initialKeyword;

@property (strong, nonatomic) UpdateDocumentFile updateHandler;

@end
