//
//  ProjectHousingModel.h
//  Denning
//
//  Created by DenningIT on 17/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectHousingModel : NSObject
@property (strong, nonatomic) NSString* housingCode;
@property (strong, nonatomic) StaffModel* developer;
@property (strong, nonatomic) NSString* licenseNo;
@property (strong, nonatomic) NSString* masterTitle;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* phase;
@property (strong, nonatomic) StaffModel* proprietor;

+ (ProjectHousingModel*) getProjectHousingFromResponse: (NSDictionary*) response;

+ (NSArray*) getProjectHousingArrayFromResponse:(NSDictionary*) response;
@end
