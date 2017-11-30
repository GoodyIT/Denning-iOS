//
//  StaffModel.m
//  Denning
//
//  Created by DenningIT on 08/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "StaffModel.h"
#import "AddressModel.h"
#import "NSDictionary+NotNull.h"

@implementation StaffModel

+ (StaffModel*) getStaffFromResponse: (NSDictionary*) response
{
    StaffModel *staff = [StaffModel new];
    staff.IDNo = [response valueForKeyNotNull:@"IDNo"];
    staff.address = [AddressModel getAddressFromResponse:[response objectForKeyNotNull:@"address"]];
    staff.citizenship = [response valueForKeyNotNull:@"citizenship"];
    staff.staffCode = [response valueForKeyNotNull:@"code"];
    staff.dateBirth = [response valueForKeyNotNull:@"dateBirth"];
    staff.emailAddress = [response valueForKeyNotNull:@"emailAddress"];
    staff.idTypeCode = [[response objectForKeyNotNull:@"idType"] valueForKeyNotNull:@"code"];
    staff.idTypeDescription = [[response objectForKeyNotNull:@"idType"] valueForKeyNotNull:@"description"];
    staff.name = [response valueForKeyNotNull:@"name"];
    staff.phoneFax = [response valueForKeyNotNull:@"phoneFax"];
    staff.phoneHome = [response valueForKeyNotNull:@"phoneHome"];
    staff.phoneOffice = [response valueForKeyNotNull:@"phoneOffice"];
    staff.title = [response valueForKeyNotNull:@"title"];
    staff.webSite = [response valueForKeyNotNull:@"webSite"];
    staff.chatStatus = [response valueForKeyNotNull:@"chatStatus"];
    staff.nickName = [response valueForKeyNotNull:@"nickName"];
    staff.userID = [response valueForKeyNotNull:@"userID"];
    
    return staff;
}

+ (NSArray*) getStaffArrayFromRepsonse: (NSDictionary*) response
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (id obj in response) {
        [result addObject:[StaffModel getStaffFromResponse:obj]];
    }
    
    return result;
}

@end
