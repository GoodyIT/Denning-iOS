//
//  HomeViewController.h
//  Denning
//
//  Created by DenningIT on 01/02/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DICustomViewController.h"

@interface HomeViewController : DICustomViewController //UITableViewController

- (void) changeUIBasedOnUserType;

- (void) displayBranchInfo;

@end
