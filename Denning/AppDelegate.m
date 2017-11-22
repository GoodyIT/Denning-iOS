//
//  AppDelegate.m
//  Denning
//
//  Created by DenningIT on 19/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "QMCore.h"
#import "QMImages.h"
#import "QMHelpers.h"
#import "QMNetworkManager.h"
#import "DataManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "LocationManager.h"

//#import <Flurry.h>

static NSString * const kQMNotificationActionTextAction = @"TEXT_ACTION";
static NSString * const kQMNotificationCategoryReply = @"TEXT_REPLY";
static NSString * const kQMAppGroupIdentifier = @"group.com.quickblox.qmunicate";

#define DEVELOPMENT 0

#if DEVELOPMENT == 1

// Production
static const NSUInteger kQMApplicationID = 55869;
static NSString * const kQMAuthorizationKey = @"tpH4TbFKOcmrYet";
static NSString * const kQMAuthorizationSecret = @"Tctz5xEDNWuJQq4";
static NSString * const kQMAccountKey = @"NuMeyx3adrFZURAvoA5j";

#else

// Development
static const NSUInteger kQMApplicationID = 55869;
static NSString * const kQMAuthorizationKey = @"tpH4TbFKOcmrYet";
static NSString * const kQMAuthorizationSecret = @"Tctz5xEDNWuJQq4";
static NSString * const kQMAccountKey = @"NuMeyx3adrFZURAvoA5j";

#endif

@interface AppDelegate ()<QMPushNotificationManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonnull, nonatomic, strong, readwrite) DemoDownloadStore *demoDownloadStore;
@property (nonnull, nonatomic, strong, readwrite) HWIFileDownloader *fileDownloader;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self startUpdatingCurrentLocation];
    
    // Quickblox settings
    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthKey:kQMAuthorizationKey];
    [QBSettings setAuthSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAccountKey];
//    [QBSettings setApplicationGroupIdentifier:kQMAppGroupIdentifier];
    
    [QBSettings setAutoReconnectEnabled:YES];
    [QBSettings setCarbonsEnabled:YES];
    
#if DEVELOPMENT == 0
    [QBSettings setLogLevel:QBLogLevelNothing];
    [QBSettings disableXMPPLogging];
    [QMServicesManager enableLogging:NO];
#else
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    [QMServicesManager enableLogging:YES];
#endif
    
    // QuickbloxWebRTC settings
    [QBRTCClient initializeRTC];
    [QBRTCConfig setICEServers:[[QMCore instance].callManager quickbloxICE]];
    [QBRTCConfig mediaStreamConfiguration].audioCodec = QBRTCAudioCodecISAC;
    [QBRTCConfig setStatsReportTimeInterval:0.0f]; // set to 1.0f to enable stats report
    
    // Registering for remote notifications
    [self registerForNotification];
    // Handling push notifications if needed
    if (launchOptions != nil) {
        NSDictionary *pushNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [QMCore instance].pushNotificationManager.pushNotification = pushNotification;
    }
    
    // Configuring external frameworks
    [Fabric with:@[CrashlyticsKit,  [Answers class]]];
    
    // setup app download store
//    self.demoDownloadStore = [[DemoDownloadStore alloc] init];
//
//    // setup downloader
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
//        self.fileDownloader = [[HWIFileDownloader alloc] initWithDelegate:self.demoDownloadStore];
//    [self.fileDownloader setupWithCompletion:nil];

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}


#pragma mark - Push notification registration

- (void)registerForNotification {
    
    NSSet *categories = nil;
    if (iosMajorVersion() > 8) {
        // text input reply is ios 9 +
        UIMutableUserNotificationAction *textAction = [[UIMutableUserNotificationAction alloc] init];
        textAction.identifier = kQMNotificationActionTextAction;
        textAction.title = NSLocalizedString(@"QM_STR_REPLY", nil);
        textAction.activationMode = UIUserNotificationActivationModeBackground;
        textAction.authenticationRequired = NO;
        textAction.destructive = NO;
        textAction.behavior = UIUserNotificationActionBehaviorTextInput;
        
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = kQMNotificationCategoryReply;
        [category setActions:@[textAction] forContext:UIUserNotificationActionContextDefault];
        [category setActions:@[textAction] forContext:UIUserNotificationActionContextMinimal];
        
        categories = [NSSet setWithObject:category];
    }
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings
                                                        settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                        categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)__unused application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [QMCore instance].pushNotificationManager.deviceToken = deviceToken;
}

- (void)startUpdatingCurrentLocation
{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        [self showDeniedLocation];
        return;
    }
    
    // if location services are restricted do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        return;
    }
    
    // if locationManager does not currently exist, create it
    if (self.locationManager == nil)
    {
        _locationManager = [[CLLocationManager alloc] init];
        (self.locationManager).delegate = self;
        self.locationManager.distanceFilter = 10.0f; // we don't need to be any more accurate than 10m
    }
    
    // for iOS 8 and later, specific user level permission is required,
    // "when-in-use" authorization grants access to the user's location
    //
    // important: be sure to include NSLocationWhenInUseUsageDescription along with its
    // explanation string in your Info.plist or startUpdatingLocation will not work.
    //
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
}

- (void) showDeniedLocation {
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    NSString *title;
    title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Location is not enabled";
    NSString *message = @"To use location you must turn on 'While Using the App' in the Location Services Settings";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* Ok = [UIAlertAction
                         actionWithTitle:@"Continue"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * __unused action)
                         {
                             if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]  options:@{}
                                                          completionHandler:nil];
                             } else {
                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                             }
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * __unused action)
                             {
                                 
                             }];
    
    [alert addAction:Ok];
    [alert addAction:cancel];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
}


- (void)applicationWillResignActive:(UIApplication *)application {

}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateInactive) {
        
        NSString *dialogID = userInfo[kQMPushNotificationDialogIDKey];
        NSString *activeDialogID = [QMCore instance].activeDialogID;
        if ([dialogID isEqualToString:activeDialogID]) {
            // dialog is already active
            return;
        }
        
        [QMCore instance].pushNotificationManager.pushNotification = userInfo;
        
        // calling dispatch async for push notification handling to have priority in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[QMCore instance].pushNotificationManager handlePushNotificationWithDelegate:self];
        });
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   
    [[QMCore instance].chatManager disconnectFromChatIfNeeded];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[QMCore instance] login];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {
    
    if ([identifier isEqualToString:kQMNotificationActionTextAction]) {
        
        NSString *text = responseInfo[UIUserNotificationActionResponseTypedTextKey];
        
        NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
        if ([text stringByTrimmingCharactersInSet:whiteSpaceSet].length == 0) {
            // do not send message that contains only of spaces
            if (completionHandler) {
                
                completionHandler();
            }
            
            return;
        }
        
        NSString *dialogID = userInfo[kQMPushNotificationDialogIDKey];
        
        __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
            
            [application endBackgroundTask:task];
            task = UIBackgroundTaskInvalid;
        }];
        
        // Do the work associated with the task.
        ILog(@"Started background task timeremaining = %f", [application backgroundTimeRemaining]);
        
        [[[QMCore instance].chatService fetchDialogWithID:dialogID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
            
            QBChatDialog *chatDialog = t.result;
            if (chatDialog != nil) {
                
                NSUInteger opponentUserID = [userInfo[kQMPushNotificationUserIDKey] unsignedIntegerValue];
                
                if (chatDialog.type == QBChatDialogTypePrivate
                    && ![[QMCore instance].contactManager isFriendWithUserID:opponentUserID]) {
                    
                    if (completionHandler) {
                        
                        completionHandler();
                    }
                    
                    return nil;
                }
                
                return [[[QMCore instance].chatManager sendBackgroundMessageWithText:text toDialogWithID:dialogID] continueWithBlock:^id _Nullable(BFTask * _Nonnull messageTask) {
                    
                    if (!messageTask.isFaulted
                        && application.applicationIconBadgeNumber > 0) {
                        
                        application.applicationIconBadgeNumber = 0;
                    }
                    
                    [application endBackgroundTask:task];
                    task = UIBackgroundTaskInvalid;
                    
                    return nil;
                }];
            }
            
            return nil;
        }];
    }
    
    if (completionHandler) {
        
        completionHandler();
    }
}

#pragma mark - QMPushNotificationManagerDelegate protocol

- (void)pushNotificationManager:(QMPushNotificationManager *)__unused pushNotificationManager didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    UITabBarController *tabBarController = [[(UISplitViewController *)self.window.rootViewController viewControllers] firstObject];
    UIViewController *dialogsVC = [[(UINavigationController *)[[tabBarController viewControllers] firstObject] viewControllers] firstObject];
    
    NSString *activeDialogID = [QMCore instance].activeDialogID;
    if ([chatDialog.ID isEqualToString:activeDialogID]) {
        // dialog is already active
        return;
    }
    
    [dialogsVC performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
}


#pragma mark LocationManager Delegate
- (void)locationManager:(CLLocationManager *) __unused manager
       didFailWithError:(NSError *)error
{
    NSLog(@"location error %@", error.localizedDescription);
}

-(void)locationManager:(CLLocationManager *)__unused manager didUpdateLocations:(NSArray *)locations{
    
    
    if([DataManager sharedManager].user.userType.length == 0) return;
    
    CLLocation* location = [locations lastObject];
    
    NSDate* eventDate = location.timestamp;
    
    float defaultTolerate = 1.0;
    if (![[LocationManager sharedManager].cityName isEqualToString:@""]) {
        defaultTolerate = 30.0;
    }
    
    NSTimeInterval howRecent = [eventDate timeIntervalSinceDate:[LocationManager sharedManager].lastLoggedDateTime];
    if (fabs(howRecent) > defaultTolerate || [[LocationManager sharedManager].cityName isEqualToString:@""]) {
        //    {
        [LocationManager sharedManager].lastLoggedDateTime = eventDate;
        [LocationManager sharedManager].oldLocation = location.coordinate;
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             if([placemark.country length] != 0) {
                 [LocationManager sharedManager].countryName = placemark.country;
             } else {
                 [LocationManager sharedManager].countryName = @"";
             }
             if([placemark.locality length] != 0) {
                 [LocationManager sharedManager].cityName = placemark.locality;
             } if([placemark.administrativeArea length] != 0) {
                 [LocationManager sharedManager].stateName = placemark.administrativeArea;
             }
             else {
                 [LocationManager sharedManager].cityName = @"";
             }
             
             [LocationManager sharedManager].streetName = @"";
             if ([placemark.thoroughfare length] != 0) {
                 [LocationManager sharedManager].streetName = [NSString stringWithFormat:@"%@ %@", placemark.thoroughfare, placemark.subThoroughfare];
             }
             
         }];
    }
}

@end
