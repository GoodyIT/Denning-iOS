 //
//  LegalFirmModel.m
//  Denning
//
//  Created by DenningIT on 13/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "LegalFirmModel.h"

@implementation LegalFirmModel

+ (LegalFirmModel*) getLegalFirmFromResponse: (NSDictionary*) response
{
    LegalFirmModel* legalFirm = [LegalFirmModel new];
    
    legalFirm.name = [response objectForKey:@"name"];
    legalFirm.IDNo = [response objectForKey:@"IDNo"];
    legalFirm.tel = [response objectForKey:@"phoneHome"];
    legalFirm.fax = [response objectForKey:@"phoneFax"];
    legalFirm.mobile = [response objectForKey:@"phoneMobile"];
    legalFirm.office = [response objectForKey:@"phoneOffice"];
    legalFirm.email = [response objectForKey:@"emailAddress"];
    legalFirm.address = [[response objectForKey:@"address"] objectForKey:@"fullAddress"];
    
    legalFirm.relatedMatter = [SearchResultModel getSearchResultArrayFromResponse:[response objectForKey:@"relatedMatter"]];
    
    return legalFirm;
}
@end
