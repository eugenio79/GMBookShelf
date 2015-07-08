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
#import "GMActivityIndicatorView.h"

#define GM_PAGE_SIZE 20
#define GM_FOOTER_HEIGHT 50

static NSString * const BaseURLString = @"http://assignment.gae.golgek.mobi/api/v1/";

@interface GMBookListViewController () <UIGestureRecognizerDelegate> {
    GMHttpClient *_httpClient;
    NSMutableArray *_booksInCache;
    NSInteger _currentOffset;
    GMBook *_selectedBook;
    GMActivityIndicatorView *_actInd;
    BOOL _loading;
    BOOL _lastItemReached;                      // it'll become YES when the HTTP client'll answer with an empty array
    UITapGestureRecognizer *_tapBehindGesture;  // used when detail is presented modally (iPad)
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@end

@implementation GMBookListViewController

#pragma mark - controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.flowLayout.footerReferenceSize = CGSizeMake(0, GM_FOOTER_HEIGHT);
    
    _booksInCache = [[NSMutableArray alloc] init];
    
    _httpClient = [GMHttpClient sharedInstance];
    
    [_httpClient requestBookListWithOffset:_currentOffset withCount:GM_PAGE_SIZE withSuccessBlock:^(NSArray *bookList) {
        
        [self _hideActInd];
        [_booksInCache addObjectsFromArray:bookList];
        [self.collectionView reloadData];
        
        _currentOffset += GM_PAGE_SIZE;
        
    } failure:^(NSError *error) {
        
        [self _hideActInd];
        [self _showErrorWithMessage:[error localizedDescription]];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([_booksInCache count] == 0)
        [self _showActInd];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"pushSegue"] ||
        [[segue identifier] isEqualToString:@"modalSegue"]) {
        
        GMBookDetailViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.book = _selectedBook;
        
        [self _addTapBehindGesture];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [self.flowLayout invalidateLayout];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _booksInCache.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"GMCell";
    
    NSInteger index = indexPath.row * (indexPath.section + 1);
    
    GMBook *currentBook = _booksInCache[index];
    
    GMCell *cell = (GMCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.book = currentBook;
    
    if (![currentBook hasDetails]) {
        
        [_httpClient requestDetailsForBookWithId:currentBook.ID withSuccessBlock:^(GMBook *bookWithDetails) {
            
            _booksInCache[indexPath.row] = bookWithDetails;
            
            if (bookWithDetails.image == nil) {
                
                [_httpClient requestImageForBook:bookWithDetails withSuccessBlock:^(UIImage *image) {
                    
                    GMBook *book = _booksInCache[indexPath.row];
                    book.image = image;
                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    
                } failure:^(NSError *error) {
                    
                    NSLog(@"error while trying to fetch image at url: %@", bookWithDetails.imageUrlString);
                }];
            }
            
        } failure:^(NSError *error) {
            
            [self _showErrorWithMessage:[error localizedDescription]];
        }];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self _cellSize];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedBook = _booksInCache[indexPath.row];
    
    NSString *segue = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"pushSegue": @"modalSegue";
    
    [self performSegueWithIdentifier:segue sender:self];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    
     if (kind == UICollectionElementKindSectionFooter) {
        
        UICollectionReusableView *footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GMFooter" forIndexPath:indexPath];
        
        reusableview = footerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if (_booksInCache.count == 0) return CGSizeZero;
    
    return CGSizeZero;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_lastItemReached) return;
    
    CGFloat actualPosition = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height - (self.collectionView.bounds.size.height);
    if (actualPosition >= contentHeight) {
        
        if (_loading) return;
        
        _loading = YES;
        
        [_httpClient requestBookListWithOffset:_currentOffset withCount:GM_PAGE_SIZE withSuccessBlock:^(NSArray *bookList) {
            
            if (bookList.count == 0) {
                _lastItemReached = YES;
            }
            else {
                [_booksInCache addObjectsFromArray:bookList];
                [self.collectionView reloadData];
                
                _currentOffset += GM_PAGE_SIZE;
            }
            
            _loading = NO;
            
        } failure:^(NSError *error) {
            
            [self _showErrorWithMessage:[error localizedDescription]];
            
            _loading = NO;
        }];
    }
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - utility methods

- (void)_showErrorWithMessage:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (CGSize)_cellSize {
    
    CGFloat cellWidth;
    
    if (self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        
        // Compact (e.g. iPhone) - single column
        cellWidth = self.collectionView.frame.size.width;
        
    } else {
        
        // Regular (e.g. iPad) - double columns
        cellWidth = (self.collectionView.frame.size.width - self.flowLayout.minimumInteritemSpacing
                     ) / 2;
    }
    
    return CGSizeMake(cellWidth, 88.0f);
}

- (void)_addTapBehindGesture {
    
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone) return;
    
    if (_tapBehindGesture == nil) {
        _tapBehindGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapBehindDetected:)];
        [_tapBehindGesture setNumberOfTapsRequired:1];
        [_tapBehindGesture setCancelsTouchesInView:NO]; //So the user can still interact with controls in the modal view
        [_tapBehindGesture setDelegate:self];
    }
    [self.view.window addGestureRecognizer:_tapBehindGesture];
}

- (void)_removeTapBehindGesture {
    
    [self.view.window removeGestureRecognizer:_tapBehindGesture];
}

- (void)_showActInd {
    if (_actInd == nil) {
        _actInd = [GMActivityIndicatorView createIndicatorForView:self.navigationController.view];
    }
    [_actInd show];
}

- (void)_hideActInd {
    if (_actInd != nil) {
        [_actInd hide];
        _actInd = nil;
    }
}

// http://stackoverflow.com/questions/9102497/dismiss-modal-view-form-sheet-controller-on-outside-tap
// http://stackoverflow.com/questions/25638409/dismiss-modal-form-sheet-view-on-outside-tap-ios-8/25844208#25844208
- (void)_tapBehindDetected:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        UIView *rootView = self.view.window.rootViewController.view;
        CGPoint location = [sender locationInView:rootView];
        if (![self.presentedViewController.view pointInside:[self.presentedViewController.view convertPoint:location fromView:rootView] withEvent:nil]) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self _removeTapBehindGesture];
            }];
        }
    }
}

@end
