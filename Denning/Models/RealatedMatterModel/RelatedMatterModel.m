//
//  RelatedMatterModel.m
//  Denning
//
//  Created by DenningIT on 26/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "RelatedMatterModel.h"

@implementation RelatedMatterModel
@synthesize partyGroupArray;

+ (RelatedMatterModel*) getRelatedMatterFromResponse: (NSDictionary*) response
{
    RelatedMatterModel* relatedMatter = [RelatedMatterModel new];
    
    relatedMatter.systemNo = [response objectForKey:@"systemNo"];
    
    relatedMatter.clientName = [NSString stringWithFormat:@"%@", [[response objectForKeyNotNull:@"primaryClient"] valueForKeyNotNull:@"name"]];
    relatedMatter.contactCode = [[response objectForKeyNotNull:@"primaryClient"] valueForKeyNotNull:@"code"];
    relatedMatter.openDate = [response valueForKeyNotNull:@"dateOpen"];
    relatedMatter.ref = [response valueForKeyNotNull:@"referenceNo"];
    relatedMatter.fileStatus = [CodeDescription getCodeDescriptionFromResponse:[response objectForKeyNotNull:@"fileStatus"]];
    relatedMatter.locationBox = [response valueForKeyNotNull:@"locationBox"];
    relatedMatter.locationPocket = [response valueForKeyNotNull:@"locationPocket"];
    relatedMatter.locationPhysical = [response valueForKeyNotNull:@"locationPhysical"];
    relatedMatter.dateClose = [response valueForKeyNotNull:@"dateClose"];
    
    relatedMatter.legalAssistant = [StaffModel getStaffFromResponse:[response objectForKeyNotNull:@"legalAssistant"]];
    
    relatedMatter.matter = [MatterCodeModel getMatterCodeFromResponse:[response objectForKeyNotNull:@"matter"]];
    
    relatedMatter.branch = [MatterBranchModel getMatterBranchFromResponse:[response objectForKeyNotNull:@"branch"]];
    
    relatedMatter.partner = [StaffModel getStaffFromResponse:[response objectForKeyNotNull:@"partner"]];
    
    relatedMatter.partyGroupArray = [RelatedMatterModel getPartyGroupArrayFromResponse: [response objectForKeyNotNull:@"partyGroup"]];
    
    relatedMatter.primaryClient = [ClientModel getClientFromResponse:[response objectForKeyNotNull:@"primaryClient"]];
    
    relatedMatter.court = [CourtModel getCourtFromResponse:[response objectForKeyNotNull:@"courtInfo"]];
    
    relatedMatter.solicitorGroupArray = [RelatedMatterModel getSolicitorGroupArrayFromResponse:[response objectForKeyNotNull:@"solicitorsGroup"]];
    
    relatedMatter.propertyGroupArray = [PropertyModel getPropertyArrayFromResponse:[response objectForKeyNotNull:@"propertyGroup"]];
    
    relatedMatter.bankGroupArray = [BankGroupModel getBankGroupArrayFromResponse:[response objectForKeyNotNull:@"bankGroup"]];
    
    relatedMatter.clerk = [StaffModel getStaffFromResponse:[response objectForKeyNotNull:@"clerk"]];
    
    relatedMatter.RMGroupArray = [RelatedMatterModel getGeneralGroupArrayFromResponse:[response objectForKeyNotNull:@"RMGroup"]];
    
    relatedMatter.dateGroupArray =  [RelatedMatterModel getGeneralGroupArrayFromResponse:[response objectForKeyNotNull:@"dateGroup"]];
    
    relatedMatter.textGroupArray = [RelatedMatterModel getGeneralGroupArrayFromResponse:[response objectForKeyNotNull:@"textGroup"]];
    
    relatedMatter.remarks = [response valueForKeyNotNull:@"remarks"];
    
    return relatedMatter;
}

+(NSArray*) getPartyGroupArrayFromResponse: (NSArray*) response
{
    NSMutableArray* partyGroupArray = [NSMutableArray new];
    
    for (id group in response) {
         PartyGroupModel* partyGroupModel = [PartyGroupModel new];
        partyGroupModel.partyGroupName = [group valueForKeyNotNull:@"PartyName"];
        partyGroupModel.partyArray = [ClientModel getClientArrayFromReponse:[group objectForKeyNotNull:@"party"]];
        [partyGroupArray addObject:partyGroupModel];
    }
   
    return partyGroupArray;
}

+(NSArray*) getSolicitorGroupArrayFromResponse: (NSArray*) response
{
    NSMutableArray* solicitorGroupArray = [NSMutableArray new];
    for (id group in response) {
        SolicitorGroup* solicitorGroup = [SolicitorGroup new];
        solicitorGroup.solicitorGroupName = [group objectForKey:@"groupName"];
        id solicitor = [group objectForKey:@"solicitor"];
        if ([solicitor isKindOfClass:[NSNull class]]) {
            solicitorGroup.solicitorCode = @"";
            solicitorGroup.solicitorName = @"";
            solicitorGroup.solicitorReference = @"";
        } else {
            solicitorGroup.solicitorCode = [solicitor objectForKey:@"code"];
            solicitorGroup.solicitorName = [solicitor objectForKey:@"name"];
            solicitorGroup.solicitorReference = [group objectForKey:@"reference"];
        }
        
        [solicitorGroupArray addObject:solicitorGroup];
    }
    
    return [solicitorGroupArray copy];
}

+(NSArray*) getGeneralGroupArrayFromResponse: (NSArray*) response
{
    NSMutableArray<GeneralGroup*>* RMGroupArray = [NSMutableArray new];
    for (id group in response) {
        GeneralGroup *model = [GeneralGroup new];
        model.fieldName = [group valueForKeyNotNull:@"fieldName"];
        model.formula = [group valueForKeyNotNull:@"formula"];
        model.value = [group valueForKeyNotNull:@"value"];
        model.label = [group valueForKeyNotNull:@"label"];
        [RMGroupArray addObject:model];
    }
    return [RMGroupArray copy];
}


@end
