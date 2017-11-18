//
//  GeneralGroup.h
//  Denning
//
//  Created by DenningIT on 27/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

// RM group, Date group, other information
@interface GeneralGroup : NSObject
@property (strong, nonatomic) NSString* fieldName;
@property (strong, nonatomic) NSString* formula;
@property (strong, nonatomic) NSString* label;
@property (strong, nonatomic) NSString* value;
@end
