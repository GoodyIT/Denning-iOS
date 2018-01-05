
//
//  CustomOperation.m
//  DenningShare
//
//  Created by Denning IT on 2017-11-30.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CustomOperation.h"
#import "DIGlobal.h"

@interface CustomOperation()

@property (nonatomic) NSURL *url;
@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSMutableData *data;
@property (nonatomic) NSURLResponse *response;
@property (nonatomic) BOOL terminated;
@property (nonatomic, copy) CustomCompletionBlock completion;
@property (nonatomic, copy) NSDictionary* params;
@end

@implementation CustomOperation


- (id) initWithUrl:(NSURL*)url completion:(CustomCompletionBlock)completion {
    
    return [self initWithUrl:url completion:completion params:nil];
}

- (id) initWithUrl:(NSURL*)url completion:(CustomCompletionBlock)completion params:(NSDictionary*) params {
    self = [super init];
    
    if (self) {
        self.url = url;
        self.completion = completion;
        self.params = params;
    }
    
    return self;
}
#pragma mark - NSOperation

- (void)main {
    if (self.isCancelled) return;
    
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:kGroupShareIdentifier];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    [request setHTTPMethod:  @"GET"];
    
    // This is how we set header fields
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[defaults valueForKey:@"sessionID"]  forHTTPHeaderField:@"webuser-sessionid"];
    [request setValue:[defaults valueForKey:@"email"] forHTTPHeaderField:@"webuser-id"];
    if (_params != nil) {
        [request setHTTPMethod: @"POST"];
        NSError* error;
        NSData* jsondata = [NSJSONSerialization dataWithJSONObject:_params
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        [request setHTTPBody:jsondata];
    }
    
    self.response = nil;
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    [self.connection scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];
    [self.connection start];
    
    while(!self.terminated && !self.isCancelled) {
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (BOOL)isFinished {
    return self.terminated;
}

- (void)cancel {
    [self reset];
    [super cancel];
}

#pragma mark - NSURLConnectionDelegate -

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response {
    if ([self isCancelled]) {
        [self reset];
        return;
    }
    
    self.response = response;
    self.data = [NSMutableData new];
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data {
    if ([self isCancelled]) {
        [self reset];
        return;
    }
    
    [self.data appendData: data];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection {
    if ([self isCancelled]) {
        [self reset];
        return;
    }
    
    if (self.completion) {
        __weak typeof(self) weakSelf = self;
        
        self.completion(weakSelf.url, weakSelf.response, weakSelf.data, nil);
        
    }
    
    [self reset];
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
    if ([self isCancelled]) {
        [self reset];
        return;
    }
    
    if (self.completion) {
        __weak typeof(self) weakSelf = self;
        
        self.completion(weakSelf.url, weakSelf.response, weakSelf.data, error);
        
    }
    
    [self reset];
}

#pragma mark - private methods -

- (void) reset {
    self.terminated = YES;
    
    [self.connection cancel];
    self.connection = nil;
    
    self.data = nil;
}

@end
