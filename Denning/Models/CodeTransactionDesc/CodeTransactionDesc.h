//
//  CodeTransactionDesc.h
//  Denning
//
//  Created by Denning IT on 2017-11-24.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeTransactionDesc : NSObject

@property (strong, nonatomic) NSString* codeValue;
@property (strong, nonatomic) NSString* strTransactionDescription;

+ (instancetype) getCodeTransactionDesc:(NSDictionary*) response;
+ (NSArray*) getCodeTransactionDescArray:(NSArray*) response;
@end
