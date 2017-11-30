//
//  AddressModel.m
//  Denning
//
//  Created by DenningIT on 24/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AddressModel.h"
#import "NSDictionary+NotNull.h"

@implementation AddressModel
@synthesize city;
@synthesize country;
@synthesize fullAddress;
@synthesize line1;
@synthesize line2;
@synthesize line3;
@synthesize state;
@synthesize postCode;

+ (AddressModel*) getAddressFromResponse: (NSDictionary*) response
{
    AddressModel* addressModel = [AddressModel new];
    
    if (response != nil && ![response isKindOfClass:[NSString class]]) {
        addressModel.city = [response valueForKeyNotNull:@"city"];
        addressModel.country = [response valueForKeyNotNull:@"country"];
        addressModel.fullAddress = [response valueForKeyNotNull:@"fullAddress"];
        addressModel.line1 = [response valueForKeyNotNull:@"line1"];
        addressModel.line2 = [response valueForKeyNotNull:@"line2"];
        addressModel.line3 = [response valueForKeyNotNull:@"line3"];
        addressModel.postCode = [response valueForKeyNotNull:@"postcode"];
        addressModel.state = [response valueForKeyNotNull:@"state"];
    } else {
        addressModel.city = @"";
        addressModel.country = @"";
        addressModel.fullAddress = @"";
        addressModel.line1 = @"";
        addressModel.line2 = @"";
        addressModel.line3 = @"";
        addressModel.postCode = @"";
        addressModel.state = @"";
    }
    
    return addressModel;
}

+ (NSArray*) getAddressArrayFromResonse: (NSDictionary*) response
{
    NSMutableArray *addressArray = [[NSMutableArray alloc] init];
    
    if ([response isKindOfClass:[NSArray class]]) {
        for (NSDictionary* dictionary in response) {
            [addressArray addObject:[AddressModel getAddressFromResponse:dictionary]];
        }
    }
    
    return addressArray;
}
@end
