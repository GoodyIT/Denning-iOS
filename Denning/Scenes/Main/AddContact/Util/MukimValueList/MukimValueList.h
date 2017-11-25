//
//  MukimValueList.h
//  Denning
//
//  Created by Ho Thong Mee on 07/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateMukimValueHandler)(MukimModel* model);

@interface MukimValueList : UIViewController

@property (strong, nonatomic) UpdateMukimValueHandler updateHandler;

@end
