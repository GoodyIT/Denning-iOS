//
//  RelatedMatterModel.h
//  Denning
//
//  Created by DenningIT on 26/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GeneralGroup;
@class PartyGroupModel;
@class SolicitorGroup;
@class CourtModel;
@class StaffModel;
@class MatterCodeModel;
@class ClientModel;
@class MatterBranchModel;

@interface RelatedMatterModel : NSObject

@property (strong, nonatomic) NSString *systemNo;

@property (strong, nonatomic) NSString* contactCode;

@property (strong, nonatomic) NSString * clientName;

// Matter information
@property (strong, nonatomic) NSString* openDate;

@property (strong, nonatomic) NSString * ref;

@property (strong, nonatomic) StaffModel * legalAssistant;

@property (strong, nonatomic) NSString *fileLocation;

@property (strong, nonatomic) NSString* locationBox;

@property (strong, nonatomic) NSString* locationPhysical;

@property (strong, nonatomic) NSString* locationPocket;

@property (strong, nonatomic) NSString* dateClose;

@property (strong, nonatomic) MatterCodeModel * matter;

@property (strong, nonatomic) MatterBranchModel* branch;

@property (strong, nonatomic) CodeDescription* fileStatus;

// Court Information
@property (strong, nonatomic) CourtModel* court;    

// Partner
@property (strong, nonatomic) StaffModel* partner;

// Party Group
@property (strong, nonatomic) NSArray<PartyGroupModel*> *partyGroupArray;

// Primary Client
@property (strong, nonatomic) ClientModel* primaryClient;

// Solicitor
@property (strong, nonatomic) NSArray<SolicitorGroup*> * solicitorGroupArray;

// Property
@property (strong, nonatomic) NSArray<PropertyModel*> * propertyGroupArray;

// Bank
@property (strong, nonatomic) NSArray<BankGroupModel*> * bankGroupArray;

// clerk
@property (strong, nonatomic) StaffModel* clerk;

// ImportantRM
@property (strong, nonatomic) NSArray<GeneralGroup*> * RMGroupArray;

// DateRM
@property (strong, nonatomic) NSArray<GeneralGroup*> * dateGroupArray;

// Other information
@property (strong, nonatomic) NSArray<GeneralGroup*> * textGroupArray ;

@property (strong, nonatomic) NSArray * relatedMatter;

@property (strong, nonatomic) NSString* remarks;

+ (RelatedMatterModel*) getRelatedMatterFromResponse: (NSDictionary*) response;

@end
