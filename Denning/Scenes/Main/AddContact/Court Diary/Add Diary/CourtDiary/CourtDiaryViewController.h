//
//  CourtDiaryViewController.h
//  Denning
//
//  Created by Ho Thong Mee on 22/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourtDiaryViewController : BaseTableViewController

@property (nonatomic, strong) EditCourtModel* courtDiary;

- (void) saveDiary;



@end
