//
//  GMDataSource.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 03/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMHttpClient.h"
#import "AFNetworking.h"

@implementation GMHttpClient

+ (GMHttpClient *)sharedInstance {
    
    static GMHttpClient *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[GMHttpClient alloc] init];
        
        _sharedInstance.baseUrlString = @"";    // default
    });
    return _sharedInstance;
}

- (void)requestBookListWithOffset:(NSInteger)offset withCount:(NSInteger)count withSuccessBlock:(void (^)(NSArray *bookList))success failure:(void (^)(NSError *error))failure
{
    NSLog(@"requesting bookList...");
    
    NSString *urlStr = [NSString stringWithFormat:@"%@items?offset=%ld&count=%ld", self.baseUrlString, (long)offset, (long)count];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"bookList request completed with success");
        
        if (success == nil) return;
        
        // 1. response validation (1) - NSArray
        
        if (![responseObject isKindOfClass:[NSArray class]]) {
            if (failure != nil) {
                failure([NSError errorWithDomain:GMDHttpClientErrorDomain code:GMHttpClientErrorCodeParsing userInfo:nil]);
            }
            return;
        }
        NSArray *items = (NSArray *)responseObject;
        
        // 2. convert dictionaries into GMBook objects
        
        NSMutableArray *books = [NSMutableArray new];
        
        for (id obj in items) {
            
            // 3. response validation (2) - each object should be an NSDictionary
            
            if (![obj isKindOfClass:[NSDictionary class]]) {
                
                if (failure != nil) {
                    failure([NSError errorWithDomain:GMDHttpClientErrorDomain code:GMHttpClientErrorCodeParsing userInfo:nil]);
                }
                return;
            }
            
            GMBook *book = [GMBook bookWithDictionary:(NSDictionary *)obj];
            [books addObject:book];
        }
        
        success([NSArray arrayWithArray:books]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"bookList request completed with failure");
        
        if (failure != nil) {
            failure(error);
        }
    }];
    
    [operation start];
}

- (void)requestDetailsForBookWithId:(NSString *)bookId withSuccessBlock:(void (^)(GMBook *bookWithDetails))success failure:(void (^)(NSError *error))failure
{
    NSAssert(bookId != nil, @"You should pass a non-empty bookId");
    
    NSString *urlStr = [NSString stringWithFormat:@"%@items/%@", self.baseUrlString, bookId];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success == nil) return;
        
        // Response validation - object should be an NSDictionary
        
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            
            if (failure != nil) {
                failure([NSError errorWithDomain:GMDHttpClientErrorDomain code:GMHttpClientErrorCodeParsing userInfo:nil]);
            }
            return;
        }
        
        GMBook *book = [GMBook bookWithDictionary:(NSDictionary *)responseObject];
        
        if (success) {
            success(book);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DETAILS_RECEIVED
                                                            object:nil
                                                          userInfo:@{
                                                                     @"book": book,
                                                                     @"image": (UIImage *)responseObject
                                                                     }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure != nil) {
            failure(error);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DETAILS_RECEIVED
                                                            object:nil
                                                          userInfo:@{
                                                                     @"bookId": bookId,
                                                                     @"error": error
                                                                     }];
    }];
    
    [operation start];
}

- (void)requestImageForBook:(GMBook *)book withSuccessBlock:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure
{
    NSAssert(book != nil, @"You should pass a non-empty GMBook object, already filled with details");
    NSAssert(book.imageUrlString != nil, @"You should pass a non-empty GMBook object, already filled with details");
    
    NSURL *url = [NSURL URLWithString:book.imageUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success != nil) {
            success((UIImage *)responseObject);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE_DOWNLOADED
                                                            object:nil
                                                          userInfo:@{
                                                                     @"book": book,
                                                                     @"image": (UIImage *)responseObject
                                                                     }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure != nil) {
            failure(error);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE_DOWNLOADED
                                                            object:nil
                                                          userInfo:@{
                                                                     @"bookId": book.ID,
                                                                     @"error": error
                                                                     }];
    }];
    [requestOperation start];
}

- (BOOL)isAlreadyRequestingForBookList {
    return NO;
}

@end
