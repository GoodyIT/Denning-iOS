//
//  ListWithDescriptionViewController.h
//  Denning
//
//  Created by DenningIT on 03/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactListWithDescSelectionDelegate;
@interface ListWithDescriptionViewController : DICustomViewController
@property (weak, nonatomic) id<ContactListWithDescSelectionDelegate> contactDelegate;

@property (assign, nonatomic) NSString *titleOfList;
@property (assign, nonatomic) NSString *url;
@property (assign, nonatomic) NSString *name;

@end
