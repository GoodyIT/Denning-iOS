//
//  TransactionDescViewController.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UpdateHandler)(CodeTransactionDesc* model);

@interface TransactionDescViewController : UIViewController
@property (strong, nonatomic) NSMutableArray<CodeTransactionDesc*>* listOfCodeDesc;
@property (strong, nonatomic) NSString* url;

@property (strong, nonatomic) UpdateHandler updateHandler;

@end
