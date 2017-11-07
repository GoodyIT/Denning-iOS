    //
//  LocationManager.m
//  reach-ios
//
//  Created by DenningIT on 04/03/2017.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager
@synthesize stateName;
@synthesize lastLoggedDateTime;
@synthesize cityName;
@synthesize countryName;
@synthesize serverStatus;

+ (LocationManager *)sharedManager {
    static LocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LocationManager alloc] init];
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
    
//    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
////    self.manager.requestSerializer.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
//    [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    lastLoggedDateTime = [[NSDate alloc] init];
    cityName = @"";
    countryName = @"";
    serverStatus = @"";
}
@end
