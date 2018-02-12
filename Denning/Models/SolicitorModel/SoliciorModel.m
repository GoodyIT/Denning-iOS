//
//  SoliciorModel.m
//  Denning
//
//  Created by DenningIT on 20/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "SoliciorModel.h"

@implementation SoliciorModel

+ (SoliciorModel*) getSolicitorFromResponse: (NSDictionary*) response
{
    SoliciorModel *model = [SoliciorModel new];
    model.IDNo = [response valueForKeyNotNull:@"IDNo"];
    model.address = [AddressModel getAddressFromResponse:[response objectForKeyNotNull:@"address"]];
    model.citizenship = [response valueForKeyNotNull:@"citizenship"];
    model.solicitorCode = [response valueForKeyNotNull:@"code"];
    model.dateBirth = [response valueForKeyNotNull:@"dateBirth"];
    model.emailAddress = [response valueForKeyNotNull:@"emailAddress"];
    model.idTypeCode = [[response objectForKeyNotNull:@"idType"] valueForKeyNotNull:@"code"];
    model.idTypeDescription = [[response objectForKeyNotNull:@"idType"] valueForKeyNotNull:@"description"];
    model.name = [response valueForKeyNotNull:@"name"];
    model.phoneFax = [response valueForKeyNotNull:@"phoneFax"];
    model.phoneHome = [response valueForKeyNotNull:@"phoneHome"];
    model.phoneOffice = [response valueForKeyNotNull:@"phoneOffice"];
    model.title = [response valueForKeyNotNull:@"title"];
    model.webSite = [response valueForKeyNotNull:@"webSite"];
    
    return model;
}

+ (NSArray*) getSolicitorArrayFromRespsonse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[SoliciorModel getSolicitorFromResponse:obj]];
    }
    
    return result;
}

@end
