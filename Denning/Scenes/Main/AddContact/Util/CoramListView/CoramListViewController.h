//
//  CoramListViewController.h
//  Denning
//
//  Created by Ho Thong Mee on 24/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateCoramHandler)(CoramModel* model);

@interface CoramListViewController : UIViewController

@property (strong, nonatomic) UpdateCoramHandler  updateHandler;

@end
