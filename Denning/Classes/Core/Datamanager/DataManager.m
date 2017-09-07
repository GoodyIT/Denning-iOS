//
//  DataManager.m
//  Reach-iOS
//
//  Created by AlexFill on 23.02.16.
//  Copyright © 2016 Maksym Rachytskyy. All rights reserved.
//

#import "DataManager.h"
#import "FirmURLModel.h"
#import "UserModel.h"

@interface DataManager()

@end

@implementation DataManager
@synthesize user;
@synthesize denningArray;
//@synthesize bussinessArray;
@synthesize personalArray;
@synthesize searchType;
@synthesize documentView;

+ (DataManager *)sharedManager {
    static DataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        searchType = @"Public";
        documentView = @"nothing";
        user = [UserModel allObjects].firstObject;
        if (!user) {
            [[RLMRealm defaultRealm] transactionWithBlock:^{
                user = [UserModel createInDefaultRealmWithValue:@[@"", @"", @"",  @"", @"", @"", @"", @"", @"", @"", @0, @"Public"]];
            }];
        }
    }
    
    return self;
}

- (void) getFirmServerArrayFromResponse: (NSDictionary*) response {
    self.denningArray = [FirmURLModel getFirmArrayFromResponse:[response objectForKey:@"catDenning"]];
//    self.bussinessArray = [FirmURLModel getFirmArrayFromResponse:[response objectForKey:@"catBussiness"]];
    self.personalArray = [FirmURLModel getFirmArrayFromResponse:[response objectForKey:@"catPersonal"]];
}

- (NSString*) determineUserType
{
    NSString* type;
    if (self.denningArray.count > 0) {
        type = @"denning";
    } else if (self.personalArray.count > 0) {
        type = @"client";
    } else {
        type = @"";
    }
    return type;
}

- (void) setUserInfoFromLogin: (NSDictionary*) response
{
    [self getFirmServerArrayFromResponse:response];
    
    [self _setInfoWithValue:[response objectForKeyNotNull:@"email"] for:@"email"];
    [self _setInfoWithValue:[self determineUserType] for:@"userType"];
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        user.email = [response objectForKeyNotNull:@"email"];
        user.phoneNumber = [response objectForKeyNotNull:@"hpNumber"];
        user.sessionID = [response objectForKeyNotNull:@"sessionID"];
        user.status = [response objectForKeyNotNull:@"status"];
        user.username = [response objectForKeyNotNull:@"name"];
        user.userType = [self determineUserType];
    }];
}

- (void) setUserPassword: (NSString*) password
{
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        user.password = password;
    }];
}

- (void) setUserInfoFromNewDeviceLogin: (NSDictionary*) response
{
    [self getFirmServerArrayFromResponse:response];
    [self _setInfoWithValue:[self determineUserType] for:@"userType"];
    
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        user.status = [response objectForKeyNotNull:@"status"];
        user.userType = [self determineUserType];
    }];
}

- (void) setUserInfoFromChangePassword: (NSDictionary*) response
{
    [self setUserInfoFromNewDeviceLogin:response];
}

- (void) _setInfoWithValue:(NSString*) value for:(NSString*) key
{
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.denningshare.extension"];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

- (void) setSessionID: (NSString*) sessionID
{
    [self _setInfoWithValue:sessionID for:@"sessionID"];
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        user.sessionID = sessionID;
    }];
}

- (void) setServerAPI: (NSString*) serverAPI withFirmName:(NSString*) firmName withFirmCity:(NSString*)firmCity
{
    self.searchType = @"General";
    [self _setInfoWithValue:serverAPI for:@"api"];
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        user.serverAPI = serverAPI;
        user.firmName = firmName;
        user.firmCity = firmCity;
    }];
}

@end
