//
//  DashboardContact.h
//  Denning
//
//  Created by Ho Thong Mee on 15/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateContactHandler)(SearchResultModel* model);

@interface DashboardContact : UIViewController

@property (strong, nonatomic) NSString* url;

@property (strong, nonatomic) NSString* callback;

@property (strong, nonatomic) UpdateContactHandler updateHandler;

@end
