//
//  AddPropertyModel.h
//  Denning
//
//  Created by Ho Thong Mee on 27/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddPropertyModel : NSObject

@property(strong, nonatomic) NSString* propertyCode;
@property(strong, nonatomic) NSString* accBuildingNo;
@property(strong, nonatomic) NSString* accParcelNo;
@property(strong, nonatomic) NSString* accStoreyNo;
@property(strong, nonatomic) NSString* address;
@property(strong, nonatomic) NSString* approvingAuthority;
@property(strong, nonatomic) TypeValueModel* area;
@property(strong, nonatomic) NSString* buildingNo;
@property(strong, nonatomic) NSString* daerah;
@property(strong, nonatomic) StaffModel* developer;
@property(strong, nonatomic) NSString* fullTitle;
@property(strong, nonatomic) NSString* landUse;
@property(strong, nonatomic) NSString* leaseExpiryDate;
@property(strong, nonatomic) TypeValueModel* lotPT;
@property(strong, nonatomic) MasterTitleModel* masterTitle;
@property(strong, nonatomic) TypeValueModel* mukim;
@property(strong, nonatomic) NSString* negeri;
@property(strong, nonatomic) NSString* parcelNo;
@property(strong, nonatomic) ProjectHousingModel* project;
@property(strong, nonatomic) NSString* propertyID;
@property(strong, nonatomic) CodeDescription* propertyType;
@property(strong, nonatomic) StaffModel* proprietor;
@property(strong, nonatomic) NSArray* relatedMatter;
@property(strong, nonatomic) NSString* restrictionAgainst;
@property(strong, nonatomic) CodeDescription* restrictionInInterest;
@property(strong, nonatomic) NSString* spaAccParcelNo;
@property(strong, nonatomic) TypeValueModel* spaArea;
@property(strong, nonatomic) NSString* spaBuildingNo;
@property(strong, nonatomic) NSString* spaCondoName;
@property(strong, nonatomic) TypeValueModel* spaParcel;
@property(strong, nonatomic) NSString* spaStoreyNo;
@property(strong, nonatomic) NSString* storeyNo;
@property(strong, nonatomic) NSString* tenure;
@property(strong, nonatomic) TypeValueModel* title;
@property(strong, nonatomic) CodeDescription* titleIssued;
@property(strong, nonatomic) NSString* totalShare;
@property(strong, nonatomic) NSString* unitShare;

+ (AddPropertyModel*) getAddPropertyFromResponse:(NSDictionary*) response;

@end
