//
//  DataManager.h
//  Reach-iOS
//
//  Created by AlexFill on 23.02.16.
//  Copyright © 2016 Maksym Rachytskyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

//@interface FirmArray : RLMObject
//@property RLMArray

@class UserModel;
@class ChatFirmModel;
@class FirmURLModel;
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
@property (strong, nonatomic) NSMutableArray<ChatFirmModel*>* clientContactsArray;
@property (strong, nonatomic) NSMutableArray<ChatFirmModel*>* staffContactsArray;
@property (strong, nonatomic) NSMutableArray<ChatFirmModel*>* denningContactArray;
@property (assign, nonatomic) BOOL userAgreementAccepted;

@property (strong, nonatomic) NSString* tempServerURL;
@property (strong, nonatomic) NSString* tempTheCode;

@property (strong, nonatomic) NSString* isFirstLoading;

@property (strong, nonatomic) NSString* badgeValue;

@property (strong, nonatomic) NSString* dtExpire;
@property (assign, nonatomic) BOOL isExpire;

@property (assign, nonatomic) BOOL isSessionExpired;

+ (DataManager *)sharedManager;

- (void) setUserPassword: (NSString*) password;

- (void) setUserInfoFromLogin: (NSDictionary*) response;

- (void) setSessionID: (NSDictionary*) response;

- (void) setAvatarURL:(NSString*) url;

- (void) setOnlySessionID:(NSString*) sessionID;

- (void) setTheCode:(NSString*) theCode;

- (void) setUserInfoFromNewDeviceLogin: (NSDictionary*) response;

- (void) setUserInfoFromChangePassword: (NSDictionary*) response;

- (void) setServerAPI: (NSString*) serverAPI firmURLModel:(FirmURLModel*) firmURLModel;

- (BOOL) isClient;

- (BOOL) isLoggedIn;

- (BOOL) isPublicUser;

- (BOOL) isDenningUser;

- (BOOL) isSuperUser:(NSString*) email;

- (BOOL) checkDenningUser:(NSString*) email;

- (BOOL) isStaff;

- (void) clearData;

- (void) setOldLocation:(CLLocation*) oldLocation lastLoggedDateTime:(NSDate*) lastLoggedDateTime;

- (void) setStreetName:(NSString*) streetName;

- (void) setQBLoginState: (BOOL) state;

- (BOOL) havingQBAccount;

@end
