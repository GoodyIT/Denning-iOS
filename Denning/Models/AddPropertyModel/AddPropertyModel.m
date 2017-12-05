//
//  AddPropertyModel.m
//  Denning
//
//  Created by Ho Thong Mee on 27/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddPropertyModel.h"

@implementation AddPropertyModel

+ (AddPropertyModel*) getAddPropertyFromResponse:(NSDictionary*) response
{
    AddPropertyModel* model = [AddPropertyModel new];
    
    model.propertyCode = [response valueForKeyNotNull:@"code"];
    model.accBuildingNo = [response valueForKeyNotNull:@"accBuildingNo"];
    model.accParcelNo = [response valueForKeyNotNull:@"accParcelNo"];
     model.accStoreyNo = [response valueForKeyNotNull:@"accStoreyNo"];
     model.address = [response valueForKeyNotNull:@"address"];
     model.approvingAuthority = [response valueForKeyNotNull:@"approvingAuthority"];
     model.area = [TypeValueModel getTypeValueFromResponse:[response objectForKeyNotNull:@"area"]];
     model.buildingNo = [response valueForKeyNotNull:@"buildingNo"];
     model.daerah = [response valueForKeyNotNull:@"daerah"];
     model.developer = [StaffModel getStaffFromResponse:[response objectForKeyNotNull:@"developer"]];
     model.fullTitle = [response valueForKeyNotNull:@"fullTitle"];
     model.landUse = [response valueForKeyNotNull:@"landUse"];
     model.leaseExpiryDate = [response valueForKeyNotNull:@"leaseExpiryDate"];
     model.lotPT = [TypeValueModel getTypeValueFromResponse:[response objectForKeyNotNull:@"lotPT"]];
     model.masterTitle = [response valueForKeyNotNull:@"masterTitle"];
    
     model.mukim = [TypeValueModel getTypeValueFromResponse:[response objectForKeyNotNull:@"mukim"]];
     model.negeri = [response valueForKeyNotNull:@"negeri"];
     model.parcelNo = [response valueForKeyNotNull:@"parcelNo"];
     model.project = [ProjectHousingModel getProjectHousingFromResponse:[response objectForKeyNotNull:@"project"]];
     model.propertyID = [response valueForKeyNotNull:@"propertyID"];
     model.propertyType = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"propertyType"]];
    model.proprietor = [StaffModel getStaffFromResponse:[response objectForKeyNotNull:@"proprietor"]];
    model.relatedMatter = [SearchResultModel getSearchResultArrayFromResponse:[response objectForKeyNotNull:@"relatedMatter"]];
    model.restrictionAgainst = [response valueForKeyNotNull:@"restrictionAgainst"];
    model.restrictionInInterest = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"restrictionInInterest"]];
    model.spaAccParcelNo = [response valueForKeyNotNull:@"spaAccParcelNo"];
    model.spaArea = [TypeValueModel getTypeValueFromResponse:[response objectForKeyNotNull:@"spaArea"]];
    model.spaBuildingNo = [response valueForKeyNotNull:@"spaBuildingNo"];
    model.spaCondoName = [response valueForKeyNotNull:@"spaCondoName"];
    model.spaParcel = [TypeValueModel getTypeValueFromResponse:[response objectForKeyNotNull:@"spaParcel"]];
    model.spaStoreyNo = [response valueForKeyNotNull:@"spaStoreyNo"];
    model.storeyNo = [response valueForKeyNotNull:@"storeyNo"];
    model.tenure = [response valueForKeyNotNull:@"tenure"];
    model.title = [TypeValueModel getTypeValueFromResponse:[response objectForKeyNotNull:@"title"]];
    model.titleIssued = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"titleIssued"]];
    model.totalShare = [response valueForKeyNotNull:@"totalShare"];
    model.unitShare = [response valueForKeyNotNull:@"unitShare"];
    
    return model;
}

@end
