//
//  QBSettings+Qmunicate.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/3/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QBSettings+Qmunicate.h"

@implementation QBSettings (Qmunicate)

+ (void)configure{
    
    switch (QMCurrentApplicationZone) {
            
        case QMApplicationZoneDevelopment:
            
            QBSettings.applicationID = 55869;
            QBSettings.authKey = @"tpH4TbFKOcmrYet";
            QBSettings.authSecret = @"Tctz5xEDNWuJQq4";
            QBSettings.accountKey = @"NuMeyx3adrFZURAvoA5j";
            
            break;
            
        case QMApplicationZoneDevelopment1:
            
            QBSettings.applicationID  = 55869;
            QBSettings.authKey = @"tpH4TbFKOcmrYet";
            QBSettings.authSecret = @"Tctz5xEDNWuJQq4";
            QBSettings.accountKey =  @"NuMeyx3adrFZURAvoA5j";
            
            break;
            
        case QMApplicationZoneProduction:
            
            QBSettings.applicationID = 55869;
            QBSettings.authKey = @"tpH4TbFKOcmrYet";
            QBSettings.authSecret = @"Tctz5xEDNWuJQq4";
            QBSettings.accountKey = @"NuMeyx3adrFZURAvoA5j";
            
            break;
            
        case QMApplicationZoneQA:
            
            QBSettings.applicationID = 55869;
            QBSettings.authKey = @"tpH4TbFKOcmrYet";
            QBSettings.authSecret = @"Tctz5xEDNWuJQq4";
            QBSettings.accountKey = @"NuMeyx3adrFZURAvoA5j";
            QBSettings.apiEndpoint = @"https://apistage1.quickblox.com";
            QBSettings.chatEndpoint = @"chatstage1.quickblox.com";
            
            break;
      
        default:
            break;
    }
    
    QBSettings.applicationGroupIdentifier = @"group.denningitshare.extension";
    QBSettings.autoReconnectEnabled = YES;
    QBSettings.carbonsEnabled = YES;
    
    QBSettings.logLevel =
    QMCurrentApplicationZone == QMApplicationZoneProduction ? QBLogLevelNothing : QBLogLevelDebug;
}

@end
