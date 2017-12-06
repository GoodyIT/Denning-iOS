//
//  CodeTransactionAutoComplete.h
//  Denning
//
//  Created by Denning IT on 2017-12-07.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateTransactionAutocompletHandler)(CodeTransactionDesc* model);


@interface CodeTransactionAutoComplete : UIViewController

@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) UpdateTransactionAutocompletHandler updateHandler;

@end
