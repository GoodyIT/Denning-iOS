//
//  DataManager.h
//  Reach-iOS
//
//  Created by AlexFill on 23.02.16.
//  Copyright © 2016 Maksym Rachytskyy. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface FirmArray : RLMObject
//@property RLMArray

@class UserModel;
@interface DataManager : NSObject

@property (strong, nonatomic) NSString  *searchType;
@property (strong, nonatomic) UserModel *user;
@property (strong, nonatomic) NSArray* denningArray;
@property (strong, nonatomic) NSArray* personalArray;
@property (strong, nonatomic) NSString* seletedUserType;
@property (strong, nonatomic) NSNumber* statusCode;
@property (strong, nonatomic) NSString* documentView;
@property (strong, nonatomic) NSMutableArray* favClientContactsArray;
@property (strong, nonatomic) NSMutableArray* favStaffContactsArray;
@property (strong, nonatomic) NSMutableArray* clientContactsArray;
@property (strong, nonatomic) NSMutableArray* staffContactsArray;
@property (strong, nonatomic) NSMutableArray* denningContactArray;
@property (assign, nonatomic) BOOL userAgreementAccepted;

@property (strong, nonatomic) NSString* tempServerURL;

@property (strong, nonatomic) NSString* isFirstLoading;

@property (strong, nonatomic) NSString* badgeValue;

@property (strong, nonatomic) NSString* dtExpire;
@property (assign, nonatomic) BOOL isExpire;

+ (DataManager *)sharedManager;

- (void) setUserPassword: (NSString*) password;

- (void) setUserInfoFromLogin: (NSDictionary*) response;

- (void) setSessionID: (NSDictionary*) response;

- (void) setOnlySessionID:(NSString*) sessionID;

- (void) setUserInfoFromNewDeviceLogin: (NSDictionary*) response;

- (void) setUserInfoFromChangePassword: (NSDictionary*) response;

- (void) setServerAPI: (NSString*) serverAPI withFirmName:(NSString*) firmName withFirmCity:(NSString*)firmCity;

- (BOOL) isClient;

- (BOOL) isLoggedIn;

- (BOOL) isPublicUser;

- (BOOL) isDenningUser;

- (BOOL) isStaff;

- (void) clearData;

@end
