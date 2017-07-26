//
//  QMNetworkManager.m
//  reach-ios
//
//  Created by Admin on 2016-11-30.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNetworkManager.h"
#import "QMCore.h"
#import "QMContent.h"
#import "QMMessagesHelper.h"
#import "SearchResultModel.h"
#import "NSError+Network.h"
#import "DIGlobal.h"
#import "DIHelpers.h"
#import "ClientModel.h"

@interface QMNetworkManager ()

@property(nonatomic, strong) NSURLSession *session;

@end

@implementation QMNetworkManager


+ (QMNetworkManager *)sharedManager {
    static QMNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QMNetworkManager alloc] init];
    });
    
    return manager;
}

#pragma mark -  Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        [self initManager];
    }
    
    return self;
}

- (void)initManager
{
    self.manager = [[AFHTTPSessionManager  alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self.manager.responseSerializer =  [AFJSONResponseSerializer serializer];
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager.requestSerializer.timeoutInterval= 100;
    [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.manager.requestSerializer setValue:@"{334E910C-CC68-4784-9047-0F23D37C9CF9}" forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:@" iPhone@denning.com.my" forHTTPHeaderField:@"webuser-id"];
    
    self.session = [NSURLSession sharedSession];
    
    // Get the default params
    self.ipWAN = [DIHelpers getWANIP];
    self.ipLan = [DIHelpers getLANIP];
    self.os = [DIHelpers getOSName];
    self.device = [DIHelpers getDevice];
    self.deviceName = [DIHelpers getDeviceName];
    self.MAC = [DIHelpers getMAC];
}

- (AFHTTPSessionManager*) setLoginHTTPHeader
{
    [self.manager.requestSerializer setValue:@"{334E910C-CC68-4784-9047-0F23D37C9CF9}" forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:@"iPhone@denning.com.my" forHTTPHeaderField:@"webuser-id"];
    
    return self.manager;
}

- (AFHTTPSessionManager*) setOtherForLoginHTTPHeader
{
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.email forHTTPHeaderField:@"webuser-id"];
    
    return self.manager;
}

- (void) setChangePasswordHTTPHeader {
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.email forHTTPHeaderField:@"webuser-id"];
}

- (void) setAddContactLoginHTTPHeader
{
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.email forHTTPHeaderField:@"webuser-id"];
}

- (void) setDashboardLoginHTTPHeader
{
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.sessionID forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.email forHTTPHeaderField:@"webuser-id"];
}

- (NSDictionary*) buildRquestParamsFromDictionary: (NSDictionary*) dict
{
    NSDictionary* basicParams = @{
                                    @"ipWAN": self.ipWAN,
                                    @"ipLAN": self.ipLan,
                                    @"OS": self.os,
                                    @"device": self.device,
                                    @"deviceName": self.deviceName,
                                    @"MAC": self.MAC
                                    };
    NSMutableDictionary* mutableBasicParams = [basicParams mutableCopy];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:dict];
    
    [mutableBasicParams addEntriesFromDictionary:params];
    
    return [mutableBasicParams copy];
}

/*
 ******** Auth *********
 */

-(void) userSignInWithEmail: (NSString*)email password:(NSString*) password withCompletion:(void(^)(BOOL success, NSString* error, NSInteger statusCode, NSDictionary* responseObject)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{
                                                            @"email": email,
                                                            @"password": password}];
    
    [self setLoginHTTPHeader];
    
    [self.manager POST:SIGNIN_URL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(YES, nil, [[responseObject objectForKey:@"statusCode"] integerValue], responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            NSHTTPURLResponse *test = (NSHTTPURLResponse *)task.response;
            
            NSLog(@"%@, %@", test.allHeaderFields, [NSHTTPURLResponse localizedStringForStatusCode:test.statusCode]);

            if (test.statusCode == 401){
                completion(NO, @"Invalid username and password", 401, nil);
            } else {
                completion(NO, error.localizedDescription, test.statusCode, nil);
            }
        }
    }];
}

- (void) sendSMSForgetPasswordWithEmail: (NSString*) email phoneNumber: (NSString*) phoneNumber reason:(NSString*) reason withCompletion:(void(^)(BOOL success, NSInteger statusCode, NSString* error, NSDictionary* response)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{
                                                                   @"email": email,
                                                                   @"hpNumber": phoneNumber,
                                                                   @"reason": reason}];
    
    [self sendSMSGeneralWithEmail:params url:FORGOT_PASSWORD_SEND_SMS_URL withCompletion:completion];
}

- (void) sendSMSRequestWithEmail: (NSString*) email phoneNumber: (NSString*) phoneNumber reason:(NSString*) reason withCompletion:(void(^)(BOOL success, NSInteger statusCode, NSString* error, NSDictionary* response)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{
                                                                   @"email": email,
                                                                   @"hpNumber": phoneNumber,
                                                                   @"reason": reason}];
    
    [self sendSMSGeneralWithEmail:params url:LOGIN_SEND_SMS_URL withCompletion:completion];
}

- (void) sendSMSForNewDeviceWithEmail: (NSString*) email activationCode: (NSString*) activationCode withCompletion: (void(^)(BOOL success, NSInteger statusCode, NSString* error, NSDictionary* response)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{
                                                                   @"email": email,
                                                                   @"activationCode": activationCode}];
    
    [self sendSMSGeneralWithEmail:params url:NEW_DEVICE_SEND_SMS_URL withCompletion:completion];
}

- (void) sendSMSGeneralWithEmail: (NSDictionary*) params url:(NSString*)url withCompletion:(void(^)(BOOL success, NSInteger statusCode, NSString* error, NSDictionary* response)) completion
{

    [self setLoginHTTPHeader];
    
    [self.manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSHTTPURLResponse *test = (NSHTTPURLResponse *)task.response;
            completion(YES, test.statusCode, nil, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            NSHTTPURLResponse *test = (NSHTTPURLResponse *)task.response;
            completion(NO, test.statusCode, error.localizedDescription, nil);
        }
    }];
}

- (void) requestForgetPasswordWithEmail: (NSString*) email phoneNumber:(NSString*) phoneNumber activationCode: (NSString*) activationCode withCompletion:(void(^)(BOOL success, NSString* error)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{@"email": email, @"hpNumber": phoneNumber, @"activationCode": activationCode}];
    
    [self setLoginHTTPHeader];
    [self.manager.requestSerializer setValue:email forHTTPHeaderField:@"webuser-id"];
    
    [self.manager POST:FORGOT_PASSWORD_REQUEST_URL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completion != nil) {
            completion(YES, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(NO, error.localizedDescription);
        }
    }];
}

- (void) changePasswordAfterLoginWithEmail: (NSString*) email password: (NSString*) password withCompletion: (void(^)(BOOL success, NSString* error, NSDictionary* response)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{@"email": email, @"password": password}];
    
    [self setChangePasswordHTTPHeader];
    
    [self.manager POST:CHANGE_PASSWORD_URL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completion != nil) {
            completion(YES, nil, responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(NO, error.localizedDescription, nil);
        }
    }];
}

- (void) getFirmListWithPage: (NSNumber*) page completion: (void(^)(NSArray* resultArray, NSError* error)) completion
{
    [self setLoginHTTPHeader];
    
    NSString* url = [NSString stringWithFormat:@"%@?page=%@", SIGNUP_FIRM_LIST_URL, page];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [FirmModel getFirmArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
    }];
}

-(void) denningSignIn:(NSString*) password withCompletion:(void(^)(BOOL success, NSString* error, NSDictionary* responseObject)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{@"email": [DataManager sharedManager].user.email, @"password": password, @"sessionID": [DataManager sharedManager].user.sessionID}];
    
    [self setLoginHTTPHeader];
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:DENNING_SIGNIN_URL];
    [self.manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completion != nil) {
            completion(YES, nil, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(NO, error.localizedDescription, nil);
        }
    }];
}

- (void) clientSignIn: (NSString*) url password:(NSString*) password withCompletion: (void(^)(BOOL success, NSDictionary * responseObject, NSString* error,  DocumentModel* doumentModel)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{@"email": [DataManager sharedManager].user.email, @"password": password, @"sessionID": [DataManager sharedManager].user.sessionID}];

    [self setLoginHTTPHeader];
    [self.manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        DocumentModel* result = [DocumentModel getDocumentFromResponse:responseObject];
        if (completion != nil) {
            completion(YES, responseObject, nil, result);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(NO, nil, error.localizedDescription, nil);
        }
    }];
}

- (void) userSignupWithUsername:(NSString*) username phone:(NSString*) phone email:(NSString*) email isLayer:(NSNumber*) isLayer firmCode: (NSNumber*) firmCode withCompletion:(void(^)(BOOL success, NSString* error)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{
                                                                   @"name": username,
                                                                   @"hpNumber": phone,
                                                                   @"email": email,
                                                                   @"isLawyer": isLayer,
                                                                   @"firmCode": firmCode}];
    
    [self setLoginHTTPHeader];
    
    [self.manager POST:SIGNUP_URL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(YES, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(NO, error.localizedDescription);
        }
    }];
}

// Home Search

- (void) getGlobalSearchFromKeyword: (NSString*) keyword searchURL:(NSString*)searchURL forCategory:(NSInteger)category searchType:(NSString*)searchType withPage:(NSNumber*)page withCompletion:(void(^)(NSArray* resultArray, NSError* error)) completion
{
    NSString* urlString;
    if (![[DataManager sharedManager].user.userType isEqualToString:@"denning"]){
        [self setLoginHTTPHeader];
        urlString = [NSString stringWithFormat:@"%@%@&category=%ld", searchURL, [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], (long)category];
    } else {
        [self setOtherForLoginHTTPHeader];
        urlString = [NSString stringWithFormat:@"%@%@&category=%ld", searchURL, [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], (long)category];
    }
    
    if ([searchType isEqualToString:@"Normal"]) { // Direct Tap on the search button
        urlString = [urlString stringByAppendingString:@"&isAutoComplete=1"];
    }
    
    [self.manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [SearchResultModel getSearchResultArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// Updates
- (void) getLatestUpdatesWithCompletion: (void(^)(NSArray* updatesArray, NSError* error)) completion
{
    [self.manager GET:UPATES_LATEST_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [NewsModel getNewsArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// News
- (void) getLatestNewsWithCompletion: (void(^)(NSArray* newsArray, NSError* error)) completion
{
    [self.manager GET:NEWS_LATEST_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [NewsModel getNewsArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// Event

- (void) getLatestEventWithStartDate: (NSString*) startDate endDate:(NSString*) endDate filter:(NSString*) filter search:(NSString*)search withCompletion: (void(^)(NSArray* eventsArray, NSError* error)) completion
{
    [self setOtherForLoginHTTPHeader];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?dateStart=%@&dateEnd=%@&filterBy=%@&search=%@", [DataManager sharedManager].user.serverAPI, EVENT_LATEST_URL, startDate, endDate, filter, search];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [EventModel getEventsArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
    }];
}

- (void) getCalenarMonthlySummaryWithYear:(NSString*) year month:(NSString*) month filter:(NSString*)filter withCompletion: (void(^)(NSArray* eventsArray, NSError* error)) completion
{
    [self setOtherForLoginHTTPHeader];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?year=%@&month=%@&filterBy=%@", [DataManager sharedManager].user.serverAPI, CALENDAR_MONTHLY_SUMMARY_URL, year, month, filter];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completion != nil) {
            completion(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
    }];
}

// Ads
- (void) getAdsWithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    [self.manager.requestSerializer setValue:@"{334E910C-CC68-4784-9047-0F23D37C9CF9}"  forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.email forHTTPHeaderField:@"webuser-id"];

    [self.manager GET:HOME_ADS_GET_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [AdsModel getAdsArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

/*
 *  Search
 */

// property

- (void) loadPropertyfromSearchWithCode: (NSString*) code completion: (void(^)(AddPropertyModel* propertyModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/Property/%@", [DataManager sharedManager].user.serverAPI, code];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        AddPropertyModel* result = [AddPropertyModel getAddPropertyFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// Contact
- (void) loadContactFromSearchWithCode: (NSString*) code completion: (void(^)(ContactModel* contactModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/Contact/%@", [DataManager sharedManager].user.serverAPI, code];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        ContactModel* result = [ContactModel getContactFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];

}

// Related Matter
- (void) loadRelatedMatterWithCode: (NSString*) code completion: (void(^)(RelatedMatterModel* contactModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/matter/%@", [DataManager sharedManager].user.serverAPI, code];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        RelatedMatterModel* result = [RelatedMatterModel getRelatedMatterFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) loadFileNoteListWithCode:(NSString*) code withPage:page
completion: (void(^)(NSArray *result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/table/Note?fileNo=%@&page=%@", [DataManager sharedManager].user.serverAPI, code, page];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [FileNoteModel getFileNoteArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) saveFileNoteWithParams: (NSDictionary*) params completion: (void(^)(FileNoteModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString: @"denningwcf/v1/table/Note"];
    [self setOtherForLoginHTTPHeader];
    [self.manager POST:_url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion([FileNoteModel getFileNoteFromResonse:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) updateFileNoteWithParams: (NSDictionary*) params completion: (void(^)(FileNoteModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString: @"denningwcf/v1/table/Note"];
    [self setOtherForLoginHTTPHeader];
    [self.manager PUT:_url parameters:params  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion([FileNoteModel getFileNoteFromResonse:responseObject],nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

// File Upload
- (void) getSuggestedNameWithUrl:(NSString*) url withPage:(NSNumber*)page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, url,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    [self setAddContactLoginHTTPHeader];
    
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completion != nil) {
            completion(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) uploadFileWithUrl:(NSString*) url params:(NSDictionary*) params WithCompletion:(void(^)(NSString* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:_url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

// Payment Record
- (void) getPaymentRecordWithFileNo:(NSString*) fileNo completion:(void(^)(NSDictionary* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/PaymentRecord/%@", [DataManager sharedManager].user.serverAPI, fileNo];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        if (completion != nil) {
            completion(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// Template
- (void) getTemplateWithFileno:(NSString*) fileNo online:(NSString*) online category:(NSString*) category type:(NSString*) type page:(NSNumber*) page search:(NSString*) search withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/Table/cboTemplate?fileno=%@&Online=%@&category=%@&Type=%@&page=%@&search=%@", [DataManager sharedManager].user.serverAPI, fileNo, online, category, type, page, search];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [self setOtherForLoginHTTPHeader];
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [TemplateModel getTemplateArrayFromResponse:responseObject];
        
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) getTemplateCategoryWithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/Table/cbotemplatecategory/only", [DataManager sharedManager].user.serverAPI];
    [self setOtherForLoginHTTPHeader];
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completion != nil) {
            completion(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) getTemplateTypeWithFilter:(NSString*) filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/Table/cbotemplatecategory?filter=%@", [DataManager sharedManager].user.serverAPI, [filter stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    [self setOtherForLoginHTTPHeader];
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completion != nil) {
            completion(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// Bank
- (void) loadBankFromSearchWithCode: (NSString*) code completion: (void(^)(BankModel* bankModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/bank/branch/%@", [DataManager sharedManager].user.serverAPI, code];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        BankModel* result = [BankModel getBankFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// Government Offices
- (void) loadGovOfficesFromSearchWithCode: (NSString*) code type:(NSString*) type completion: (void(^)(GovOfficeModel* govOfficeModel, NSError* error)) completion
{
    NSString *point = @"";
    if ([type isEqualToString:@"LandOffice"]) {
        point = @"landOffice";
    } else {
        point = @"PTG";
    }
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/GovOffice/%@/%@", [DataManager sharedManager].user.serverAPI, point, code];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        GovOfficeModel* result = [GovOfficeModel getGovOfficeFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// Legal firm (Solicitor)
- (void) loadLegalFirmWithCode: (NSString*) code completion: (void(^)(LegalFirmModel* legalFirmModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/Solicitor/%@", [DataManager sharedManager].user.serverAPI, code];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        LegalFirmModel* result = [LegalFirmModel getLegalFirmFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}



// Ledger
- (void) loadLedgerWithCode: (NSString*) code completion: (void(^)(NewLedgerModel* newLedgerModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/%@/fileLedger", [DataManager sharedManager].user.serverAPI, code];
//    NSString* url = [NSString stringWithFormat:@"http://121.196.213.102:9339/denningwcf/v1/%@/ledger", code];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NewLedgerModel* result = [NewLedgerModel getNewLedgerModelFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// Ledger detail
- (void) loadLedgerDetailURL:(NSString*) url completion: (void(^)(NSArray* ledgerModelDetailArray, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].user.serverAPI, [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];

    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray* result = [LedgerDetailModel getLedgerDetailArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

// Documents
- (void) loadDocumentWithCode: (NSString*) code completion: (void(^)(DocumentModel* doumentModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/matter/%@/fileFolder", [DataManager sharedManager].user.serverAPI, code];
    [self setOtherForLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        DocumentModel* result = [DocumentModel getDocumentFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) getChatContactsWithCompletion:(void(^)(void)) completion
{
    [self setLoginHTTPHeader];
    NSString* url = [GET_CHAT_CONTACT_URL stringByAppendingString:[DataManager sharedManager].user.email];
    __block ChatContactModel* chatContacts;
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        chatContacts = [ChatContactModel getChatContactFromResponse:responseObject];
        QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100];
        [QBRequest usersForPage:page successBlock:^(QBResponse *response, QBGeneralResponsePage *pageInformation, NSArray *users) {
            // Favorite Contact
            [DataManager sharedManager].favoriteContactsArray = [NSMutableArray new];
            for (ChatFirmModel *chatFirmModel in chatContacts.favoriteContacts) {
                ChatFirmModel* newModel = [ChatFirmModel new];
                newModel.firmName = chatFirmModel.firmName;
                newModel.firmCode = chatFirmModel.firmCode;
                NSMutableArray* userArray = [NSMutableArray new];
                for (ChatUserModel* chatUserModel in chatFirmModel.users) {
                    for (QBUUser* user in users) {
                        if ([[chatUserModel.email lowercaseString] isEqualToString:user.email]) {
                            [userArray addObject:user];
                        }
                    }
                }
                newModel.users = [userArray copy];
                [[DataManager sharedManager].favoriteContactsArray addObject:newModel];
            }
            
            // Client Contact
            [DataManager sharedManager].clientContactsArray = [NSMutableArray new];
            for (ChatFirmModel *chatFirmModel in chatContacts.clientContacts) {
                ChatFirmModel* newModel = [ChatFirmModel new];
                newModel.firmName = chatFirmModel.firmName;
                newModel.firmCode = chatFirmModel.firmCode;
                NSMutableArray* userArray = [NSMutableArray new];
                for (ChatUserModel* chatUserModel in chatFirmModel.users) {
                    for (QBUUser* user in users) {
                        if ([[chatUserModel.email lowercaseString] isEqualToString:user.email]) {
                            [userArray addObject:user];
                        }
                    }
                }
                newModel.users = [userArray copy];
                [[DataManager sharedManager].clientContactsArray addObject:newModel];
            }
            
            // Staff Contact
            [DataManager sharedManager].staffContactsArray = [NSMutableArray new];
            for (ChatFirmModel *chatFirmModel in chatContacts.staffContacts) {
                ChatFirmModel* newModel = [ChatFirmModel new];
                newModel.firmName = chatFirmModel.firmName;
                newModel.firmCode = chatFirmModel.firmCode;
                NSMutableArray* userArray = [NSMutableArray new];
                for (ChatUserModel* chatUserModel in chatFirmModel.users) {
                    for (QBUUser* user in users) {
                        if ([[chatUserModel.email lowercaseString] isEqualToString:user.email]) {
                            [userArray addObject:user];
                        }
                    }
                }
                newModel.users = [userArray copy];
                [[DataManager sharedManager].staffContactsArray addObject:newModel];
            }
            
            if (completion != nil) {
                completion();
            }

        } errorBlock:^(QBResponse *response) {
            // Handle error
            NSLog(@"Retrieve user error%@", response.error);
        }];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error.localizedDescription);
        // Error Message
    }];
}

- (void) addFavoriteContact: (QBUUser*) user withCompletion:(void(^)(NSError* error)) completion
{
    [self setLoginHTTPHeader];
    NSDictionary* params = @{@"email": [QBSession currentSession].currentUser.email, @"favourite": user.email};
    NSString* url = PUBLIC_ADD_FAVORITE_CONTACT_URL;
    
    [self.manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            NSHTTPURLResponse *test = (NSHTTPURLResponse *)task.response;
            
            NSLog(@"%@, %@", test.allHeaderFields, [NSHTTPURLResponse localizedStringForStatusCode:test.statusCode]);
            completion(error);
        }
    }];
}

- (void) removeFavoriteContact: (QBUUser*) user withCompletion:(void(^)(NSError* error)) completion
{
    [self setLoginHTTPHeader];
    NSDictionary* params = @{@"email": [QBSession currentSession].currentUser.email, @"favourite": user.email};
    
    [self.manager DELETE:REMOVE_FAVORITE_CONTACT_URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(error);
        }
    }];
}

/*
 *  Add Contact
 */

- (void) getCodeDescWithUrl:(NSString*) url withPage:(NSNumber*)page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, url,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    [self setAddContactLoginHTTPHeader];
    
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [CodeDescription getCodeDescriptionArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) getDescriptionWithUrl: (NSString*) url withPage: (NSNumber*) page withSearch:(NSString*)search withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, url,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    [self setAddContactLoginHTTPHeader];
    
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completion != nil) {
            completion(responseObject, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) getPostCodeWithPage:(NSNumber*) page withSearch:(NSString*)search withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, CONTACT_POSTCODE_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    [self setAddContactLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [CityModel getCityModelArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) getBankBranchWithPage:(NSNumber*) page withSearch:(NSString*)search withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, BANK_BRANCH_GET_LIST_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    [self setAddContactLoginHTTPHeader];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray* result = [BankBranchModel getBankBranchArrayFromResponse:responseObject];
        if (completion != nil) {
            completion(result, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completion != nil) {
            completion(nil, error);
        }
        
        // Error Message
    }];
}

- (void) getSolicitorList: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI,CONTACT_SOLICITOR_GET_LIST_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [SoliciorModel getSolicitorArrayFromRespsonse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) checkIDorNameDuplication:(NSString*) string url:(NSString*)url WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@", [DataManager sharedManager].user.serverAPI,url, [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) saveContactWithData:(NSDictionary*) data withCompletion:(void(^)(ContactModel* addContact, NSError* error)) completion
{
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:CONTACT_SAVE_URL];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            ContactModel* addContact = [ContactModel getContactFromResponse:responseObject];
            completion(addContact, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) updateContactWithData:(NSDictionary*) data withCompletion:(void(^)(ContactModel* addContact, NSError* error)) completion
{
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:CONTACT_SAVE_URL];
    [self setAddContactLoginHTTPHeader];
    [self.manager PUT:url parameters:data success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            ContactModel* addContact = [ContactModel getContactFromResponse:responseObject];
            completion(addContact, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

/*
 * Court Diary
 */

- (void) getSimpleMatter:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, MATTERSIMPLE_GET_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [MatterSimple getMatterSimpleArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getStaffArray:(NSNumber*) page withSearch:(NSString*)search WithURL:(NSString*) url WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI,url, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [StaffModel getStaffArrayFromRepsonse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getCourtWithCode:(NSString*) code WithCompletion:(void(^)(EditCourtModel* model, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/v1/courtDiary/%@", [DataManager sharedManager].user.serverAPI,code];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            EditCourtModel *result = [EditCourtModel getEditCourtFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getCourtDiaryArrayWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, COURTDIARY_GET_LIST_URL,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [CourtDiaryModel getCourtDiaryArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];

}

- (void) getCoramArrayWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, COURT_CORAM_GET_LIST_URL,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [CoramModel getCoramArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
    
}

- (void) updateCourtDiaryWithData: (NSDictionary*) data WithCompletion:(void(^)(EditCourtModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:COURT_SAVE_UPATE_URL];
    [self setAddContactLoginHTTPHeader];
    [self.manager PUT:_url parameters:data success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion([EditCourtModel getEditCourtFromResponse:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}


- (void) saveCourtDiaryWithData: (NSDictionary*) data WithCompletion:(void(^)(EditCourtModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:COURT_SAVE_UPATE_URL];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:_url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion([EditCourtModel getEditCourtFromResponse:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) savePersonalDiaryWithData: (NSDictionary*) data WithCompletion:(void(^)(EditCourtModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:PERSONAL_DIARY_SAVE_URL];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:_url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) saveOfficeDiaryWithData: (NSDictionary*) data WithCompletion:(void(^)(EditCourtModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:OFFICE_DIARY_SAVE_URL];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:_url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

/*
 * Property
 */

- (void) getPropertyType: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_TYPE_GET_LIST_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [MatterCodeModel getMatterCodeArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getPropertyList: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_GET_LIST_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [FullPropertyModel getFullPropertyArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getMukimValue: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_MUKIM_GET_LIST_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [MukimModel getMukimArrayFromReponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getMasterTitle:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_MASTER_TITLE_GETLIST_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [MasterTitleModel getMasterTitleArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) savePropertyWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(AddPropertyModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:_url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion([AddPropertyModel getAddPropertyFromResponse:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) updatePropertyWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(AddPropertyModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self setAddContactLoginHTTPHeader];
    [self.manager PUT:_url parameters:data success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion([AddPropertyModel getAddPropertyFromResponse:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

/*
 * Matter
 */

- (void) getMatterLitigation:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, MATTER_LITIGATION_GET_LIST_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [MatterLitigationModel getMatterLitigationArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getMatterCode:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, MATTER_LIST_GET_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [MatterCodeModel getMatterCodeArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) saveMatterWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(RelatedMatterModel* result, NSError* error)) completion
{
//    NSString* _url = [@"http://43.252.215.163/" stringByAppendingString:url];
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:_url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion([RelatedMatterModel getRelatedMatterFromResponse:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) updateMatterWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(RelatedMatterModel* result, NSError* error)) completion
{
//    NSString* _url = [@"http://43.252.215.163/" stringByAppendingString:url];
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self setAddContactLoginHTTPHeader];
    [self.manager PUT:_url parameters:data success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion([RelatedMatterModel getRelatedMatterFromResponse:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

/*
 * Property
 */

- (void) getPropertyProjectHousingWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_PROJECT_HOUSING_GET_URL,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [ProjectHousingModel getProjectHousingArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getPropertyContactListWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, CONTACT_GETLIST_URL,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [StaffModel getStaffArrayFromRepsonse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

/*
 * Quotation
 */

- (void) getPresetBillCode:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PRESET_BILL_GET_URL,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [PresetBillModel getPresetBillArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) calculateTaxInvoiceWithParams: (NSDictionary*) data withCompletion: (void(^)(NSDictionary* result, NSError* error)) completion
{
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:TAXINVOICE_CALCULATION_URL];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) saveBillorQuotationWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(NSDictionary* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:_url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}



/*
 * Bill
 */

- (void) getQuotationListWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, QUOTATION_GET_LIST_URL,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [QuotationModel getQuotationArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

/*
 * Receipt
 */

- (void) getAccountTypeListWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, ACCOUNT_TYPE_GET_LIST_URL,[search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [AccountTypeModel getAccountTypeArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) saveReceiptWithParams: (NSDictionary*) data WithCompletion: (void(^)(NSDictionary* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:RECEIPT_SAVE_URL];
    [self setAddContactLoginHTTPHeader];
    [self.manager POST:_url parameters:data progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

/*
 * Dashbard
 */

- (void) getDashboardMainWithCompletion: (void(^)(DashboardMainModel* result, NSError* error)) completion
{
    [self setDashboardLoginHTTPHeader];
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:DASHBOARD_MAIN_GET_URL];
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            DashboardMainModel *result = [DashboardMainModel getDashboardMainFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];

}

- (void) getDashboardThreeItmesInURL:(NSString*)url withCompletion: (void(^)(ThreeItemModel* result, NSError* error)) completion
{
    [self setAddContactLoginHTTPHeader];
    NSString* _url = [NSString stringWithFormat:@"%@%@", [DataManager sharedManager].user.serverAPI, url];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            ThreeItemModel *result = [ThreeItemModel getThreeItemFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getDashboardCompletionHeaderInURL:(NSString*)url withCompletion: (void(^)(S3Model* result, NSError* error)) completion
{
    [self setAddContactLoginHTTPHeader];
    NSString* _url = [NSString stringWithFormat:@"%@%@", [DataManager sharedManager].user.serverAPI, url];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            S3Model *result = [S3Model getS3FromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getDashboardItemModelWithURL: (NSString*) url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    [self setAddContactLoginHTTPHeader];
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray* result = [ItemModel getItemArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getDashboardMyDueTaskWithURL: (NSString*) url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    [self setAddContactLoginHTTPHeader];
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@&search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray* result = [TaskCheckModel getTaskCheckArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getDashboardBankReconWithURL:(NSString*) url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    [self setAddContactLoginHTTPHeader];
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray* result = [BankReconModel getBankReconArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getDashboardTrialBalanceWithURL:(NSString*) url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    [self setAddContactLoginHTTPHeader];
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray* result = [TrialBalanceModel getTrialBalanceArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getNewMatterInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter  withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [SearchResultModel getSearchResultArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getDashboardContactInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].user.serverAPI, url];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [SearchResultModel getSearchResultArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getDashboardTaxInvoiceInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [TaxInvoceModel getTaxInvoiceArrayFromResonse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getDashboardFeeTransferInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [FeeTranserModel getFeeTranserArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getProfitLossDetailWithURL:(NSString*) url withCompletion:(void(^)(ProfitLossDetailModel* result, NSError* error)) completion {
    
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].user.serverAPI, url];
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            completion([ProfitLossDetailModel getProfitLossDetailFromResponse:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getStaffOnlineWithURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [StaffOnlineModel getStaffOnlineArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}

- (void) getAttendanceDetailWithURL:(NSString*)url withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    
}

- (void) getCompletionTrackingWithURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    
    [self setAddContactLoginHTTPHeader];
    [self.manager GET:_url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if  (completion != nil)
        {
            NSArray *result = [CompletionTrackingModel getCompletionTrackingArrayFromResponse:responseObject];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if  (completion != nil)
        {
            completion(nil, error);
        }
    }];
}
@end
