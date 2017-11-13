//
//  ContactModel.m
//  Denning
//
//  Created by DenningIT on 26/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel

+ (ContactModel*) getContactFromResponse: (NSDictionary*) response
{
    ContactModel *contactModel = [ContactModel new];
    
    contactModel.contactCode = [response valueForKeyNotNull:@"code"];
    contactModel.idType = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"idType"]];
    contactModel.IDNo = [response valueForKeyNotNull:@"IDNo"];
    contactModel.name = [response valueForKeyNotNull:@"name"];
    contactModel.homePhone = [response valueForKeyNotNull:@"phoneHome"];
    contactModel.mobilePhone = [response valueForKeyNotNull:@"phoneMobile"];
    contactModel.officePhone = [response valueForKeyNotNull:@"phoneOffice"];
    contactModel.email = [response valueForKeyNotNull:@"emailAddress"];
    contactModel.address = [AddressModel getAddressFromResponse:[response objectForKeyNotNull:@"address"]];
    
    contactModel.dateOfBirth = [response valueForKeyNotNull:@"dateBirth"];
    contactModel.citizenShip = [response valueForKeyNotNull:@"citizenship"];
    contactModel.fax = [response valueForKeyNotNull:@"phoneFax"];
    contactModel.tax = [response valueForKeyNotNull:@"taxFileNo"];
    contactModel.IRDBranch = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"irdBranch"]];
    contactModel.idType = [response valueForKeyNotNull:@"idType"];
    contactModel.contactTitle = [response valueForKeyNotNull:@"title"];
    contactModel.contactPerson = [response valueForKeyNotNull:@"contactPerson"];
    contactModel.website = [response valueForKeyNotNull:@"website"];
    contactModel.InviteToDenning = [response valueForKeyNotNull:@"InviteToDenning"];
    contactModel.registeredOffice = [response valueForKeyNotNull:@"registeredOffice"];
    contactModel.occupation = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"occupation"]];
    
    contactModel.relatedMatter = [SearchResultModel getSearchResultArrayFromResponse:[response objectForKeyNotNull:@"relatedMatter"]];
    
    contactModel.matterDescription = @"";
    for(SearchResultModel* model in contactModel.relatedMatter) {
        contactModel.matterDescription = [NSString stringWithFormat:@"%@, %@", contactModel.matterDescription, model.key];
    }
    return contactModel;
}

+ (NSString*) combineAddress: (NSDictionary*) address
{
    NSString *fullAddress;

    NSString *line1 = [address objectForKeyNotNull:@"line1"];
    NSString *line2 = [address objectForKeyNotNull:@"line2"];
    NSString *line3 = [address objectForKeyNotNull:@"line3"];
    NSString *postCode = [address objectForKeyNotNull:@"postcode"];
    NSString *city = [address objectForKeyNotNull:@"city"];
    NSString *state = [address objectForKeyNotNull:@"state"];
    NSString *country = [address objectForKeyNotNull:@"country"];
    
    fullAddress = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@", line1, line2, line3, postCode, city, state, country];
    
    return fullAddress;
}

@end
