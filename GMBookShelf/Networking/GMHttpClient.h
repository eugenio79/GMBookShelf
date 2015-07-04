//
//  GMHttpClient.h
//  GMBookShelf
//
//  Created by Giuseppe Morana on 03/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMBook.h"

#define GMDHttpClientErrorDomain @"GMDHttpClientErrorDomain"

typedef NS_ENUM(NSInteger, GMHttpClientErrorCode) {
    GMHttpClientErrorCodeParsing                = 1,
    GMHttpClientErrorRequestInProgress          = 2
};


@interface GMHttpClient : NSObject

@property (nonatomic, strong) NSString *baseUrlString;

+ (GMHttpClient *)sharedInstance;

/**
 * If the request is successfull, bookList param on success block is an array of GMBook objects, filled with info fetched from the WS
 */
- (void)requestBookListWithOffset:(NSInteger)offset withCount:(NSInteger)count withSuccessBlock:(void (^)(NSArray *bookList))success failure:(void (^)(NSError *error))failure;

/**
 * If the request is successfull, book param on success block is automatically filled with WS item details
 */
- (void)requestDetailsForBookWithId:(NSString *)bookId withSuccessBlock:(void (^)(GMBook *bookWithDetails))success failure:(void (^)(NSError *error))failure;

- (void)requestImageForBook:(GMBook *)book withSuccessBlock:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;

/// @return YES if there's already a requestBookList in progress
- (BOOL)isAlreadyRequestingForBookList;

@end


