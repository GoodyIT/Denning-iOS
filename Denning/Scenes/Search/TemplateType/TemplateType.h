//
//  TemplateType.h
//  Denning
//
//  Created by Ho Thong Mee on 25/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateTypeHandler)(NSDictionary* type);

@interface TemplateType : UITableViewController

@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) UpdateTypeHandler updateHandler;
@end
