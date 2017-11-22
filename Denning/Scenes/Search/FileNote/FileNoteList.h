//
//  FileNoteList.h
//  Denning
//
//  Created by Ho Thong Mee on 19/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileNoteList : UIViewController

@property (strong, nonatomic) NSString* clientName;
@property (strong, nonatomic) NSString* key;

@property (strong, nonatomic) NSArray<FileNoteModel*>* listOfFileNotes;
@end
