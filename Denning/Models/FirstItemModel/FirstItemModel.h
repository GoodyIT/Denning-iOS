//
//  FirstItemModel.h
//  Denning
//
//  Created by Ho Thong Mee on 22/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FirstItemModel : NSObject
@property(strong, nonatomic) NSString* background;
@property(strong, nonatomic) NSString* footerAPI;
@property(strong, nonatomic) NSString*  footerDescription;
@property(strong, nonatomic) NSString* footerDescriptionColor;
@property(strong, nonatomic) NSString* icon;
@property(strong, nonatomic) NSString* formName;
@property(strong, nonatomic) NSString* itemId;
@property(strong, nonatomic) NSString* mainAPI;
@property(strong, nonatomic) NSString* mainValue;
@property(strong, nonatomic) NSString* mainValueColor;
@property(strong, nonatomic) NSString* title;
@property(strong, nonatomic) NSString* titleColor;
@property(strong, nonatomic) NSString* footerValue;
@property(strong, nonatomic) NSString* footerValueColor;

+(FirstItemModel*) getFirstItemFromResponse:(NSDictionary*)response;

+ (NSArray*) getFirstItemArrayFromResponse:(NSArray*) response;
@end
