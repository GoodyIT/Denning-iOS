//
//  QBChatAttachment+QMFactory.h
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import <Quickblox/Quickblox.h>
#import "QBChatAttachment+QMCustomParameters.h"
#import <CoreLocation/CLLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBChatAttachment (QMFactory)

- (instancetype)initWithName:(NSString *)name
                     fileURL:(nullable NSURL *)fileURL
                 contentType:(NSString *)contentType
              attachmentType:(NSString *)type;

+ (instancetype)videoAttachmentWithFileURL:(NSURL *)fileURL;
+ (instancetype)audioAttachmentWithFileURL:(NSURL *)fileURL;
+ (instancetype)imageAttachmentWithImage:(UIImage *)image;
+ (instancetype)imageAttachmentWithImage:(UIImage *)image fileName:(NSString*) fileName;
+ (instancetype)fileAttachmentWithFileURL:(NSURL*)filePath contentType:(NSString*)contentType fileName:(NSString*)fileName fileSize:(NSInteger)fileSize;
+ (instancetype)locationAttachmentWithCoordinate:(CLLocationCoordinate2D)locationCoordinate;

@end

NS_ASSUME_NONNULL_END
