//
//  AdsModel.h
//  Denning
//
//  Created by Ho Thong Mee on 28/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdsModel : NSObject

@property (strong, nonatomic) NSString* URL;
@property (strong, nonatomic) NSString* adsCode;
@property (strong, nonatomic) NSString* imgData;

@property (strong, nonatomic) UIImage* image;

+ (AdsModel*) getAdsFromResponse:(NSDictionary*) response;

+ (NSArray*) getAdsArrayFromResponse:(NSArray*) response;

@end
