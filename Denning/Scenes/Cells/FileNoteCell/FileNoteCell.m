//
//  FileNoteCell.m
//  Denning
//
//  Created by Ho Thong Mee on 19/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileNoteCell.h"

@implementation FileNoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithModel:(FileNoteModel*) model
{
    _nickName.text = model.clsMeetBy.strInitials;
    _date.text = [DIHelpers getDateInShortForm:model.dtDate];
    _note.text = model.strNote;
}

@end
