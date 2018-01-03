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
@synthesize personalArray;
@synthesize denningContactArray;
@synthesize searchType;
@synthesize documentView;
@synthesize userAgreementAccepted;
@synthesize tempServerURL;
@synthesize isExpire;

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
        userAgreementAccepted = NO;
        tempServerURL = @"";
        isExpire = NO;
        user = [UserModel allObjects].firstObject;
        if (!user) {
            [[RLMRealm defaultRealm] transactionWithBlock:^{
                user = [UserModel createInDefaultRealmWithValue:@[@"", @"", @"",  @"", @"", @"", @"", @"", @"", @"", @0, @"", @""]];
            }];
        }
    }
    
    return self;
}

- (void) getFirmServerArrayFromResponse: (NSDictionary*) response {
    self.denningArray = [FirmURLModel getFirmArrayFromResponse:[response objectForKey:@"catDenning"]];
    self.personalArray = [FirmURLModel getFirmArrayFromResponse:[response objectForKey:@"catPersonal"]];
}

- (void) determineUserType
{
    [[NSUserDefaults standardUserDefaults] setBool:personalArray.count > 0 forKey:@"isClient"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setUserInfoFromLogin: (NSDictionary*) response
{
    [self getFirmServerArrayFromResponse:response];
    
    [self _setInfoWithValue:[response valueForKeyNotNull:@"email"] for:@"email"];
    [self determineUserType];
    [self _setInfoWithValue:[response valueForKeyNotNull:@"userType"] for:@"userType"];
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        user.email = [response valueForKeyNotNull:@"email"];
        user.avatarUrl = [response valueForKeyNotNull:@"avatarUrl"];
        user.phoneNumber = [response valueForKeyNotNull:@"hpNumber"];
        user.sessionID = [response valueForKeyNotNull:@"sessionID"];
        user.status = [response valueForKeyNotNull:@"status"];
        user.username = [response valueForKeyNotNull:@"name"];
        user.userType = [response valueForKeyNotNull:@"userType"];
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
    [self determineUserType];
    [self _setInfoWithValue:[response valueForKeyNotNull:@"userType"] for:@"userType"];
    
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        user.password = [response valueForKeyNotNull:@"password"];
        user.status = [response objectForKeyNotNull:@"status"];
        user.userType = [response valueForKeyNotNull:@"userType"];
    }];
}

- (void) setUserInfoFromChangePassword: (NSDictionary*) response
{
    [self setUserInfoFromNewDeviceLogin:response];
}

- (void) _setInfoWithValue:(NSString*) value for:(NSString*) key
{
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:kGroupShareIdentifier];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

- (void) setSessionID: (NSDictionary*) response
{
    [self getFirmServerArrayFromResponse:response];
    [self setOnlySessionID:[response valueForKeyNotNull:@"sessionID"]];
}

- (void) setOnlySessionID:(NSString*) sessionID {
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

- (BOOL) isClient {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (BOOL)[defaults boolForKey:@"isClient"];
}

- (BOOL) isLoggedIn {
    return user.email.length > 0 && user.password.length > 0;
}

- (BOOL) isPublicUser {
    return user.userType.length > 0 && [user.userType isEqualToString:@"public"];
}

- (BOOL) isStaff {
    return [user.userType isEqualToString:@"denning"];
}

- (BOOL) isDenningUser {
    BOOL isSupportMemember = NO;
    for (ChatFirmModel* firmModel in denningContactArray) {
        NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.email CONTAINS[cd] %@", user.email];
        NSArray *filteredUsers = [firmModel.users filteredArrayUsingPredicate:usersSearchPredicate];
        if (filteredUsers.count > 0) {
            isSupportMemember = YES;
            break;
        }
    }
    
    return isSupportMemember;
}

- (void) clearData {
    [self _setInfoWithValue:@"" for:@"email"];
    [self _setInfoWithValue:@"" for:@"userType"];
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        user.email = @"";
        user.phoneNumber = @"";
        user.sessionID = @"";
        user.status = @"";
        user.username = @"";
        user.userType = @"";
        user.serverAPI = @"";
        user.firmName = @"";
        user.firmCity = @"";
    }];
    
    personalArray = [NSMutableArray new];
    [self determineUserType];
}

@end
