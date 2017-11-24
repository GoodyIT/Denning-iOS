//
//  AppDelegate.h
//  Denning
//
//  Created by DenningIT on 19/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemoDownloadStore;
@class HWIFileDownloader;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * _Nullable window;


@property (nonnull, nonatomic, strong, readonly) DemoDownloadStore *demoDownloadStore;

@property (nonnull, nonatomic, strong, readonly) HWIFileDownloader *fileDownloader;

- (void)showDeniedLocation;

@end

