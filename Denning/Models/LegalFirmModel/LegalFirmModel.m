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
    
    legalFirm.name = [response valueForKeyNotNull:@"name"];
    legalFirm.IDNo = [response valueForKeyNotNull:@"IDNo"];
    legalFirm.title = [response valueForKeyNotNull:@"title"];
    legalFirm.tel = [response valueForKeyNotNull:@"phoneHome"];
    legalFirm.fax = [response valueForKeyNotNull:@"phoneFax"];
    legalFirm.mobile = [response valueForKeyNotNull:@"phoneMobile"];
    legalFirm.office = [response valueForKeyNotNull:@"phoneOffice"];
    legalFirm.email = [response valueForKeyNotNull:@"emailAddress"];
    legalFirm.address = [[response valueForKeyNotNull:@"address"] objectForKey:@"fullAddress"];
    
    legalFirm.relatedMatter = [SearchResultModel getSearchResultArrayFromResponse:[response objectForKey:@"relatedMatter"]];
    
    return legalFirm;
}
@end
