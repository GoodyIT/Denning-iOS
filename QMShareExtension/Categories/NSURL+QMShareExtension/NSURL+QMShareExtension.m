//
//  NSURL+QMShareExtension.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/20/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "NSURL+QMShareExtension.h"
#import <Bolts/Bolts.h>
#import "QMLog.h"

NSString *const QMAppleMapsHost = @"maps.apple.com";
NSString *const QMAppleMapsPath = @"/maps";
NSString *const QMAppleMapsLatLonKey = @"ll";

NSString *const QMGoogleMapsAPIKey = @"AIzaSyAgJbVJswdgnpplYjAEip9BoBLTl05820o";
NSString *const QMGoogleMapsShortenerEndpointUrl = @"https://www.googleapis.com/urlshortener/v1/url";

NSString *const QMGoogleMapsShortHost = @"goo.gl";
NSString *const QMGoogleMapsShortPath = @"/maps";
NSString *const QMGoogleMapsHost = @"google.com";
NSString *const QMGoogleMapsSearchPath = @"maps/search";
NSString *const QMGoogleMapsPlacePath = @"maps/place";
NSString *const QMGoogleMapsProvider = @"google";


@implementation NSURL (QMShareExtension)

//MARK: - Public methods

- (BOOL)isLocationURL {
    
    BOOL isAppleMapURL = [self isAppleMapURL] ;
    BOOL isGoogleMapURL = [self isGoogleMapURL];
    
    BOOL isLocationURL = isAppleMapURL || isGoogleMapURL;
    
    return isLocationURL;
}

- (BFTask <CLLocation *>*)location {
    
    if ([self isAppleMapURL]) {
        
        CLLocationCoordinate2D coordinates = [self locationCoordinate];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinates.latitude
                                                          longitude:coordinates.longitude];
        return [BFTask taskWithResult:location];
    }
    
    else if ([self isGoogleMapURL]) {
        return [self locationFromGoogleURL:self];
    }
    else {
        NSParameterAssert(NO);
        return nil;
    }
}

+ (NSURL *)appleMapsURLForLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    NSString *coordinates = [NSString stringWithFormat:@"%lf,%lf", locationCoordinate.latitude, locationCoordinate.longitude];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.apple.com/maps?ll=%@&q=%@&t=m", coordinates, coordinates]];
    return url;
}

//MARK: - Private methods

- (CLLocationCoordinate2D)locationCoordinate {
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:false];
    NSArray *queryItems = urlComponents.queryItems;
    
    NSString *coordinateItem = nil;
    
    for (NSURLQueryItem *queryItem in queryItems) {
        if ([queryItem.name isEqualToString:QMAppleMapsLatLonKey]) {
            coordinateItem = queryItem.value;
        }
    }
    
    if (coordinateItem == nil) {
        return kCLLocationCoordinate2DInvalid;
    }
    
    
    NSArray *coordComponents = [coordinateItem componentsSeparatedByString:@","];
    if (coordComponents.count != 2) {
        return kCLLocationCoordinate2DInvalid;
    }
    
    double latitude = [coordComponents.firstObject floatValue];
    double longitude = [coordComponents.lastObject floatValue];
    
    return  CLLocationCoordinate2DMake(latitude, longitude);
}

- (BOOL)isAppleMapURL {
    
    return ([self.host isEqualToString:QMAppleMapsHost] &&
            [self.path isEqualToString:QMAppleMapsPath]);
}

- (BOOL)isGoogleMapURL {
    return [self isShortGoogleMapURL] || [self isLongGoogleMapURL];
}

- (BOOL)isShortGoogleMapURL {
    return
    [self.host isEqualToString:QMGoogleMapsShortHost] &&
    [self.path hasPrefix:QMGoogleMapsShortPath];
}

- (BOOL)isLongGoogleMapURL {
    return
    [self.host isEqualToString:QMGoogleMapsHost] &&
    ([self.path hasPrefix:QMGoogleMapsSearchPath] ||
     [self.path hasPrefix:QMGoogleMapsPlacePath]);
}

- (BFTask <CLLocation *> *)locationFromGoogleURL:(NSURL *)url {
    
    BFTaskCompletionSource *source = [[BFTaskCompletionSource alloc] init];
    
    void(^completionBlock)(NSString *longURL) = ^(NSString *longURL) {
        
        CLLocation *location = [self parseGoogleURL:longURL];
        if (location) {
            [source setResult:location];
        }
        else {
            NSError *error =
            [NSError errorWithDomain:@"QMShareExtension"
                                code:0
                            userInfo:nil];
            [source setError:error];
        }
    };
    
    if ([self isShortGoogleMapURL]) {
        
        [[self getLongURL] continueWithExecutor:BFExecutor.mainThreadExecutor
                                      withBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
                                          
                                          t.error ?
                                          [source setError:t.error] :
                                          completionBlock(t.result.absoluteString);
                                          
                                          return nil;
                                      }];
    }
    else {
        completionBlock(url.absoluteString);
    }
    
    return source.task;
}

- (CLLocation *)parseGoogleURL:(NSString *)googleURL {
    
    CLLocation *location = nil;
    
    NSString *pattern = @"([0-9.\\-]*),([0-9.\\-]*)";
    NSError *regexError = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&regexError];
    
    if (!regexError) {
        
        NSArray *matches = [regex matchesInString:googleURL
                                          options:0
                                            range:NSMakeRange(0, [googleURL length])];

        NSTextCheckingResult *mathResult = matches.firstObject;
        
        if (mathResult.numberOfRanges > 2) {
            NSString *latitude = [googleURL substringWithRange:[mathResult rangeAtIndex:1]];
            NSString *longitude = [googleURL substringWithRange:[mathResult rangeAtIndex:2]];
            
            if (fabs(latitude.doubleValue) > DBL_EPSILON &&
                fabs(longitude.doubleValue) > DBL_EPSILON) {
                
                  location = [[CLLocation alloc] initWithLatitude:latitude.doubleValue
                                                              longitude:longitude.doubleValue];
            }
        }
        NSLog(@"location = %@", location);
    }
    else {
        QMLog(@"REGEX error: %@", regexError);
    }
    
    return location;
}


- (BFTask <NSURL*> *)getLongURL {
    
    BFTaskCompletionSource *source = [[BFTaskCompletionSource alloc] init];
    
    NSString *url =
    [NSString stringWithFormat:@"%@?fields=longUrl,status&shortUrl=%@&key=%@",
     QMGoogleMapsShortenerEndpointUrl,
     QMEncodedStringFromStringWithEncoding(self.absoluteString, NSUTF8StringEncoding),
     QMGoogleMapsAPIKey];
    
    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:url]
                               completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          
          if (!error) {
              if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                  NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                  if (statusCode != 200) {
                      QMLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                      NSError *responseError =
                      [NSError errorWithDomain:@"QMShareExtension"
                                          code:0
                                      userInfo:nil];
                      
                      [source setError:responseError];
                  }
              }
              
              NSError *jsonParseError = nil;
              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:&jsonParseError];
              
              if (!jsonParseError) {
                  NSString *longUrl = [json objectForKey:@"longUrl"];
                  [source setResult:[NSURL URLWithString:longUrl]];
              }
              else {
                  QMLog(@"JSON parse error: %@", jsonParseError);
                  [source setError:error];
              }
          }
          else {
              QMLog(@"API request error: %@", error);
              [source setError:error];
          }
      }] resume];
    
    return source.task;
}

static inline NSString * QMEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    
    /*
     The documentation for `CFURLCreateStringByAddingPercentEscapes` suggests that one should "pre-process" URL strings with unpredictable sequences that may already contain percent escapes. However, if the string contains an unescaped sequence with '%' appearing without an escape code (such as when representing percentages like "42%"), `stringByReplacingPercentEscapesUsingEncoding` will return `nil`. Thus, the string is only unescaped if there are no invalid percent-escaped sequences.
     */
    NSString *unescapedString = [string stringByReplacingPercentEscapesUsingEncoding:encoding];
    if (unescapedString) {
        string = unescapedString;
    }
    
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kAFLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
}

@end
