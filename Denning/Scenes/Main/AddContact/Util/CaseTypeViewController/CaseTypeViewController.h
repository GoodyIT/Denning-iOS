//
//  CaseTypeViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-19.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateCaseTypeHandler)(CaseTypeModel* model);

@interface CaseTypeViewController : UIViewController

@property (strong, nonatomic) UpdateCaseTypeHandler  updateHandler;


@end
