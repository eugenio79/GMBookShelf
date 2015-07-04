//
//  EUBook.m
//  EUBookShelf
//
//  Created by Giuseppe Morana on 03/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMBook.h"

@implementation GMBook

+ (GMBook *)bookWithDictionary:(NSDictionary *)dict {
    return [[GMBook alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    NSAssert(dict != nil, @"dict can't be nil!");
    
    if (self = [super init]) {
        
        self.ID = [dict objectForKey:@"id"];
        self.title = [dict objectForKey:@"title"];
        self.link = [dict objectForKey:@"link"];
        self.author = [dict objectForKey:@"author"];    // detail
        self.price = [dict objectForKey:@"price"];    // detail
        self.imageUrlString = [dict objectForKey:@"image"];    // detail
    }
    return self;
}

- (BOOL)hasDetails {
    return self.author != nil;  // if author is not nil I consider I've already asked WS for details
}

@end
