//
//  EventModel.m
//  Denning
//
//  Created by DenningIT on 01/02/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "EventModel.h"

@implementation EventModel

@synthesize URL;
@synthesize FileNo;
@synthesize eventCode;
@synthesize description;
@synthesize eventStart;
@synthesize eventEnd;
@synthesize imageURL;
@synthesize imageData;
@synthesize location;
@synthesize reminder1;
@synthesize reminder2;

+ (EventModel*) getEventFromResponse: (NSDictionary*) response
{
    EventModel* eventModel = [EventModel new];
    
    eventModel.caseName = [response valueForKeyNotNull:@"description"];
    eventModel.FileNo = [response valueForKeyNotNull:@"FileNo"];
    eventModel.caseNo = [response valueForKeyNotNull:@"caseNo"];
    eventModel.URL = [response valueForKeyNotNull:@"URL"];
    eventModel.eventCode = [response valueForKeyNotNull:@"code"];
    eventModel.eventStart = [response valueForKeyNotNull:@"eventStart"];
    eventModel.eventEnd = [response valueForKeyNotNull:@"eventEnd"];
    eventModel.eventType = [response valueForKeyNotNull:@"eventType"];
    if (![[response objectForKey:@"img"] isEqual:[NSNull null]]){
        eventModel.imageURL = [[response objectForKey:@"img"] valueForKeyNotNull:@"FileName"];
        eventModel.imageData = [[response objectForKey:@"img"] valueForKeyNotNull:@"base64"];
    }
    
    eventModel.location = [response valueForKeyNotNull:@"location"];
    eventModel.reminder1 = [response valueForKeyNotNull:@"reminder1"];
    eventModel.reminder2 = [response valueForKeyNotNull:@"reminder2"];
    
    eventModel.counsel = [response valueForKeyNotNull:@"counsel"];
    
    return eventModel;
}

+ (NSArray*) getEventsArrayFromResponse: (NSDictionary*) response
{
    NSMutableArray* eventsArray = [NSMutableArray new];
    
    if ([response isKindOfClass:[NSArray class]]) {
        for (NSDictionary* dictionary in response) {
            [eventsArray addObject:[EventModel getEventFromResponse:dictionary]];
        }
    }

    return eventsArray;
}

@end
