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
#import "AFHTTPSessionOperation.h"
#import "LocationManager.h"

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
    [self.manager.requestSerializer setValue:@"iPhone@denning.com.my" forHTTPHeaderField:@"webuser-id"];
    
    self.session = [NSURLSession sharedSession];
    
    // Get the default params
    self.ipWAN = [DIHelpers getWANIP] != nil ? [DIHelpers getWANIP] : @"";
    self.ipLan = [DIHelpers getLANIP] != nil ? [DIHelpers getLANIP] : @"";
    self.os = [DIHelpers getOSName];
    self.device = [DIHelpers getDevice];
    self.deviceName = [DIHelpers getDeviceName];
    self.MAC = [DIHelpers getMAC] != nil ? [DIHelpers getMAC] : @"";
}

- (AFHTTPSessionManager*) setPublicHTTPHeader {
    [self.manager.requestSerializer setValue:@"{334E910C-CC68-4784-9047-0F23D37C9CF9}"  forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:@"iPhone@denning.com.my" forHTTPHeaderField:@"webuser-id"];
    
    return _manager;
}

- (AFHTTPSessionManager*) setPrivateHTTPHeader {
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.email forHTTPHeaderField:@"webuser-id"];
    
    return _manager;
}

- (void) cancelAllOperations
{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
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

-(void) userSignInWithEmail: (NSString*)email password:(NSString*) password withCompletion:(void(^)(BOOL success, NSError* error, NSInteger statusCode, NSDictionary* responseObject)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{
                                                            @"email": email,
                                                            @"password": password}];
    
    [self setPublicHTTPHeader];
    
    [self sendPostWithURL:SIGNIN_URL params:params completion:^(NSDictionary * _Nonnull result, NSError * error,  NSURLSessionDataTask * _Nonnull task) {
            if (error == nil) {
                completion(YES, error, [[result objectForKey:@"statusCode"] integerValue], result);
            } else {
                NSHTTPURLResponse *test = (NSHTTPURLResponse *)task.response;
                completion(NO, error, test.statusCode, nil);
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

    [self setPublicHTTPHeader];
    
    [self sendPostWithURL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * error,  NSURLSessionDataTask * _Nonnull task) {
                if (error == nil) {
                        completion(YES, [[result valueForKeyNotNull:@"statusCode"] integerValue], error.localizedDescription, result);
                    } else {
                
                completion(NO, [[result valueForKeyNotNull:@"statusCode"] integerValue], error.localizedDescription, nil);
            }
    }];
}

- (void) requestForgetPasswordWithEmail: (NSString*) email phoneNumber:(NSString*) phoneNumber activationCode: (NSString*) activationCode withCompletion:(void(^)(BOOL success, NSString* error)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{@"email": email, @"hpNumber": phoneNumber, @"activationCode": activationCode}];
    
    [self setPublicHTTPHeader];
    
    [self sendPostWithURL:FORGOT_PASSWORD_REQUEST_URL params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        if (error == nil) {
            completion(YES, nil);
        } else {
            completion(NO, error.localizedDescription);
        }
    }];
}

- (void) changePasswordAfterLoginWithEmail: (NSString*) email password: (NSString*) password withCompletion: (void(^)(BOOL success, NSString* error, NSDictionary* response)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{@"email": email, @"password": password}];
    
    [self setPublicHTTPHeader];
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.email forHTTPHeaderField:@"webuser-id"];
    [self sendPostWithURL:CHANGE_PASSWORD_URL params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        if (error == nil) {
            completion(YES, nil, result);
        } else {
            completion(NO, error.localizedDescription, result);
        }
    }];
}

- (void) getFirmListWithPage: (NSNumber*) page completion: (void(^)(NSArray* resultArray, NSError* error)) completion
{
    [self setPublicHTTPHeader];
    
    NSString* url = [NSString stringWithFormat:@"%@?page=%@", SIGNUP_FIRM_LIST_URL, page];
    
    [self sendGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([FirmModel getFirmArrayFromResponse:result], error);
    }];
}

- (void) staffSignIn: (NSString*) url password:password withCompletion: (void(^)(NSDictionary * responseObject, NSError* error)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{@"email": [DataManager sharedManager].user.email, @"password": password, @"sessionID": [DataManager sharedManager].user.sessionID}];
    
    [self setPublicHTTPHeader];
    [self sendPostWithURL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error);
    }];
}

- (void) clientSignIn: (NSString*) url password:password withCompletion: (void(^)(BOOL success, NSDictionary * responseObject, NSError* error,  DocumentModel* doumentModel)) completion
{
    NSDictionary* params = [self buildRquestParamsFromDictionary:@{@"email": [DataManager sharedManager].user.email, @"password": password, @"sessionID": [DataManager sharedManager].user.sessionID}];

    [self setPublicHTTPHeader];
    [self sendPostWithURL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
         completion(YES, result, error, [DocumentModel getDocumentFromResponse:result]);
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
    
    [self setPublicHTTPHeader];
    [self sendPostWithURL:SIGNUP_URL params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        if (error == nil) {
            completion(YES, nil);
        } else {
            NSHTTPURLResponse *test = (NSHTTPURLResponse *)task.response;
            if (test.statusCode == 406) {
                completion(NO, @"Email or phone number is already registered.");
            } else {
                completion(NO, error.localizedDescription);
            }
        }
    }];
}

// Home Search

- (void) getGlobalSearchFromKeyword: (NSString*) keyword searchURL:(NSString*)searchURL forCategory:(NSInteger)category searchType:(NSString*)searchType withPage:(NSNumber*)page withProgress:(void (^)(CGFloat progress))progressBlock withCompletion:(void(^)(NSArray* resultArray, NSError* error)) completion
{
    NSString* urlString = [NSString stringWithFormat:@"%@%@&category=%ld&page=%@", searchURL, keyword, (long)category, page];
    if ([[DataManager sharedManager].searchType isEqualToString:@"Denning"]){
        [self setPrivateHTTPHeader];
        
    } else {
        [self setPublicHTTPHeader];
    }
    
    if ([searchType isEqualToString:@"Normal"]) { // Direct Tap on the search button
        urlString = [urlString stringByAppendingString:@"&isAutoComplete=1"];
    }
    
    [self sendProgressRequestWithType:@"Get" URL:urlString params:nil withProgress:progressBlock completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([SearchResultModel getSearchResultArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) attendanceClockIn:(void(^)(AttendanceModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString: ATTENDANCE_CLOCK_IN];
    
    NSString* _location = [NSString stringWithFormat:@"%lf,%f", [DataManager sharedManager].user.latitude, [DataManager sharedManager].user.latitude];
    NSDictionary* params = @{@"strLocationLong":_location, @"strLocationName":[DataManager sharedManager].user.streetName, @"strRemarks": @"start work"};
    [self sendPrivatePostWithURL:_url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([AttendanceModel getAttendanceModelFromResponse:result], error);
    }];
}

- (void) attendanceClockOut:(void(^)(AttendanceModel* result, NSError* error)) completion{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString: ATTENDANCE_CLOCK_IN];
    
    NSString* _location = [NSString stringWithFormat:@"%lf,%f", [LocationManager sharedManager].oldLocation.latitude, [LocationManager sharedManager].oldLocation.latitude];
    NSDictionary* params = @{@"strLocationLong":_location, @"strLocationName":[LocationManager sharedManager].streetName, @"strRemarks": @"start work"};
    [self sendPrivatePutWithURL:_url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([AttendanceModel getAttendanceModelFromResponse:result], error);
    }];
}

- (void) attendanceStartBreak:(void(^)(AttendanceModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString: ATTENDANCE_BREAK];
    
    NSString* _location = [NSString stringWithFormat:@"%lf,%f", [LocationManager sharedManager].oldLocation.latitude, [LocationManager sharedManager].oldLocation.latitude];
    NSDictionary* params = @{@"strLocationLong":_location, @"strLocationName":[LocationManager sharedManager].streetName, @"strRemarks": @"start work"};
    
    [self sendPrivatePostWithURL:_url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([AttendanceModel getAttendanceModelFromResponse:result], nil);
    }];
}

- (void) attendanceEndBreak:(void(^)(AttendanceModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString: ATTENDANCE_BREAK];
    NSString* _location = [NSString stringWithFormat:@"%lf,%f", [LocationManager sharedManager].oldLocation.latitude, [LocationManager sharedManager].oldLocation.latitude];
    NSDictionary* params = @{@"strLocationLong":_location, @"strLocationName":[LocationManager sharedManager].streetName, @"strRemarks": @"start work"};
    
    [self sendPrivatePutWithURL:_url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
         completion([AttendanceModel getAttendanceModelFromResponse:result], error);
    }];
}

// Updates
- (void) getLatestUpdatesWithCompletion: (void(^)(NSArray* updatesArray, NSError* error)) completion
{
    [self setPublicHTTPHeader];
    [self sendGetWithURL:UPDATES_LATEST_URL completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([NewsModel getNewsArrayFromResponse:result], error);
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

- (void) getLatestEventWithStartDate: (NSString*) startDate endDate:(NSString*) endDate filter:(NSString*) filter search:(NSString*)search page:(NSNumber*) page  withCompletion: (void(^)(NSArray* eventsArray, NSError* error)) completion
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@?dateStart=%@&dateEnd=%@&filterBy=%@&search=%@&page=%@", [DataManager sharedManager].user.serverAPI, EVENT_LATEST_URL, startDate, endDate, filter, search, page];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
         completion([EventModel getEventsArrayFromResponse:result], error);
    }];
}

- (void) getCalenarMonthlySummaryWithYear:(NSString*) year month:(NSString*) month filter:(NSString*)filter withCompletion: (void(^)(NSArray* eventsArray, NSError* error)) completion
{
    NSString *url = [NSString stringWithFormat:@"%@%@?year=%@&month=%@&filterBy=%@", [DataManager sharedManager].user.serverAPI, CALENDAR_MONTHLY_SUMMARY_URL, year, month, filter];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion((NSArray*)result, error);
    }];
}

// Ads
- (void) getAdsWithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    [self.manager.requestSerializer setValue:@"{334E910C-CC68-4784-9047-0F23D37C9CF9}"  forHTTPHeaderField:@"webuser-sessionid"];
    [self.manager.requestSerializer setValue:[DataManager sharedManager].user.email forHTTPHeaderField:@"webuser-id"];
    
    [self sendGetWithURL:HOME_ADS_GET_URL completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([AdsModel getAdsArrayFromResponse:(NSArray*)result], error);
    }];
}

// Attendnace
- (void) getAttendanceListWithCompletion:(void(^)(AttendanceModel* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@", [DataManager sharedManager].user.serverAPI, ATTENDANCE_GET_URL];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([AttendanceModel getAttendanceModelFromResponse:result], error);
    }];
}

/*
 *  Search
 */

// property

- (void) loadPropertyfromSearchWithCode: (NSString*) code completion: (void(^)(AddPropertyModel* propertyModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/Property/%@", [DataManager sharedManager].user.serverAPI, code];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([AddPropertyModel getAddPropertyFromResponse:result], error);
    }];
}

// Contact
- (void) loadContactFromSearchWithCode: (NSString*) code completion: (void(^)(ContactModel* contactModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/Contact/%@", [DataManager sharedManager].user.serverAPI, code];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([ContactModel getContactFromResponse:result], error);
    }];
}

// Related Matter
- (void) loadRelatedMatterWithCode: (NSString*) code completion: (void(^)(RelatedMatterModel* contactModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/matter/%@", [DataManager sharedManager].user.serverAPI, code];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([RelatedMatterModel getRelatedMatterFromResponse:result], error);
    }];
}

- (void) loadFileNoteListWithCode:(NSString*) code withPage:page
completion: (void(^)(NSArray *result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/table/Note?fileNo=%@&page=%@", [DataManager sharedManager].user.serverAPI, code, page];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([FileNoteModel getFileNoteArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) saveFileNoteWithParams: (NSDictionary*) params completion: (void(^)(FileNoteModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString: @"denningwcf/v1/table/Note"];
    [self sendPrivatePostWithURL:_url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([FileNoteModel getFileNoteFromResonse:result], error);
    }];
}

- (void) updateFileNoteWithParams: (NSDictionary*) params completion: (void(^)(FileNoteModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString: @"denningwcf/v1/table/Note"];
    [self sendPrivatePutWithURL:_url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([FileNoteModel getFileNoteFromResonse:result],error);
    }];
}

// File Upload
- (void) getSuggestedNameWithUrl:(NSString*) url withPage:(NSNumber*)page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, url, search, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion((NSArray*)result, error);
    }];
}

- (void) uploadFileWithUrl:(NSString*) url params:(NSDictionary*) params WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    [self sendPrivatePostWithURL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion((NSArray*)result, error);
    }];
}

// Payment Record
- (void) getPaymentRecordWithFileNo:(NSString*) fileNo completion:(void(^)(NSDictionary* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/PaymentRecord/%@", [DataManager sharedManager].user.serverAPI, fileNo];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error);
    }];
}

// Template
- (void) getTemplateWithFileno:(NSString*) fileNo online:(NSString*) online category:(NSString*) category type:(NSString*) type page:(NSNumber*) page search:(NSString*) search withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/Table/cboTemplate?fileno=%@&Online=%@&category=%@&Type=%@&page=%@&search=%@", [DataManager sharedManager].user.serverAPI, fileNo, online, category, type, page, search];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([TemplateModel getTemplateArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) getTemplateCategoryWithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [DataManager sharedManager].user.serverAPI, SEARCH_TEMPLATE_CATEGORY_GET];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion((NSArray*)result, error);
    }];
}

- (void) getTemplateTypeWithFilter:(NSString*) filter inCategory:(NSString*) category page:page withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@%@%@&search=%@&page=%@", [DataManager sharedManager].user.serverAPI, SEARCH_TYPE_CATEGORY_GET, category, filter, page];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion((NSArray*)result, error);
    }];
}

// Bank
- (void) loadBankFromSearchWithCode: (NSString*) code completion: (void(^)(BankModel* bankModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/bank/branch/%@", [DataManager sharedManager].user.serverAPI, code];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([BankModel getBankFromResponse:result], error);
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
    
    if ([[DataManager sharedManager].searchType isEqualToString:@"Denning"]){
        NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/GovOffice/%@/%@", [DataManager sharedManager].user.serverAPI, point, code];
        [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
            completion([GovOfficeModel getGovOfficeFromResponse:result], error);
        }];
    } else {
        NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/GovOffice/%@/%@", PUBLIC_BASE_URL, point, code];
        [self setPublicHTTPHeader];
        [self sendGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
            completion([GovOfficeModel getGovOfficeFromResponse:result], error);
        }];
    }
}

// Legal firm (Solicitor)
- (void) loadLegalFirmWithCode: (NSString*) code completion: (void(^)(LegalFirmModel* legalFirmModel, NSError* error)) completion
{
    if ([[DataManager sharedManager].searchType isEqualToString:@"Denning"]){
        NSString* url = [NSString stringWithFormat:@"%@%@%@", [DataManager sharedManager].user.serverAPI, PRIVATE_LEGAL_FIRM_URL, code];
        
        [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
            completion([LegalFirmModel getLegalFirmFromResponse:result], error);
        }];
    } else {
        NSString* url = [NSString stringWithFormat:@"%@%@", PUBLIC_LEGAL_FIRM_URL, code];
        
        [self setPublicHTTPHeader];
        [self sendGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
            completion([LegalFirmModel getLegalFirmFromResponse:result], error);
        }];
    }
}

// Ledger
- (void) loadLedgerWithCode: (NSString*) code completion: (void(^)(NewLedgerModel* newLedgerModel, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/%@/fileLedger", [DataManager sharedManager].user.serverAPI, code];

    [self loadLedgerWithUrl:url completion:completion];
}

- (void) loadLedgerWithUrl: (NSString*) url completion: (void(^)(NewLedgerModel* newLedgerModel, NSError* error)) completion
{
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([NewLedgerModel getNewLedgerModelFromResponse:result], error);
    }];
}

// Ledger detail
- (void) loadLedgerDetailURL:(NSString*) url completion: (void(^)(NSArray* ledgerModelDetailArray, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].user.serverAPI, url];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([LedgerDetailModel getLedgerDetailArrayFromResponse:result], error);
    }];
}

// Documents
- (void) loadDocumentWithCode: (NSString*) code completion: (void(^)(DocumentModel* doumentModel, NSError* error)) completion
{
    if ([[DataManager sharedManager].searchType isEqualToString:@"Denning"]){
        NSString* url = [NSString stringWithFormat:@"%@denningwcf/v1/app/matter/%@/fileFolder", [DataManager sharedManager].user.serverAPI, code];
        
        [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
            completion([DocumentModel getDocumentFromResponse:result], error);
        }];
    } else {
        NSString* url = [NSString stringWithFormat:@"%@/v1/matter/%@/fileFolder", PUBLIC_BASE_URL, code];
        
        [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
            completion([DocumentModel getDocumentFromResponse:result], error);
        }];
    }
}

- (NSMutableArray*) buildContactsFrom:(NSArray*) contacts{
    NSMutableArray* dest = [NSMutableArray new];
    for (ChatFirmModel *chatFirmModel in contacts) {
        ChatFirmModel* newModel = [ChatFirmModel new];
        newModel.firmName = chatFirmModel.firmName;
        newModel.firmCode = chatFirmModel.firmCode;
        NSMutableArray* userArray = [NSMutableArray new];
        for (ChatUserModel* chatUserModel in chatFirmModel.users) {
            QBUUser* user = [[QMCore instance].usersService.usersMemoryStorage usersWithEmails:@[chatUserModel.email]].firstObject;
            if (user != nil) {
                QBUUser *newUser = [user copy];
                newUser.twitterDigitsID = chatUserModel.position;
                newUser.twitterID = chatUserModel.tag;
                [userArray addObject:newUser];
            }
        }
        
        newModel.users = [userArray copy];
        [dest addObject:newModel];
    }
    
    return dest;
}

- (BFTask *) getChatContacts
{
    NSString* url = GET_CHAT_CONTACT_URL;

    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        NSString* _url = [url stringByAppendingString:[DataManager sharedManager].user.email];
        [self setPublicHTTPHeader];
        __block ChatContactModel* chatContacts;
        [self sendGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
            if (error == nil) {
                chatContacts = [ChatContactModel getChatContactFromResponse:result];
                
                // Denning Contact
                [DataManager sharedManager].denningContactArray = [self buildContactsFrom:chatContacts.denningContacts];
                
                // Staff Contact
                [DataManager sharedManager].staffContactsArray = [self buildContactsFrom:chatContacts.staffContacts];
                
                // Client Contact
                [DataManager sharedManager].clientContactsArray = [self buildContactsFrom:chatContacts.clientContacts];
                
                // favorite Staff Contact
                [DataManager sharedManager].favStaffContactsArray = [self buildContactsFrom:chatContacts.favStaffContacts];
                
                // favorite client
                [DataManager sharedManager].favClientContactsArray = [self buildContactsFrom:chatContacts.favClientContacts];
                
                // Set Expire values
                [[DataManager sharedManager] setIsExpire:[chatContacts.isExpire boolValue]];
                [DataManager sharedManager].dtExpire = chatContacts.dtExpire;
                
                [source setResult:chatContacts.favStaffContacts];
            } else {
                [source setError:error];
            }
            
        }];
    });
}

- (void) addFavoriteContact: (QBUUser*) user withCompletion:(void(^)(NSError* error)) completion
{
    [self setPublicHTTPHeader];
    NSDictionary* params = @{@"email": [QBSession currentSession].currentUser.email, @"favourite": user.email};
    NSString* url = PUBLIC_ADD_FAVORITE_CONTACT_URL;
    
    [self sendPostWithURL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(error);
    }];
}

- (void) removeFavoriteContact: (QBUUser*) user withCompletion:(void(^)(NSError* error)) completion
{
    [self setPublicHTTPHeader];
    NSDictionary* params = @{@"email": [QBSession currentSession].currentUser.email, @"favourite": user.email};
    
    [self sendPostWithURL:REMOVE_FAVORITE_CONTACT_URL params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(error);
    }];
}

/*
 *  Add Contact
 */

- (void) getCodeDescWithUrl:(NSString*) url withPage:(NSNumber*)page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, url,search, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([CodeDescription getCodeDescriptionArrayFromResponse:result], error);
    }];
}

- (void) getDescriptionWithUrl: (NSString*) url withPage: (NSNumber*) page withSearch:(NSString*)search withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, url, search, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion((NSArray*)result, error);
    }];
}

- (void) getPostCodeWithPage:(NSNumber*) page withSearch:(NSString*)search withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, CONTACT_POSTCODE_URL, search, page];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([CityModel getCityModelArrayFromResponse:result], error);
    }];
}

- (void) getBankBranchWithPage:(NSNumber*) page withSearch:(NSString*)search withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, BANK_BRANCH_GET_LIST_URL, search, page];

    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([BankBranchModel getBankBranchArrayFromResponse:result], error);
    }];
}

- (void) getSolicitorList: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI,CONTACT_SOLICITOR_GET_LIST_URL,search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([SoliciorModel getSolicitorArrayFromRespsonse:result], error);
    }];
}

- (void) checkIDorNameDuplication:(NSString*) string url:(NSString*)url WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@", [DataManager sharedManager].user.serverAPI,url, string];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion((NSArray*)result, error);
    }];
}

- (void) saveContactWithData:(NSDictionary*) data withCompletion:(void(^)(ContactModel* addContact, NSError* error)) completion
{
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:CONTACT_SAVE_URL];
    [self setPrivateHTTPHeader];
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
    [self setPrivateHTTPHeader];
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
    NSString* url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, MATTERSIMPLE_GET_URL, search, page];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([MatterSimple getMatterSimpleArrayFromResponse:result], error);
    }];
}

- (void) getStaffArray:(NSNumber*) page withSearch:(NSString*)search WithURL:(NSString*) url WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI,url,  search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([StaffModel getStaffArrayFromRepsonse:result], error);
    }];
}

- (void) getCourtWithCode:(NSString*) code WithCompletion:(void(^)(EditCourtModel* model, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/v1/courtDiary/%@", [DataManager sharedManager].user.serverAPI,code];
    
    [self setPrivateHTTPHeader];
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
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, COURTDIARY_COURT_GET_LIST_URL,search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([CourtDiaryModel getCourtDiaryArrayFromResponse:result], error);
    }];
}

- (void) getCoramArrayWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, COURT_CORAM_GET_LIST_URL,search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([CoramModel getCoramArrayFromResponse:result], error);
    }];
}

- (void) updateCourtDiaryWithData: (NSDictionary*) data WithCompletion:(void(^)(EditCourtModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:COURT_SAVE_UPATE_URL];
    [self setPrivateHTTPHeader];
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
    [self setPrivateHTTPHeader];
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
    [self setPrivateHTTPHeader];
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
    [self sendPrivatePostWithURL:_url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([EditCourtModel getEditCourtFromResponse:result], error);
    }];
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
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_TYPE_GET_LIST_URL, search, page];
    
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([MatterCodeModel getMatterCodeArrayFromResponse:result], error);
    }];
}

- (void) getPropertyList: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_GET_LIST_URL, search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([FullPropertyModel getFullPropertyArrayFromResponse:result], error);
    }];
}

- (void) getMukimValue: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_MUKIM_GET_LIST_URL, [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]], page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([MukimModel getMukimArrayFromReponse:result], error);
    }];
}

- (void) getMasterTitle:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_MASTER_TITLE_GETLIST_URL, search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([MasterTitleModel getMasterTitleArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) savePropertyWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(AddPropertyModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self setPrivateHTTPHeader];
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
    [self sendPrivatePutWithURL:_url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([AddPropertyModel getAddPropertyFromResponse:result], error);
    }];
}

/*
 * Matter
 */

- (void) getMatterLitigation:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, MATTER_LITIGATION_GET_LIST_URL, search,  page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([MatterLitigationModel getMatterLitigationArrayFromResponse:result], error);
    }];
}

- (void) getMatterCode:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, MATTER_LIST_GET_URL, search, page];
    
    
    [self setPrivateHTTPHeader];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        NSArray *array = [MatterCodeModel getMatterCodeArrayFromResponse:result];
        completion(array, error);
    }];
}

- (void) saveMatterWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(RelatedMatterModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self sendPrivatePostWithURL:_url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([RelatedMatterModel getRelatedMatterFromResponse:result], error);
    }];
}

- (void) updateMatterWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(RelatedMatterModel* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self sendPrivatePutWithURL:_url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([RelatedMatterModel getRelatedMatterFromResponse:result], error);
    }];
}

/*
 * Property
 */

- (void) getPropertyProjectHousingWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PROPERTY_PROJECT_HOUSING_GET_URL, search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([ProjectHousingModel getProjectHousingArrayFromResponse:result], error);
    }];
}

- (void) getPropertyContactListWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, CONTACT_GETLIST_URL,search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([StaffModel getStaffArrayFromRepsonse:result], error);
    }];
}

/*
 * Quotation
 */

- (void) getPresetBillCode:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, PRESET_BILL_GET_URL,search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([PresetBillModel getPresetBillArrayFromResponse:result], error);
    }];
}

- (void) calculateTaxInvoiceWithParams: (NSDictionary*) data withCompletion: (void(^)(NSDictionary* result, NSError* error)) completion
{
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:TAXINVOICE_CALCULATION_URL];
    [self sendPrivatePostWithURL:url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error);
    }];
}

- (void) saveBillorQuotationWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(NSDictionary* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:url];
    [self sendPrivatePostWithURL:_url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error);
    }];
}

/*
 * Bill
 */

- (void) getQuotationListWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, QUOTATION_GET_LIST_URL, search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([QuotationModel getQuotationArrayFromResponse:result], nil);
    }];
}

/*
 * Receipt
 */

- (void) getAccountTypeListWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    NSString* _url = [NSString stringWithFormat:@"%@%@%@&page=%@", [DataManager sharedManager].user.serverAPI, ACCOUNT_TYPE_GET_LIST_URL, search, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([AccountTypeModel getAccountTypeArrayFromResponse:result], error);
    }];
}

- (void) saveReceiptWithParams: (NSDictionary*) data WithCompletion: (void(^)(NSDictionary* result, NSError* error)) completion
{
    NSString* _url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:RECEIPT_SAVE_URL];
    [self sendPrivatePostWithURL:_url params:data completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error);
    }];
}

- (void) displaySessionExpireMessage {
    [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_SESSION_EXPIRED", nil) actionSuccess:NO inViewController:[DIHelpers topMostController]];
}

/*
 Leave Application
 */
- (void) sendProgressRequestWithType:(NSString*) requestType URL:(NSString*) url params:(nullable NSDictionary*) params withProgress:(void (^)(CGFloat progress))progressBlock  completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion {
    
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

    NSOperation *operation = [AFHTTPSessionOperation operationWithManager:self.manager
                                                               HTTPMethod:requestType
                                                                URLString:url
                                                               parameters:params
                                                           uploadProgress:nil
                                                         downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                                                             progressBlock(downloadProgress.fractionCompleted);
                                                         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                                      if (completion != nil) {                                 completion(responseObject, nil, task);                         }                } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                                                                          if (((NSHTTPURLResponse *)task.response).statusCode == 410) { // Session expired.
                                                                              [self displaySessionExpireMessage];
                                                                              
                                                                          }
                                                                          if  (completion != nil)
                                                                          {
                                                                              completion(nil, error, task);
                                                                          }
                                                                      }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void) sendRequestWithType:(NSString*) requestType URL:(NSString*) url params:(nullable NSDictionary*) params completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion
{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSOperation *operation = [AFHTTPSessionOperation operationWithManager:self.manager
                                                               HTTPMethod:requestType
                                                                URLString:url
                                                               parameters:params
                                                           uploadProgress:nil
                                                         downloadProgress:nil
                                                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                                      if (completion != nil) {                                 completion(responseObject, nil, task);                         }                } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                                                                          if (((NSHTTPURLResponse *)task.response).statusCode == 410) { // Session expired.
                                                                              [self displaySessionExpireMessage];
                                                                              
                                                                          }
                                                                          if  (completion != nil)
                                                                          {
                                                                              completion(nil, error, task);
                                                                          }
                                                                      }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void) sendGetWithURL:(NSString*) url completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion
{
    [self sendRequestWithType:@"Get" URL:url params:nil completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error, task);
    }];
}

- (void) sendPostWithURL:(NSString*) url params:(NSDictionary*) params completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion
{
    [self sendRequestWithType:@"POST" URL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error, task);
    }];
}

- (void) sendPutWithURL:(NSString*) url params:(NSDictionary*) params completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion
{
    [self sendRequestWithType:@"PUT" URL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error,  NSURLSessionDataTask * _Nonnull task) {
        completion(result, error, task);
    }];
}

- (void) sendPrivateGetWithURL:(NSString*) url completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion
{
    [self setPrivateHTTPHeader];
    [self sendGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error, task);
    }];
}

- (void) sendDeleteWithURL:(NSString*) url params:(NSDictionary* ) params completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion
{
    [self sendRequestWithType:@"DELETE" URL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error, task);
    }];
}

- (void) sendPrivatePostWithURL:(NSString*) url params:(NSDictionary*) params completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion
{
    [self setPrivateHTTPHeader];
    [self sendPostWithURL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error, task);
    }];
}

- (void) sendPrivatePutWithURL:(NSString*) url params:(NSDictionary*) params completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion
{
    [self setPrivateHTTPHeader];
    [self sendPutWithURL:url params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error, task);
    }];
}

- (void) getLeaveRecordsWithPage:(NSNumber*) page completion:(void(^)(NSDictionary* result, NSError* error, NSURLSessionDataTask * _Nonnull task)) completion
{
    NSString *url = [NSString stringWithFormat:@"%@%@?page=%@", [DataManager sharedManager].user.serverAPI, LEAVE_RECORD_GET_URL, page];
    [self setPrivateHTTPHeader];
    [self sendGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error, task);
    }];
}

/*
 * Dashbard
 */

- (void) getDashboardMainWithCompletion: (void(^)(DashboardMainModel* result, NSError* error)) completion
{
    
    NSString* url = [[DataManager sharedManager].user.serverAPI stringByAppendingString:DASHBOARD_MAIN_GET_URL];
    [self sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([DashboardMainModel getDashboardMainFromResponse:result], error);
    }];
}

- (void) getDashboardThreeItmesInURL:(NSString*)url withCompletion: (void(^)(ThreeItemModel* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@%@", [DataManager sharedManager].user.serverAPI, url];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([ThreeItemModel getThreeItemFromResponse:result], error);
    }];
}

- (void) getDashboardCompletionHeaderInURL:(NSString*)url withCompletion: (void(^)(S3Model* result, NSError* error)) completion
{
    [self setPrivateHTTPHeader];
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
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([ItemModel getItemArrayFromResponse:result], error);
    }];
}

- (void) getDashboardMyDueTaskWithURL: (NSString*) url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@&search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([TaskCheckModel getTaskCheckArrayFromResponse:result], error);
    }];
}

- (void) getDashboardBankReconWithURL:(NSString*) url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([BankReconModel getBankReconArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) getDashboardTrialBalanceWithURL:(NSString*) url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([TrialBalanceModel getTrialBalanceArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) getNewMatterInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter  withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([SearchResultModel getSearchResultArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) getDashboardContactInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([SearchResultModel getSearchResultArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) getDashboardFeeTransferInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{

    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion((NSArray*)result, nil);
    }];
}

- (void) getProfitLossDetailWithURL:(NSString*) url withCompletion:(void(^)(ProfitLossDetailModel* result, NSError* error)) completion {
    
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].user.serverAPI, url];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([ProfitLossDetailModel getProfitLossDetailFromResponse:result], error);
    }];
}

- (void) getStaffOnlineWithURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@&search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([StaffOnlineModel getStaffOnlineArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) getCompletionTrackingWithURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@?search=%@&page=%@", [DataManager sharedManager].user.serverAPI, url, filter, page];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion([CompletionTrackingModel getCompletionTrackingArrayFromResponse:(NSArray*)result], error);
    }];
}

- (void) getResponseWithUrl:(NSString*) url withCompletion:(void(^)(id result, NSError* error)) completion
{
    NSString* _url = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].user.serverAPI, url];
    [self sendPrivateGetWithURL:_url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        completion(result, error);
    }];
}
@end
