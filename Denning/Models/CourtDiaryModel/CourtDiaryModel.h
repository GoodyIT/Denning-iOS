//
//  CourtDiaryModel.h
//  Denning
//
//  Created by Ho Thong Mee on 23/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourtDiaryModel : NSObject

@property (strong, nonatomic) NSString* courtDiaryCode;
@property (strong, nonatomic) NSString* place;
@property (strong, nonatomic) NSString* typeCase;

+ (CourtDiaryModel*) getCourtDiaryFromResponse: (NSDictionary*) response;

+ (NSArray*) getCourtDiaryArrayFromResponse: (NSDictionary*) response;

@end
