//
//  TemplateCell.h
//  Denning
//
//  Created by Ho Thong Mee on 24/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIGeneralCell.h"

@interface TemplateCell : DIGeneralCell
@property (weak, nonatomic) IBOutlet UILabel *templateName;
@property (weak, nonatomic) IBOutlet UILabel *versionNo;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *user;

- (void) configureCellWithModel: (TemplateModel*) model;

@end
