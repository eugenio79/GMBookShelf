//
//  GMHttpClient.h
//  GMBookShelf
//
//  Created by Giuseppe Morana on 03/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMBook.h"

#define GMHttpClientErrorDomain @"GMHttpClientErrorDomain"

typedef NS_ENUM(NSInteger, GMHttpClientErrorCode) {
    GMHttpClientErrorCodeParsing                = 1
};

typedef NS_ENUM(NSInteger, GMHttpClientNetworkStatus) {
    GMHttpClientNetworkStatusOffline             = 0,
    GMHttpClientNetworkStatusOnline              = 1
};

#define NOTIFICATION_DETAILS_RECEIVED @"NOTIFICATION_DETAILS_RECEIVED"  // book details fetch completed
#define NOTIFICATION_IMAGE_DOWNLOADED @"NOTIFICATION_IMAGE_DOWNLOADED"
#define NOTIFICATION_NETWORK_STATUS_CHANGED @"NOTIFICATION_NETWORK_STATUS_CHANGED"    // offline -> online, etc.

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

/**
 * This method uses two ways to notificate the completion of the task:
 * - with a block (success or failure), to notify directly the caller
 * - with an NSNotification, to notify anyone else is registering as an observer
 */
- (void)requestImageForBook:(GMBook *)book withSuccessBlock:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;

/// @return YES if the HTTP client has network
- (BOOL)isOnline;

@end


