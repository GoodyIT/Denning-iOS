//
//  ListWithCodeTableViewController.h
//  Denning
//
//  Created by DenningIT on 03/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactListWithCodeSelectionDelegate;

@interface ListWithCodeTableViewController : BaseViewController
@property (weak, nonatomic) id<ContactListWithCodeSelectionDelegate> delegate;

@property (strong, nonatomic) NSMutableArray* listOfCodeDesc;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* titleOfList;
@property (strong, nonatomic) NSString* name;

@end
