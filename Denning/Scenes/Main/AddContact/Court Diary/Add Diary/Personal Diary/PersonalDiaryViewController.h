//
//  PersonalDiaryViewController.h
//  Denning
//
//  Created by Ho Thong Mee on 22/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalDiaryViewController : BaseTableViewController

@property(strong, nonatomic) OfficeDiaryModel* personalDiary;

- (void) saveDiary;

@end
