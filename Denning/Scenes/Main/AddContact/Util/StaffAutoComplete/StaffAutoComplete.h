//
//  StaffAutoComplete.h
//  Denning
//
//  Created by Denning IT on 2017-11-25.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLPAutoCompleteTextField;

typedef void (^UpdateClientHandler)(StaffModel* model);

@interface StaffAutoComplete : UIViewController

@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *autocompleteTF;
@property (strong, nonatomic) NSString* url;

@property (strong, nonatomic) UpdateClientHandler updateHandler;

@end
