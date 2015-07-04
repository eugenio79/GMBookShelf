//
//  GMDataSource.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 04/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMDataSource.h"
#import "GMHttpClient.h"


@interface GMDataSource() {
    GMHttpClient *_httpClient;
    NSMutableArray *_booksInCache;
}

@end

@implementation GMDataSource

- (instancetype)init {
    
    if (self = [super init]) {
        _booksInCache = [NSMutableArray new];
        _httpClient = [GMHttpClient sharedInstance];
        
        /*
        [_httpClient requestBookListWithOffset:0 withCount:GM_PAGE_SIZE withSuccessBlock:^(NSArray *bookList) {
            
            [_booksInCache addObjectsFromArray:bookList];
            
            if (self.delegate != nil) {
                [self.delegate didFetchBookList:bookList];
            }
        } failure:^(NSError *error) {
            if (self.delegate != nil) {
                [self.delegate didFailWithError:error];
            }
        }];
         */
    }
    return self;
}

- (NSInteger)booksCount {
    return _booksInCache.count;
}

- (GMBook *)bookAtIndex:(NSInteger)index {
    
    return nil;
}

//- (void)didUpdateBook:(GMBook *)book;
//- (void)didFetchBookList:(NSArray *)bookList;

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

@end
