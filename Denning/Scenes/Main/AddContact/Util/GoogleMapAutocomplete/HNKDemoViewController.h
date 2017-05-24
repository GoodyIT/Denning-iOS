//
//  HNKDemoViewController.h
//  HNKGooglePlacesAutocomplete-Example
//
//  Created by Tom OMalley on 8/11/15.
//  Copyright (c) 2015 Harlan Kellaway. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UpdateGoogleMapHandler)(NSString* address);

@interface HNKDemoViewController : UIViewController

@property (strong, nonatomic) UpdateGoogleMapHandler updateHandler;

@end
