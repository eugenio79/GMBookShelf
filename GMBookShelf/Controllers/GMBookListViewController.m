//
//  ViewController.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 03/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMBookListViewController.h"
#import "GMHttpClient.h"
#import "GMCell.h"
#import "GMBookDetailViewController.h"

#define GM_PAGE_SIZE 20

static NSString * const BaseURLString = @"http://assignment.gae.golgek.mobi/api/v1/";

@interface GMBookListViewController () {
    GMHttpClient *_httpClient;
    NSMutableArray *_booksInCache;
    NSInteger _currentOffset;
    GMBook *_selectedBook;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation GMBookListViewController

#pragma mark - controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 88.0f;
    
    _booksInCache = [[NSMutableArray alloc] init];
    
    _httpClient = [GMHttpClient sharedInstance];
    
    [_httpClient requestBookListWithOffset:_currentOffset withCount:GM_PAGE_SIZE withSuccessBlock:^(NSArray *bookList) {
        
        [_booksInCache addObjectsFromArray:bookList];
        [self.tableView reloadData];
        
        _currentOffset += GM_PAGE_SIZE;
        
    } failure:^(NSError *error) {
        
        [self _showErrorWithMessage:[error localizedDescription]];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"bookDetailSegue"]) {
        GMBookDetailViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.book = _selectedBook;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _booksInCache.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"GMCell";
    
    GMBook *currentBook = _booksInCache[indexPath.row];
    
    GMCell *cell = (GMCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.book = currentBook;
    
    if (![currentBook hasDetails]) {
        
        [_httpClient requestDetailsForBookWithId:currentBook.ID withSuccessBlock:^(GMBook *bookWithDetails) {
            
            _booksInCache[indexPath.row] = bookWithDetails;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            if (bookWithDetails.image == nil) {
                
                [_httpClient requestImageForBook:bookWithDetails withSuccessBlock:^(UIImage *image) {
                    
                    GMBook *book = _booksInCache[indexPath.row];
                    book.image = image;
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                } failure:^(NSError *error) {
                    
                    NSLog(@"error while trying to fetch image: %@", bookWithDetails.imageUrlString);
                }];
            }
            
        } failure:^(NSError *error) {
            
            [self _showErrorWithMessage:[error localizedDescription]];
        }];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 88.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedBook = _booksInCache[indexPath.row];
    [self performSegueWithIdentifier:@"bookDetailSegue" sender:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat actualPosition = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height - (self.tableView.bounds.size.height);
    if (actualPosition >= contentHeight) {
        
        [_httpClient requestBookListWithOffset:_currentOffset withCount:GM_PAGE_SIZE withSuccessBlock:^(NSArray *bookList) {
            
            [_booksInCache addObjectsFromArray:bookList];
            [self.tableView reloadData];
            
            _currentOffset += GM_PAGE_SIZE;
            
        } failure:^(NSError *error) {
            
            if (error.code != GMHttpClientErrorRequestInProgress) {
                [self _showErrorWithMessage:[error localizedDescription]];
            }
        }];
    }}

#pragma mark - utility methods

- (void)_showErrorWithMessage:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
