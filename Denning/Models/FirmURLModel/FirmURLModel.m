//
//  FirmURLModel.m
//  Denning
//
//  Created by DenningIT on 29/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FirmURLModel.h"
#import "NSDictionary+NotNull.h"
#import "DocumentModel.h"

@implementation FirmURLModel

+ (FirmURLModel*) getFirmModelFromResponse: (NSDictionary*) response
{
    FirmURLModel* model = [FirmURLModel new];
    
    model.firmServerURL = [response valueForKey:@"APIServer"];
    model.name = [[response objectForKey:@"LawFirm"] valueForKey:@"name"];
    model.city = [[[response objectForKey:@"LawFirm"] objectForKey:@"address"] valueForKey:@"city"];
    model.document = [DocumentModel getDocumentFromResponse:[response objectForKey:@"folders"]];
    model.theCode = [response valueForKey:@"theCode"];
    
    return model;
}

+ (NSArray*) getFirmArrayFromResponse:(NSArray*) response
{
    NSMutableArray* firmArray = [NSMutableArray new];
    
    if (![response isKindOfClass:[NSNull class]]) {
        for(id obj in response) {
            [firmArray addObject:[FirmURLModel getFirmModelFromResponse:obj]];
        }
    }
    
    return firmArray;
}
@end
