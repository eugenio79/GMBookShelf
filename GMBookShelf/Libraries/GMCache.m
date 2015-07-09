//
//  GMCache.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 08/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMCache.h"
#import "NSString+MD5.h"

#define GM_BOOK_PREFIX @"GM_BOOK_PREFIX"

@interface GMCache()
@property (nonatomic, strong) NSString *cachePath;
@end

@implementation GMCache

#pragma mark - public APIs

+ (GMCache *)sharedInstance {
    
    static GMCache *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[GMCache alloc] init];
    });
    return _sharedInstance;
}

- (void)saveImage:(UIImage *)imageToSave relatedToUrlString:(NSString *)urlString {
    
    NSAssert(imageToSave != nil, @"imageToSave shouldn't be nil");
    NSAssert(urlString != nil, @"urlString shouldn't be nil");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *fileName = [NSString stringWithFormat:@"%@_%@.png", GM_BOOK_PREFIX, [urlString MD5]];
        NSString *pathToSave = [[self cachePath] stringByAppendingPathComponent:fileName];
        BOOL written = [UIImagePNGRepresentation(imageToSave) writeToFile:pathToSave atomically:YES];
        if (!written) NSLog(@"error while trying to save: %@", pathToSave);
    });
}

- (void)loadImageWithUrlString:(NSString *)urlString withSuccessBlock:(void (^)(UIImage *imageCached))success failure:(void (^)(NSError *error))failure {
    
    NSAssert(urlString != nil, @"urlString shouldn't be nil");
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.png", GM_BOOK_PREFIX, [urlString MD5]];
    NSString *imagePath  = [self.cachePath stringByAppendingPathComponent:fileName];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    if (image != nil) {
        if (success != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(image);
            });
        }
    } else {
        if (failure != nil) {
            NSError *error = [NSError errorWithDomain:GMCacheErrorDomain
                                                 code:GMCacheErrorCodeNotFound
                                             userInfo:@{
                                                        @"urlString": urlString
                                                        }];
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }
}

- (void)clear {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [self cachePath];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        if ([file hasPrefix:GM_BOOK_PREFIX]) {
            NSString *path = [directory stringByAppendingPathComponent:file];
            BOOL success = [fm removeItemAtPath:path error:&error];
            if (!success || error) {
                NSLog(@"error while trying to remove item at path: %@", path);
            }
        }
    }
}

#pragma mark - private

- (NSString *)cachePath {
    if (_cachePath == nil) {
        _cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSLog(@"cachePath: %@", _cachePath);
    }
    return _cachePath;
}

@end
