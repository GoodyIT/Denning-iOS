//
//  QBChatAttachment+QMFactory.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import "QBChatAttachment+QMFactory.h"

static NSString *const kQMAttachmentTypeAudio = @"audio";
static NSString *const kQMAttachmentTypeImage = @"image";
static NSString *const kQMAttachmentTypeVideo = @"video";
static NSString *const kQMAttachmentTypePdf = @"pdf";
static NSString *const kQMAttachmentTypeDoc = @"doc";

static NSString *const kQMAttachmentContentTypeAudio = @"audio/mp4";
static NSString *const kQMAttachmentContentTypeVideo = @"video/mp4";

@implementation QBChatAttachment (QMFactory)

+ (instancetype)initWithName:(nullable NSString *)name
                     fileURL:(nullable NSURL *)fileURL
                 contentType:(NSString *)contentType
              attachmentType:(NSString *)type {
    
    QBChatAttachment *attachment = [QBChatAttachment new];
    
    attachment.type = type;
    attachment.name = name;
    attachment.localFileURL = fileURL;
    attachment.contentType = contentType;
    
    return attachment;
}

+ (instancetype)initWithName:(nullable NSString *)name
                     fileURL:(nullable NSURL *)fileURL
                 contentType:(NSString *)contentType
              attachmentType:(NSString *)type
                    fileSize:(NSInteger) fileSize {
    
    QBChatAttachment *attachment = [self initWithName:name fileURL:fileURL contentType:contentType attachmentType:type];
    
    attachment.size = fileSize;
    
    return attachment;
}

+ (instancetype)videoAttachmentWithFileURL:(NSURL *)fileURL {
    
    NSParameterAssert(fileURL);
    
    return [self initWithName:@"Video attachment"
                      fileURL:fileURL
                  contentType:kQMAttachmentContentTypeVideo
               attachmentType:kQMAttachmentTypeVideo];
}

+ (instancetype)audioAttachmentWithFileURL:(NSURL *)fileURL {
    
    NSParameterAssert(fileURL);
    
    return [self initWithName:@"Voice message"
                      fileURL:fileURL
                  contentType:kQMAttachmentContentTypeAudio
               attachmentType:kQMAttachmentTypeAudio];
}

+ (instancetype) fileAttachmentWithFileURL:(NSURL *)fileURL contentType:(NSString*)contentType fileName:(NSString*) fileName fileSize:(NSInteger)fileSize{
    NSParameterAssert(fileURL);
    return [self initWithName:fileName
                      fileURL:fileURL
                  contentType:contentType
               attachmentType:@"file"
                     fileSize:fileSize];
}

+ (instancetype)imageAttachmentWithImage:(UIImage *)image fileName:(NSString*) fileName {
    
    NSParameterAssert(image);
    
    int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    
    NSString *contentType = [NSString stringWithFormat:@"image/%@", hasAlpha ? @"png" : @"jpg"];
    
    QBChatAttachment *attachment = [self initWithName:fileName
                                              fileURL:nil
                                          contentType:contentType
                                       attachmentType:kQMAttachmentTypeImage];
    attachment.image = image;
    
    return attachment;
}

+ (instancetype)imageAttachmentWithImage:(UIImage *)image {
    return [self imageAttachmentWithImage:image fileName:@"Image Attach"];
}

@end
