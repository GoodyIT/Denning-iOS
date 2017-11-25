//
//  UserModel.h
//  Denning
//
//  Created by DenningIT on 19/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirmURLModel.h"

//@class FirmURLModel;
//
//@interface FirmURLModel : RLMObject
//
//@end


//RLM_ARRAY_TYPE(FirmURLModel)

@interface UserModel : RLMObject

@property   NSString    *sessionID;
@property   NSString    *email;
@property   NSString    *phoneNumber;
@property   NSString    *username;
@property   NSString    *password;
@property   NSString    *status;
@property   NSString    *serverAPI;
@property   NSString    *firmCity;
@property   NSString    *userType;
@property   NSString    *serverURL;
@property   NSInteger    activationCode;
@property   NSString    *firmName;

@end

//@interface FirmURLModel()
//
//@property NSString      *firmServerURL;
//@property NSString      *name;
////@property NSString      *category;
////@property BOOL          isActive;
//@end
