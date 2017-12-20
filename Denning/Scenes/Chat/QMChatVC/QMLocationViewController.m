//
//  QMLocationViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMLocationViewController.h"

#import "QMMapView.h"
#import "QMLocationButton.h"
#import "QMLocationPinView.h"

static const CGFloat kQMLocationButtonSize = 44.0f;
static const CGFloat kQMLocationButtonSpacing = 16.0f;

static const CGFloat kQMLocationPinXShift = 3.5f;

@interface QMLocationViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
{
    QMMapView *_mapView;
    QMLocationButton *_locationButton;
    QMLocationPinView *_pinView;
    
    CLLocationManager *_locationManager;
    
    CLLocationCoordinate2D targetLocation;
    
    BOOL _initialPin;
    BOOL _userLocationChanged;
    BOOL _regionChanged;
}

@end

@implementation QMLocationViewController

//MARK: - Construction

- (instancetype)init {
    
    self = [super init];
    if (self != nil) {
        
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithState:(QMLocationVCState)state {
    
    self = [super init];
    if (self != nil) {
        
        [self commonInit];
        
        _state = state;
        
        switch (state) {
                
            case QMLocationVCStateView:
                [self configureMapButtons];
                break;
                
            case QMLocationVCStateSend:
                [self configureSendState];
                break;
        }
    }
    
    return self;
}

- (instancetype)initWithState:(QMLocationVCState)state locationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    self = [self initWithState:state];
    if (self != nil) {
        
        [self setLocationCoordinate:locationCoordinate];
    }
    
    return self;
}

- (void)commonInit {
    
    self.title = NSLocalizedString(@"QM_STR_LOCATION", nil);
    
    _mapView = [[QMMapView alloc] initWithFrame:self.view.bounds];
    [_mapView setManipulationsEnabled:YES];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
}

- (void) configureMapButtons {
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapButton setTitle:@"Maps" forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(_openNavigation:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapButton];
}

- (void) _openAppleMap {
    MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:targetLocation];

    MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:placeMark];
    
    mapItem.name = @"Target location";
    
    NSDictionary* launchOptions = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving};
    
    MKMapItem* currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
}

- (void) _openGoogleMap {
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        NSString* googleMapString = [NSString stringWithFormat:@"comgooglemaps://?center=%lf,%lf&zoom=14&views=traffic", targetLocation.latitude, targetLocation.longitude];
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:googleMapString]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:@"https://itunes.apple.com/us/app/google-maps-gps-navigation/id585027354"]];
    }
}

- (void) _openWaze {
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:@"waze://"]]) {
        // Waze is installed. Launch Waze and start navigation
        NSString *urlStr =
        [NSString stringWithFormat:@"https://waze.com/ul?ll=%f,%f&navigate=yes",
         targetLocation.latitude, targetLocation.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    } else {
        // Waze is not installed. Launch AppStore to install Waze app
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:@"http://itunes.apple.com/us/app/id323229106"]];
    }
}

- (void) _openNavigation:(UIButton*) sender {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"Denning"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _openAppleMap];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Google Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _openGoogleMap];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Open in Waze" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _openWaze];
    }]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = sender;
        alertController.popoverPresentationController.sourceRect = sender.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)configureSendState {
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"QM_STR_SEND", nil) style:UIBarButtonItemStylePlain target:self action:@selector(_sendAction)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) style:UIBarButtonItemStylePlain target:self action:@selector(_cancelAction)];
    
    CGFloat shift = kQMLocationButtonSize + kQMLocationButtonSpacing;
    _locationButton = [[QMLocationButton alloc]
                       initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - shift,
                                                CGRectGetHeight(self.view.bounds) - shift,
                                                kQMLocationButtonSize,
                                                kQMLocationButtonSize)];
    _locationButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [_locationButton addTarget:self action:@selector(_updateUserLocation) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_locationButton];
    
    _pinView = [[QMLocationPinView alloc] init];
    _pinView.frame = CGRectMake(CGRectGetWidth(_mapView.frame) / 2.0f - QMLocationPinViewOriginPinCenter,
                                CGRectGetHeight(_mapView.frame) / 2.0f - kQMLocationPinXShift,
                                CGRectGetWidth(_pinView.frame),
                                CGRectGetHeight(_pinView.frame));
    _pinView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [_mapView addSubview:_pinView];
}

//MARK: - Setters

- (void)setLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    targetLocation = locationCoordinate;
    [_mapView markCoordinate:locationCoordinate animated:NO];
}

//MARK: - Private

- (void)_sendAction {
    
    self.sendButtonPressed(_mapView.centerCoordinate);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_cancelAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_showLocationRestrictedAlert {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"QM_STR_LOCATION_ERROR", nil)
                                          message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_LOCATION", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_SETTINGS", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)_updateUserLocation {
    
    if (_userLocationChanged || _regionChanged) {
        
        [_locationButton setLoadingState:YES];
        [self _setRegionForCoordinate:_mapView.userLocation.coordinate];
        
        _userLocationChanged = NO;
        _regionChanged = NO;
    }
}

- (void)_setRegionForCoordinate:(CLLocationCoordinate2D)coordinate {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, MKCoordinateSpanDefaultValue, MKCoordinateSpanDefaultValue);
    [_mapView setRegion:region animated:YES];
}

//MARK: - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)__unused manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
            
        case kCLAuthorizationStatusNotDetermined:
            break;
            
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            
            _locationButton.hidden = YES;
            [self _showLocationRestrictedAlert];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            _locationButton.hidden = NO;
            _mapView.showsUserLocation = YES;
            break;
    }
}

//MARK: - MKMapViewDelegate

- (void)mapView:(MKMapView *)__unused mapView didUpdateUserLocation:(MKUserLocation *)__unused userLocation {
    
    _userLocationChanged = YES;
    
    if (!_initialPin) {
        
        [self _updateUserLocation];
        _initialPin = YES;
    }
}

- (void)mapView:(MKMapView *)__unused mapView regionWillChangeAnimated:(BOOL)__unused animated {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [_pinView setPinRaised:YES animated:YES];
}

- (void)mapView:(MKMapView *)__unused mapView regionDidChangeAnimated:(BOOL)__unused animated {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (_locationButton.loadingState) {
        
        [_locationButton setLoadingState:NO];
    }
    else {
        
        _regionChanged = YES;
    }
    
    [_pinView setPinRaised:NO animated:YES];
}

@end
