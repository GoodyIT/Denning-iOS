//
//  SoliciorModel.h
//  Denning
//
//  Created by DenningIT on 20/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoliciorModel : NSObject

@property (strong, nonatomic) NSString *IDNo;
@property (strong, nonatomic) AddressModel *address;
@property (strong, nonatomic) NSString * citizenship;
@property (strong, nonatomic) NSString * solicitorCode;
@property (strong, nonatomic) NSString * dateBirth;
@property (strong, nonatomic) NSString * emailAddress;
@property (strong, nonatomic) NSString * idType;
@property (strong, nonatomic) NSString * idTypeCode;
@property (strong, nonatomic) NSString *idTypeDescription;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneFax;
@property (strong, nonatomic) NSString *phoneHome;
@property (strong, nonatomic) NSString *phoneMobile;
@property (strong, nonatomic) NSString *phoneOffice;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *webSite;

+ (SoliciorModel*) getSolicitorFromResponse: (NSDictionary*) response;

+ (NSArray*) getSolicitorArrayFromRespsonse: (NSDictionary*) response;

@end
