//
//  DocumentViewController.h
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentViewController : UITableViewController

@property (strong, nonatomic) DocumentModel* documentModel;
@property (strong, nonatomic) NSString* previousScreen;

@property (strong, nonatomic) NSString* fromDashboard;
@end
