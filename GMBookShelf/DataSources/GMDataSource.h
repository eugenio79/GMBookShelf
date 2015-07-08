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

- (NSInteger)booksCount;

- (GMBook *)bookAtIndex:(NSInteger)index;

@end
