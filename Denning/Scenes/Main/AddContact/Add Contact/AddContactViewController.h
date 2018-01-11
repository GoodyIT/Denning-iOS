//
//  AddContactViewController.h
//  Denning
//
//  Created by DenningIT on 20/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateContactHandler)(ContactModel* model);
@class ListWithCodeTableViewController;

@interface AddContactViewController : DICustomTableViewController<UITextFieldDelegate, ContactListWithCodeSelectionDelegate, ContactListWithDescSelectionDelegate>

@property (weak, nonatomic) IBOutlet UIFloatLabelTextField *postcodeTextField;

@property (strong, nonatomic) ContactModel* contactModel;
@property(strong, nonatomic) NSString* viewType;

@property (strong, nonatomic) UpdateContactHandler updateHandler;
@end
