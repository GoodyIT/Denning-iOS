//
//  DocumentCell.h
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralContactCell.h"

@interface DocumentCell : GeneralContactCell

- (void) configureCellWithFileModel: (FileModel*) model;
@end
