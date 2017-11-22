//
//  ListOfCodeStrViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-22.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateCodeStrHandler)(CodeStrModel* model);

@interface ListOfCodeStrViewController : UIViewController

@property (strong, nonatomic) UpdateCodeStrHandler  updateHandler;
@property (strong, nonatomic) NSString* url;

@end
