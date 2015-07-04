//
//  GMDataSourceProtocol.h
//  GMBookShelf
//
//  Created by Giuseppe Morana on 04/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMBook.h"

@protocol GMDataSourceProtocol <NSObject>

@required

/**
 * Called when GMDataSource has new fresh info about the book (i.e. details)
 */
- (void)didUpdateBook:(GMBook *)book;

/**
 * Called when GMDataSource has fetched new items
 */
- (void)didFetchBookList:(NSArray *)bookList;

/**
 * Called if some kind of error occurs
 */
- (void)didFailWithError:(NSError *)error;

@end
