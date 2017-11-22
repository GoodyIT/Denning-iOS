//
//  BankModel.m
//  Denning
//
//  Created by DenningIT on 27/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "BankGroupModel.h"

@implementation BankGroupModel

+(BankGroupModel*) getBankGroupFromResponse: (NSDictionary*) response
{
    BankGroupModel* bankGroupModel = [BankGroupModel new];
    bankGroupModel.bankGroupName = [response valueForKeyNotNull:@"groupName"];
    id bank = [response objectForKeyNotNull:@"bank"];
    if (bank == nil) {
        bankGroupModel.bankCode = @"";
        bankGroupModel.bankName = @"";
    } else {
        bankGroupModel.bankCode = [bank valueForKeyNotNull:@"code"];
        bankGroupModel.bankName = [bank valueForKeyNotNull:@"name"];
    }
    
    return bankGroupModel;
}

+(NSArray*) getBankGroupArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray* bankGroupArray = [NSMutableArray new];
    for (id group in response){
        BankGroupModel* model = [BankGroupModel getBankGroupFromResponse:group];
        if (model != nil) {
            [bankGroupArray addObject:model];
        }
    }
    return bankGroupArray;
}
@end
