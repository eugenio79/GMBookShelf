//
//  GMDataSource.h
//  GMBookShelf
//
//  Created by Giuseppe Morana on 04/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMDataSourceProtocol.h"

@interface GMDataSource : NSObject

@property (nonatomic, weak) id<GMDataSourceProtocol> delegate;

//- (void)didUpdateBook:(GMBook *)book;
//- (void)didFetchBookList:(NSArray *)bookList;

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


- (NSInteger)booksCount;

- (GMBook *)bookAtIndex:(NSInteger)index;

@end
