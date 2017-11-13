//
//  ContactModel.h
//  Denning
//
//  Created by DenningIT on 26/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CodeDescription;
@interface ContactModel : NSObject

@property (strong, nonatomic) NSString* contactCode;

@property (strong, nonatomic) NSString* dateOfBirth;

@property (strong, nonatomic) NSString* citizenShip;

@property (strong, nonatomic) NSString* fax;

@property (strong, nonatomic) CodeDescription* IRDBranch;

@property (strong, nonatomic) CodeDescription* occupation;

@property (strong, nonatomic) NSString* name;

@property (strong, nonatomic) NSString* IDNo;

@property (strong, nonatomic) CodeDescription *idType;

@property (strong, nonatomic) NSString *contactTitle;

@property (strong, nonatomic) NSString *InviteToDenning;

@property (strong, nonatomic) NSString *website;

@property (strong, nonatomic) NSString *homePhone;

@property (strong, nonatomic) NSString * mobilePhone;

@property (strong, nonatomic) NSString * officePhone;

@property (strong, nonatomic) NSString * email;

@property (strong, nonatomic) AddressModel * address;

@property (strong, nonatomic) NSString *contactPerson;

@property (strong, nonatomic) NSString *registeredOffice;

@property (strong, nonatomic) NSString *KPLama;

@property (strong, nonatomic) NSArray * relatedMatter;

@property (strong, nonatomic) NSString * tax;

@property (strong, nonatomic) NSString* matterDescription;

+ (ContactModel*) getContactFromResponse: (NSDictionary*) response;

@end
