//
//  QMNetworkManager.h
//  reach-ios
//
//  Created by Admin on 2016-11-30.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CompletionHandler)(BOOL success, id response, NSError *error);

@class UserModel;
@class NewsModel;
@class EventModel;
@class PropertyModel;
@class ContactModel;
@class RelatedMatterModel;
@class BankModel;
@class LegalFirmModel;
@class GovOfficeModel;
@class LedgerModel;
@class NewLedgerModel;
@class LedgerDetailModel;
@class DocumentModel;
@class AddContactModel;
@class EditCourtModel;
@class ThreeItemModel;
@class NewMatterModel;
@class DashboardMainModel;
@class AddPropertyModel;

@interface QMNetworkManager : NSObject

@property(nonatomic, strong) AFHTTPSessionManager  *manager;


@property (strong, atomic) NSString       *installDate;
@property (strong, atomic) NSString       *installDateTemp;
@property (assign) CLLocationCoordinate2D     oldLocation;
@property(strong, atomic) NSString       *countryName;
@property(strong, nonatomic) NSString       *cityName;
@property(strong, atomic) NSString       *stateName;
@property (strong, atomic) NSNumber      *invalidTry;
@property (strong, atomic) NSDate       *startTrackTimeForLogin;

@property (strong, nonatomic) NSString* ipWAN;
@property (strong, nonatomic) NSString* ipLan;
@property (strong, nonatomic) NSString* os;
@property (strong, nonatomic) NSString* device;
@property (strong, nonatomic) NSString* deviceName;
@property (strong, nonatomic) NSString* MAC;

@property(nonatomic, strong) UserModel*     myProfile;

@property (nonatomic, strong) NSString* selectedBaseURLForGeneral;

+ (QMNetworkManager *)sharedManager;

- (AFHTTPSessionManager*) setLoginHTTPHeader;
- (AFHTTPSessionManager*) setOtherForLoginHTTPHeader;

/*
 ******** Auth *********
 */

/*
 *  Sign In
 *   
 *  @param: username
 *  @param: email
 */

-(void) userSignInWithEmail: (NSString*)email password:(NSString*) password withCompletion:(void(^)(BOOL success, NSString* error , NSInteger statusCode, NSDictionary* responseObject)) completion;

/*
 *  Request SMS for New Device
 *  @param: email
 *  @param: activation code
 */
//
//- (void) sendSMSNewDeviceWithEmail: (NSString*) email activationCode: (NSNumber*) activationCode withCompletion:(void(^)(BOOL success, NSString* error , NSInteger statusCode)) completion;

/*
 *  Forget Password
 *    1.  Request SMS
 *  @param: email
 *  @param: phone number
 *  @param: reason
 */

- (void) sendSMSForgetPasswordWithEmail: (NSString*) email phoneNumber: (NSString*) phoneNumber reason:(NSString*) reason withCompletion:(void(^)(BOOL success, NSInteger statusCode, NSString* error, NSDictionary* response)) completion;

- (void) sendSMSRequestWithEmail: (NSString*) email phoneNumber: (NSString*) phoneNumber reason:(NSString*) reason withCompletion:(void(^)(BOOL success, NSInteger statusCode, NSString* error, NSDictionary* response)) completion;

- (void) sendSMSForNewDeviceWithEmail: (NSString*) email activationCode: (NSString*) activationCode withCompletion: (void(^)(BOOL success, NSInteger statusCode, NSString* error, NSDictionary* response)) completion;

/*
 *  Forget Password
 *  @param: email
 *  @param: phone number
 *  @param: activationCode
 */

- (void) requestForgetPasswordWithEmail: (NSString*) email phoneNumber:(NSString*) phoneNumber activationCode: (NSString*) activationCode withCompletion:(void(^)(BOOL success, NSString* error)) completion;

/*
 *  Change Pasword
 *
 *  @param: email
 *  @param: password
 */

- (void) changePasswordAfterLoginWithEmail: (NSString*) email password: (NSString*) password withCompletion: (void(^)(BOOL success, NSString* error, NSDictionary* response)) completion;

/*
 *  Get Firm List
 */

- (void) getFirmListWithPage: (NSNumber*) page completion: (void(^)(NSArray* resultArray, NSError* error)) completion;

/*
 *  Secondary Log in
 */

// Denning Login

-(void) denningSignIn:(NSString*) password withCompletion:(void(^)(BOOL success, NSString* error, NSDictionary* responseObject)) completion;

// client login
- (void) clientSignIn: (NSString*) url password: (NSString*) password withCompletion: (void(^)(BOOL success, NSDictionary * responseObject, NSString* error,  DocumentModel* doumentModel)) completion;


/*
 *      Sign up
 *
 *  @param: username
 *  @param: phone
 *  @param: email
 *  @param: password
 *  @param: isLayer
 *  @param: firmCode
 *  @param: ipWan
 *  @param: ipLan
 *  @param: os
 *  @param: device
 *  @param: deviceName
 */

- (void) userSignupWithUsername:(NSString*) username phone:(NSString*) phone email:(NSString*) email isLayer:(NSNumber*) isLayer firmCode: (NSNumber*) firmCode withCompletion:(void(^)(BOOL success, NSString* error)) completion;

// Home Search

- (void) getGlobalSearchFromKeyword: (NSString*) keyword searchURL:(NSString*)searchURL forCategory:(NSInteger)category searchType:(NSString*)searchType withCompletion:(void(^)(NSArray* resultArray, NSError* error)) completion;

// Updates
- (void) getLatestUpdatesWithCompletion: (void(^)(NSArray* updatesArray, NSError* error)) completion;
// News

- (void) getLatestNewsWithCompletion: (void(^)(NSArray* newsArray, NSError* error)) completion;

// Event

- (void) getLatestEventWithStartDate: (NSString*) startDate endDate:(NSString*) endDate filter:(NSString*) filter search:(NSString*)search withCompletion: (void(^)(NSArray* eventsArray, NSError* error)) completion;

- (void) getCalenarMonthlySummaryWithYear:(NSString*) year month:(NSString*) month filter:(NSString*)filter withCompletion: (void(^)(NSArray* eventsArray, NSError* error)) completion;

// Ads

- (void) getAdsWithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

/*
 * Search
 */

// Property

- (void) loadPropertyfromSearchWithCode: (NSString*) code completion: (void(^)(AddPropertyModel* propertyModel, NSError* error)) completion;

// Contact
- (void) loadContactFromSearchWithCode: (NSString*) code completion: (void(^)(ContactModel* contactModel, NSError* error)) completion;

// Bank
- (void) loadBankFromSearchWithCode: (NSString*) code completion: (void(^)(BankModel* bankModel, NSError* error)) completion;

// Government Offices
- (void) loadGovOfficesFromSearchWithCode: (NSString*) code type:(NSString*) type completion: (void(^)(GovOfficeModel* govOfficeModel, NSError* error)) completion;

// Related Matter
- (void) loadRelatedMatterWithCode: (NSString*) code completion: (void(^)(RelatedMatterModel* contactModel, NSError* error)) completion;

// Legal firm (Solicitor)
- (void) loadLegalFirmWithCode: (NSString*) code completion: (void(^)(LegalFirmModel* legalFirmModel, NSError* error)) completion;

// Ledger
- (void) loadLedgerWithCode: (NSString*) code completion: (void(^)(NewLedgerModel* newLedgerModel, NSError* error)) completion;

// Ledger detail
- (void) loadLedgerDetailURL:(NSString*) url completion: (void(^)(NSArray* ledgerDetailModelArray, NSError* error)) completion;


// Document
- (void) loadDocumentWithCode: (NSString*) code completion: (void(^)(DocumentModel* doumentModel, NSError* error)) completion;


/*
 * Chat
 */

// Get the contacts
- (void) getChatContactsWithCompletion:(void(^)(void)) completion;

- (void) addFavoriteContact: (QBUUser*) user withCompletion:(void(^)(NSError* error)) completion;

- (void) removeFavoriteContact: (QBUUser*) user withCompletion:(void(^)(NSError* error)) completion;


/*
 *  Add Contact
 */

- (void) getCodeDescWithUrl:(NSString*) url withPage:(NSNumber*)page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getDescriptionWithUrl: (NSString*) url withPage: (NSNumber*) page withSearch:(NSString*)search withCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getPostCodeWithPage:(NSNumber*) page withSearch:(NSString*)search withCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getBankBranchWithPage:(NSNumber*) page withSearch:(NSString*)search withCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) saveContactWithData:(NSDictionary*) data withCompletion:(void(^)(ContactModel* addContact, NSError* error)) completion;

- (void) updateContactWithData:(NSDictionary*) data withCompletion:(void(^)(ContactModel* addContact, NSError* error)) completion;

- (void) getSolicitorList: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) checkIDorNameDuplication:(NSString*) string url:(NSString*)url WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;
/*
 * Court Diary
 */

- (void) getSimpleMatter:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getStaffArray:(NSNumber*) page withSearch:(NSString*)search WithURL:(NSString*) url WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getCourtWithCode:(NSString*) code WithCompletion:(void(^)(EditCourtModel* model, NSError* error)) completion;

- (void) getCourtDiaryArrayWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getCoramArrayWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) updateCourtDiaryWithData: (NSDictionary*) data WithCompletion:(void(^)(EditCourtModel* result, NSError* error)) completion;

- (void) saveCourtDiaryWithData: (NSDictionary*) data WithCompletion:(void(^)(EditCourtModel* result, NSError* error)) completion;

- (void) savePersonalDiaryWithData: (NSDictionary*) data WithCompletion:(void(^)(EditCourtModel* result, NSError* error)) completion;

- (void) saveOfficeDiaryWithData: (NSDictionary*) data WithCompletion:(void(^)(EditCourtModel* result, NSError* error)) completion;

/*
 * Property
 */

- (void) getPropertyProjectHousingWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getPropertyContactListWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getPropertyType: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getPropertyList: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getMukimValue: (NSNumber*) page withSearch:(NSString*) search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getMasterTitle:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) savePropertyWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(AddPropertyModel* result, NSError* error)) completion;

- (void) updatePropertyWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(AddPropertyModel* result, NSError* error)) completion;
/*
 * Matter
 */

- (void) getMatterLitigation:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getMatterCode:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) saveMatterWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(RelatedMatterModel* result, NSError* error)) completion;

- (void) updateMatterWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(RelatedMatterModel* result, NSError* error)) completion;

/*
 * Quotation
 */

- (void) getPresetBillCode:(NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) calculateTaxInvoiceWithParams: (NSDictionary*) data withCompletion: (void(^)(NSDictionary* result, NSError* error)) completion;

- (void) saveBillorQuotationWithParams: (NSDictionary*) data inURL:(NSString*) url WithCompletion: (void(^)(NSDictionary* result, NSError* error)) completion;

/*
 * Bill
 */

- (void) getQuotationListWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;


/*
 * Receipt
 */

- (void) getAccountTypeListWithPage: (NSNumber*) page withSearch:(NSString*)search WithCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) saveReceiptWithParams: (NSDictionary*) data WithCompletion: (void(^)(NSDictionary* result, NSError* error)) completion;


/*
 * Dashbard
 */

- (void) getDashboardMainWithCompletion: (void(^)(DashboardMainModel* result, NSError* error)) completion;

- (void) getDashboardThreeItmesInURL:(NSString*)url withCompletion: (void(^)(ThreeItemModel* result, NSError* error)) completion;

- (void) getDashboardItemModelWithURL: (NSString*) url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getDashboardMyDueTaskWithURL: (NSString*) url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion:(void(^)(NSArray* result, NSError* error)) completion;

- (void) getNewMatterInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion;

- (void) getDashboardContactInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion;

- (void) getDashboardTaxInvoiceInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion;

- (void) getDashboardAccountInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion;

- (void) getDashboardFeeTransferInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion;

-  (void) getDashboardTaskCheckListInURL:(NSString*)url withPage:(NSNumber*) page withFilter:(NSString*)filter withCompletion: (void(^)(NSArray* result, NSError* error)) completion;
@end

NS_ASSUME_NONNULL_END
