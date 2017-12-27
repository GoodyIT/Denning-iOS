//
//  DIDocumentManager.h
//  Denning
//
//  Created by Denning IT on 2017-12-13.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DIDocumentManager : NSObject< UIDocumentInteractionControllerDelegate>

+ (instancetype) shared;

- (NSURL*) isAttachedFileExist:(NSString*) fileName;

- (NSURL*) createNewDir:(NSString*) subDir;

- (void) viewDocument:(NSURL*) Url inViewController:(UIViewController*) viewController withCompletion:(void(^)(NSURL *filePath)) completion;

- (void) downloadFileFromURL: (NSURL *) ur withProgress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(NSURL *filePath))completionBlock onError:(void (^)(NSError *error))errorBlock;

- (void)displayDocument:(NSURL*)document inView:(UIViewController*) viewController;

- (void) viewDocument:(NSURL*) Url inViewController:(UIViewController*) viewController withCompletion:(void(^)(NSURL *filePath)) completion withCustomParam:(NSString*) custom;

@end
