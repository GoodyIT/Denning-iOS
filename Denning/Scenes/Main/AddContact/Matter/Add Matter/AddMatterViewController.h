//
//  AddMatterViewController.h
//  Denning
//
//  Created by DenningIT on 08/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateMatterHandler)(RelatedMatterModel* model);

@interface AddMatterViewController : BaseViewController

@property (nonatomic, strong) RelatedMatterModel* matterModel;

@property (nonatomic, strong) UpdateMatterHandler updateHandler;
@end
