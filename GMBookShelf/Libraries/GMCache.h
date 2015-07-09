//
//  GMCache.h
//  GMBookShelf
//
//  Created by Giuseppe Morana on 08/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMBook.h"

#define GMCacheErrorDomain @"GMCacheErrorDomain"

typedef NS_ENUM(NSInteger, GMCacheErrorCode) {
    GMCacheErrorCodeNotFound                = 1
};

@interface GMCache : NSObject

+ (GMCache *)sharedInstance;

- (void)saveImage:(UIImage *)imageToSave relatedToUrlString:(NSString *)urlString;

/// success and failure block codes are called back on UI thread
- (void)loadImageWithUrlString:(NSString *)urlString withSuccessBlock:(void (^)(UIImage *imageCached))success failure:(void (^)(NSError *error))failure;

- (void)clear;

@end
