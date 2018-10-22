//
//  AddMenu.m
//  Denning
//
//  Created by Denning IT on 2018-10-20.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import "AddMenu.h"

@implementation AddMenu

+ (instancetype) getAddMenu: (NSDictionary*) response {
    AddMenu* menu = [AddMenu new];
    
    menu.ios_icon = [response valueForKeyNotNull:@"ios_icon"];
    menu.title = [response valueForKeyNotNull:@"title"];
    menu.items = [AddMenu getAddMenuArray:[response objectForKeyNotNull:@"items"]];
    menu.openForm = [response valueForKeyNotNull:@"openForm"];
    
    return menu;
}

+ (NSMutableArray<AddMenu*>*) getAddMenuArray:(NSArray*) response
{
    
    NSMutableArray* array = [NSMutableArray new];
    for (id obj in response) {
        [array addObject:[AddMenu getAddMenu:obj]];
    }
    
    return array;
    
}

@end
