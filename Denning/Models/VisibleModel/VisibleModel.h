//
//  VisibleModel.h
//  Denning
//
//  Created by Ho Thong Mee on 26/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VisibleModel : NSObject

@property (strong, nonatomic) NSString* iStyle;
@property (strong, nonatomic) NSString* isVisible;
@property (strong, nonatomic) NSString* sessionAPI;
@property (strong, nonatomic) NSString* sessionID;
@property (strong, nonatomic) NSString* sessionName;

+ (VisibleModel*) getVisibleFromReponse:(NSDictionary*) response;

+ (NSArray*) getVisibleArrayFromResponse: (NSDictionary*) response;
@end
