//
//  BankBranchViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLPAutoCompleteTextField;
typedef void (^UpdateBankBranchHandler)(BankBranchModel* model);

@interface BankBranchAutoComplete : UIViewController

@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *autocompleteTF;
@property (strong, nonatomic) NSString* url;

@property (strong, nonatomic) UpdateBankBranchHandler updateHandler;

@end
