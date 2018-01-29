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
#import "QMColors.h"
#import "QMHelpers.h"
#import "QMNetworkManager.h"
#import "QMChatVC.h"
#import "DIGlobal.h"
#import "DataManager.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "LocationManager.h"
#import <Intents/Intents.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseAuth/FirebaseAuth.h>
@import Contacts;
@import GoogleMaps;
@import GooglePlaces;

@import UserNotifications;

#import "UIScreen+QMLock.h"
#import "UIImage+Cropper.h"
#import "QBSettings+Qmunicate.h"

static NSString * const kQMNotificationActionTextAction = @"TEXT_ACTION";
static NSString * const kQMNotificationCategoryReply = @"TEXT_REPLY";
static NSString * const kQMAppGroupIdentifier = @"group.denningitshare.extension";



@interface AppDelegate ()<QMPushNotificationManagerDelegate, CLLocationManagerDelegate, QMAuthServiceDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonnull, nonatomic, strong, readwrite) DemoDownloadStore *demoDownloadStore;
@property (nonnull, nonatomic, strong, readwrite) HWIFileDownloader *fileDownloader;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self startUpdatingCurrentLocation];
	
	application.applicationIconBadgeNumber = 0;
    
    // Quickblox settings
    [QBSettings configure];
    [QMServicesManager enableLogging:QMCurrentApplicationZone != QMApplicationZoneProduction];
    
    // QuickbloxWebRTC settings
    [QBRTCClient initializeRTC];
    [QBRTCConfig mediaStreamConfiguration].audioCodec = QBRTCAudioCodecISAC;
    [QBRTCConfig setStatsReportTimeInterval:0.0f]; // set to 1.0f to enable stats report
    
    // Configuring app appearance
//    [[UITabBar appearance] setTintColor:QMMainApplicationColor()];
  //  [[UINavigationBar appearance] setTintColor:QMSecondaryApplicationColor()];

    // Configuring searchbar appearance
    
    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBackgroundImage:QMStatusBarBackgroundImage() forBarPosition:0 barMetrics:UIBarMetricsDefault];
    
    [[UITextField appearance] setTintColor:QMSecondaryApplicationColor()];
    [UITextField appearance].keyboardAppearance = UIKeyboardAppearanceDark;
    
    [SVProgressHUD setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.92f]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    // Configuring external frameworks
    [FIRApp configure];
    [[FIRAuth auth] useAppLanguage];
    // Configuring external frameworks
    [Fabric with:@[CrashlyticsKit,  [Answers class]]];
    
    // Google Map
    [GMSServices provideAPIKey:kGoogleMapAPIKey];
    [GMSPlacesClient provideAPIKey:kGoogleMapPlaceAPIKey];
    
    if (launchOptions != nil) {
        NSDictionary *pushNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [QMCore instance].pushNotificationManager.pushNotification = pushNotification;
    }
    
    if ([QMCore instance].currentProfile != nil) {
        [[QMCore instance].currentProfile clearLastFetchingDate];
    }
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)application:(UIApplication *)__unused application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    if ([[FIRAuth auth] canHandleNotification:userInfo]) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
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
    application.applicationIconBadgeNumber = [[DataManager sharedManager].badgeValue integerValue];
    [[QMCore instance].chatManager disconnectFromChatIfNeeded];
}

- (void)applicationWillEnterForeground:(UIApplication *)__unused application {
    // sending presence after application becomes active,
    // or just restoring state if chat is disconnected
    if (QBChat.instance.manualInitialPresence) {
        QBChat.instance.manualInitialPresence = NO;
    }
    // connect to chat now
    [QMCore.instance login];
}

- (void)applicationDidBecomeActive:(UIApplication *)__unused application {
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push notification registration

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)__unused notificationSettings {
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
#endif
    }
    
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)__unused application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[QMCore instance].pushNotificationManager updateToken:deviceToken];
    FIRAuthAPNSTokenType firTokenType;

    if (QMCurrentApplicationZone == QMApplicationZoneProduction) {
        firTokenType = FIRAuthAPNSTokenTypeProd;
    }
    else {
        firTokenType = FIRAuthAPNSTokenTypeSandbox;
    }

    [[FIRAuth auth] setAPNSToken:deviceToken type:firTokenType];
}

- (void)application:(UIApplication *)__unused application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [[QMCore instance].pushNotificationManager handleError:error];
}

- (void)application:(UIApplication *)__unused application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
   withResponseInfo:(NSDictionary *)responseInfo
  completionHandler:(void (^)())completionHandler {
    
    [[QMCore instance].pushNotificationManager handleActionWithIdentifier:identifier
                                                       remoteNotification:userInfo
                                                             responseInfo:responseInfo
                                                        completionHandler:completionHandler];
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
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
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

- (BOOL)application:(UIApplication *)__unused application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))__unused restorationHandler {
    
    BOOL isCallIntent = [userActivity.activityType isEqualToString:INStartAudioCallIntentIdentifier] || [userActivity.activityType isEqualToString:INStartVideoCallIntentIdentifier];
    if (isCallIntent) {
        [QMCore.instance.callManager handleUserActivityWithCallIntent:userActivity];
    }
    
    return YES;
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
    
    @try {
        [dialogsVC performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        QMChatVC* chatVC = [QMChatVC chatViewControllerWithChatDialog:chatDialog];
        [dialogsVC.navigationController pushViewController:chatVC animated:YES];
    }
}


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

#pragma mark LocationManager Delegate
- (void)locationManager:(CLLocationManager *) __unused manager
       didFailWithError:(NSError *)error
{
    NSLog(@"location error %@", error.localizedDescription);
}

-(void)locationManager:(CLLocationManager *)__unused manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation* location = [locations lastObject];
    
    NSDate* eventDate = location.timestamp;
    
    float defaultTolerate = 2.0;
    if (![[DataManager sharedManager].user.streetName isEqualToString:@""]) {
        defaultTolerate = 30.0;
    }
    
    NSTimeInterval howRecent = [eventDate timeIntervalSinceDate:[DataManager sharedManager].user.lastLoggedDateTime];
    if (fabs(howRecent) > defaultTolerate) {
        
        [[DataManager sharedManager] setOldLocation:location lastLoggedDateTime:eventDate];
        
        GMSGeocoder *geocode= [GMSGeocoder geocoder];
        GMSReverseGeocodeCallback handler=^(GMSReverseGeocodeResponse *response,NSError *error)
        {
            GMSAddress *address=response.firstResult;
            if (address)
            {
//                [LocationManager sharedManager].countryName = address.country;
//                [LocationManager sharedManager].cityName = address.locality;
                [[DataManager sharedManager] setStreetName:address.lines.firstObject];
            }
        };
        [geocode reverseGeocodeCoordinate:location.coordinate completionHandler:handler];
    }
}

@end
