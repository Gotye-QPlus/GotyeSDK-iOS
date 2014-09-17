//
//  NRGridView.m
//  Grid
//
//  Created by Louka Desroziers on 05/01/12.

/***********************************************************************************
 *
 * Copyright (c) 2012 Novedia Regions
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 ***********************************************************************************
 *
 * Referencing this project in your AboutBox is appreciated.
 * Please tell me if you use this class so we can cross-reference our projects.
 *
 ***********************************************************************************/

#import "NRGridView.h"
#import <objc/runtime.h>

@interface NRGridViewHeader : UIView
@property (nonatomic, readonly) UILabel *titleLabel;
@end
@implementation NRGridViewHeader
@synthesize titleLabel = _titleLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) [self setBackgroundColor:[UIColor clearColor]];
    return self;
}
- (UILabel*)titleLabel
{
    if(_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setTextAlignment:UITextAlignmentLeft];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:17.]];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setLineBreakMode:UILineBreakModeTailTruncation];
        [_titleLabel setShadowColor:[UIColor whiteColor]];
        [_titleLabel setShadowOffset:CGSizeMake(0, 1)];
        
        [self addSubview:_titleLabel];
    }
    
    return [[_titleLabel retain] autorelease];
}
static CGFloat const _kNRGridViewHeaderContentPadding = 10.;
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = [self bounds];
    CGRect titleLabelFrame = CGRectMake(_kNRGridViewHeaderContentPadding, 
                                        _kNRGridViewHeaderContentPadding, 
                                        CGRectGetWidth(bounds)-_kNRGridViewHeaderContentPadding*2, 
                                        CGRectGetHeight(bounds)-_kNRGridViewHeaderContentPadding*2);
    [[self titleLabel] setFrame:titleLabelFrame];
}

- (void)dealloc
{
    [_titleLabel release];
    [super dealloc];
}

@end
/** **/


/** **/
@interface NRGridViewSectionLayout : NSObject
@property (nonatomic, assign) NSInteger section, numberOfItems;
@property (nonatomic, assign) CGRect headerFrame, contentFrame, footerFrame;
@property (nonatomic, assign) NRGridViewLayoutStyle layoutStyle;
@property (nonatomic, retain) UIView *headerView, *footerView;
@property (nonatomic, readonly) CGRect sectionFrame;
@end
@implementation NRGridViewSectionLayout
@synthesize section,numberOfItems, headerFrame, contentFrame, footerFrame, layoutStyle;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;

@dynamic sectionFrame;
- (CGRect)sectionFrame
{
    return CGRectMake(CGRectGetMinX([self headerFrame]), 
                      CGRectGetMinY([self headerFrame]), 
                      (layoutStyle == NRGridViewLayoutStyleVertical
                       ? CGRectGetWidth([self contentFrame])
                       : CGRectGetWidth([self headerFrame])+CGRectGetWidth([self contentFrame])+CGRectGetWidth([self footerFrame])), 
                      (layoutStyle == NRGridViewLayoutStyleVertical
                       ? CGRectGetHeight([self headerFrame]) + CGRectGetHeight([self contentFrame])+CGRectGetHeight([self footerFrame])
                       : CGRectGetHeight([self contentFrame])));
}

- (void)setHeaderView:(UIView *)headerView
{
    if(_headerView != headerView)
    {
        [_headerView removeFromSuperview];
        [_headerView release];
        _headerView = [headerView retain];
    }
}

- (void)setFooterView:(UIView *)footerView
{
    if(_footerView != footerView)
    {
        [_footerView removeFromSuperview];
        [_footerView release];
        _footerView = [footerView retain];
    }
}


- (void)dealloc
{
    [self setHeaderView:nil];
    [self setFooterView:nil];

    [super dealloc];
}

@end
/** **/

static NSString* const _kNRGridViewCellIndexPathKey = @"_indexPath";
@interface NRGridViewCell (NRGridViewCellIndexPathExtension)
- (void)__setIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*)__indexPath;
@end
@implementation NRGridViewCell (NRGridViewCellIndexPathExtension)
- (void)__setIndexPath:(NSIndexPath*)indexPath
{
    objc_setAssociatedObject(self, 
                             &_kNRGridViewCellIndexPathKey, 
                             indexPath, 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSIndexPath*)__indexPath
{
    return objc_getAssociatedObject(self, &_kNRGridViewCellIndexPathKey);
}
@end

/** **/
@implementation NSIndexPath (NRGridViewIndexPath)
@dynamic itemIndex;
+ (NSIndexPath*)indexPathForItemIndex:(NSInteger)itemIndex
                            inSection:(NSInteger)section
{
    return [NSIndexPath indexPathForRow:itemIndex 
                              inSection:section];
}
- (NSInteger)itemIndex
{
    return [self row];
}

@end
/** **/



static CGFloat const _kNRGridViewDefaultHeaderHeight = 50.; // layout style = vertical
static CGFloat const _kNRGridViewDefaultHeaderWidth = 30.; // layout style = horizontal


@interface NRGridView (/*Private*/) <UIGestureRecognizerDelegate>
- (void)__commonInit;
- (void)__reloadContentSize;

- (NSInteger)__numberOfCellsPerColumnUsingSize:(CGSize)cellSize
                                   layoutStyle:(NRGridViewLayoutStyle)layoutStyle;
- (NSInteger)__numberOfCellsPerLineUsingSize:(CGSize)cellSize
                                   layoutStyle:(NRGridViewLayoutStyle)layoutStyle;

- (BOOL)__hasHeaderInSection:(NSInteger)sectionIndex;
- (CGFloat)__widthForHeaderAtSectionIndex:(NSInteger)sectionIndex
                         usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;
- (CGFloat)__heightForHeaderAtSectionIndex:(NSInteger)sectionIndex
                          usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;

- (CGFloat)__widthForContentInSection:(NSInteger)section
                          forCellSize:(CGSize)cellSize
                     usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;
- (CGFloat)__heightForContentInSection:(NSInteger)section
                           forCellSize:(CGSize)cellSize
                      usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;

- (BOOL)__hasFooterInSection:(NSInteger)sectionIndex;
- (CGFloat)__widthForFooterAtSectionIndex:(NSInteger)sectionIndex
                         usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;
- (CGFloat)__heightForFooterAtSectionIndex:(NSInteger)sectionIndex
                          usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;

- (NSArray*)__sectionsInRect:(CGRect)rect;
- (NRGridViewSectionLayout*)__sectionLayoutAtIndex:(NSInteger)section;

- (CGRect)__rectForHeaderInSection:(NSInteger)section
                  usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;
- (UIView*)__visibleHeaderForSection:(NSInteger)section; // returns a visible header that has already been created.
- (UIView*)__headerForSection:(NSInteger)section; // returns a visible header that has already been created, or creates a new one if applicable.


- (UIView*)__footerForSection:(NSInteger)section;

- (CGRect)__rectForCellAtIndexPath:(NSIndexPath*)indexPath 
                  usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;
- (void)__throwCellsInReusableQueue:(NSSet*)cellsSet;
- (void)__throwCellInReusableQueue:(NRGridViewCell*)cell;

- (void)__layoutCellsWithLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
              visibleCellsIndexPaths:(NSArray*)visibleCellsIndexPaths;


@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGestureRecognizer;

- (void)__handleTapGestureRecognition:(UIGestureRecognizer*)tapGestureRecognizer;
- (void)__handleLongPressGestureRecognizer:(UIGestureRecognizer*)tapGestureRecognizer;

@end

@implementation NRGridView
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize longPressGestureRecognizer = _longPressGestureRecognizer;

@synthesize layoutStyle = _layoutStyle;
@synthesize dataSource = _dataSource;
@synthesize delegate;
@synthesize cellSize = _cellSize;
@synthesize selectedCellIndexPath = _selectedCellIndexPath;
@synthesize longPressOptions = _longPressOptions;

@dynamic visibleCells, indexPathsForVisibleCells;

#pragma mark - Init

- (void)__commonInit
{
    _visibleCellsSet = [[NSMutableSet alloc] init];
    _reusableCellsSet = [[NSMutableSet alloc] init];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAlwaysBounceVertical:YES];
    [self setLayoutStyle:NRGridViewLayoutStyleVertical];
    [self setCellSize:kNRGridViewDefaultCellSize];
    [self setLongPressOptions:(NRGridViewLongPressUnhighlightUponScroll|NRGridViewLongPressUnhighlightUponAnotherTouch)];
    
    // Tap gesture recognizer
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                    action:@selector(__handleTapGestureRecognition:)];
    [_tapGestureRecognizer setNumberOfTapsRequired:1];
    [_tapGestureRecognizer setNumberOfTouchesRequired:1];
    [_tapGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:_tapGestureRecognizer];
}

- (id)initWithLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        [self __commonInit];
        [self setLayoutStyle:layoutStyle];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self __commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self __commonInit];
    }
    return self;
}

#pragma mark - Getters

- (NSArray*)visibleCells
{
    return [_visibleCellsSet allObjects];
}

- (NSArray*)indexPathsForVisibleCells
{
    return [[self visibleCells] valueForKeyPath:@"@unionOfObjects.indexPath"];
}

- (NRGridViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath
{
    NRGridViewCell *cell = nil;
    
    if(indexPath!=nil)
        for(NRGridViewCell* aCell in [self visibleCells])
            if([[aCell __indexPath] isEqual:indexPath]){
                cell = [aCell retain];
                break;
            }
    
    return [cell autorelease];
}

- (NSIndexPath*)indexPathForLongPressuredCell
{
    return [_longPressuredCell __indexPath];
}

#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self __reloadContentSize];
    [self setNeedsLayout];
}

- (void)setCellSize:(CGSize)cellSize
{
    if(CGSizeEqualToSize(_cellSize, cellSize) == NO)
    {
        [self willChangeValueForKey:@"cellSize"];
        _cellSize = cellSize;
        
        [self __reloadContentSize];
        [self setNeedsLayout];
        [self didChangeValueForKey:@"cellSize"];
    }
}

- (void)setSelectedCellIndexPath:(NSIndexPath *)selectedCellIndexPath
{
    [self selectCellAtIndexPath:selectedCellIndexPath animated:NO];
}

- (void)setLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    if(_layoutStyle != layoutStyle)
    {
        NSAssert((layoutStyle == NRGridViewLayoutStyleHorizontal || layoutStyle == NRGridViewLayoutStyleVertical),
                 @"%@: incorrect layout style", 
                 NSStringFromClass([self class]));
        
        [self willChangeValueForKey:@"layoutStyle"];
        _layoutStyle = layoutStyle;
        [self didChangeValueForKey:@"layoutStyle"];
        
        [self setAlwaysBounceVertical:(layoutStyle == NRGridViewLayoutStyleVertical)];
        [self setAlwaysBounceHorizontal:(layoutStyle == NRGridViewLayoutStyleHorizontal)];

        if([self dataSource])
            [self reloadData];
    }
}

- (void)setDelegate:(id<NRGridViewDelegate>)aDelegate
{
    if(delegate != aDelegate)
    {
        [self willChangeValueForKey:@"delegate"];
        [self removeGestureRecognizer:_longPressGestureRecognizer];
        [_longPressGestureRecognizer release], _longPressGestureRecognizer=nil;
        
        [super setDelegate:aDelegate];
        delegate = aDelegate;
        
        if([aDelegate respondsToSelector:@selector(gridView:didLongPressCellAtIndexPath:)])
        {
            _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__handleLongPressGestureRecognizer:)];
            [_longPressGestureRecognizer setDelegate:self];
            [_longPressGestureRecognizer setNumberOfTapsRequired:0];
            [_longPressGestureRecognizer setNumberOfTouchesRequired:1];
            
            [self addGestureRecognizer:_longPressGestureRecognizer];
        }
        [self didChangeValueForKey:@"delegate"];
    }
    
    
}

#pragma mark - Private Methods

- (NSInteger)__numberOfCellsPerColumnUsingSize:(CGSize)cellSize
                                   layoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    if(CGRectIsEmpty([self bounds]))
        return 1;
    return (layoutStyle == NRGridViewLayoutStyleHorizontal
            ? floor((CGRectGetHeight([self bounds]) - [self contentInset].top - [self contentInset].bottom)/cellSize.height)
            : NSIntegerMax);
}

- (NSInteger)__numberOfCellsPerLineUsingSize:(CGSize)cellSize
                                 layoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    if(CGRectIsEmpty([self bounds]))
       return 1;
    return (layoutStyle == NRGridViewLayoutStyleVertical
            ? floor((CGRectGetWidth([self bounds]) - [self contentInset].left - [self contentInset].right)/cellSize.width)
            : NSIntegerMax);
}



- (BOOL)__hasHeaderInSection:(NSInteger)sectionIndex
{
    return ( ([[self dataSource] respondsToSelector:@selector(gridView:titleForHeaderInSection:)] && [[self dataSource] gridView:self 
                                                                                                         titleForHeaderInSection:sectionIndex] !=nil)
            || ([[self dataSource] respondsToSelector:@selector(gridView:viewForHeaderInSection:)] && [[self dataSource] gridView:self 
                                                                                                           viewForHeaderInSection:sectionIndex] !=nil) );
}


- (CGFloat)__widthForHeaderAtSectionIndex:(NSInteger)sectionIndex
                         usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    if([self __hasHeaderInSection:sectionIndex] == NO)
        return 0.;
    
    // If layout is horizontal, we set the headerWidth to the default value '_kNRGridViewDefaultHeaderWidth'
    // Otherwise, the headerWidth is set to the width of the grid view
    CGFloat headerWidth = (layoutStyle == NRGridViewLayoutStyleHorizontal 
                           ? _kNRGridViewDefaultHeaderWidth
                           : CGRectGetWidth([self bounds]));
    
    if([self layoutStyle] == NRGridViewLayoutStyleHorizontal
       && [[self dataSource] respondsToSelector:@selector(gridView:widthForHeaderInSection:)])
        headerWidth = [[self dataSource] gridView:self 
                          widthForHeaderInSection:sectionIndex];
    
    return headerWidth;
}

- (CGFloat)__heightForHeaderAtSectionIndex:(NSInteger)sectionIndex
                          usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    if([self __hasHeaderInSection:sectionIndex] == NO)
        return 0.;
    
    // If layout is vertical, we set the headerHeight to the default value '_kNRGridViewDefaultHeaderHeight'
    // Otherwise, the headerHeight is set to the height of the grid view
    CGFloat headerHeight = (layoutStyle == NRGridViewLayoutStyleVertical 
                            ? _kNRGridViewDefaultHeaderHeight
                            : CGRectGetHeight([self bounds]));
    
    if([self layoutStyle] == NRGridViewLayoutStyleVertical
       && [[self dataSource] respondsToSelector:@selector(gridView:heightForHeaderInSection:)])
        headerHeight = [[self dataSource] gridView:self 
                          heightForHeaderInSection:sectionIndex];
    
    return headerHeight;
}



- (CGFloat)__widthForContentInSection:(NSInteger)section
                          forCellSize:(CGSize)cellSize
                     usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    return (layoutStyle == NRGridViewLayoutStyleHorizontal
            ? ceil((CGFloat)[[self dataSource] gridView:self 
                                 numberOfItemsInSection:section] / (CGFloat)[self __numberOfCellsPerColumnUsingSize:cellSize 
                                                                                                        layoutStyle:layoutStyle]) * cellSize.width
            : CGRectGetWidth([self bounds]));
}


- (CGFloat)__heightForContentInSection:(NSInteger)section
                           forCellSize:(CGSize)cellSize
                      usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    return (layoutStyle == NRGridViewLayoutStyleVertical
            ? ceil((CGFloat)[[self dataSource] gridView:self 
                                 numberOfItemsInSection:section] / (CGFloat)[self __numberOfCellsPerLineUsingSize:cellSize 
                                                                                                      layoutStyle:layoutStyle]) * cellSize.height 
            : CGRectGetHeight([self bounds]));
}


- (BOOL)__hasFooterInSection:(NSInteger)sectionIndex
{
    return ( ([[self dataSource] respondsToSelector:@selector(gridView:titleForFooterInSection:)] && [[self dataSource] gridView:self 
                                                                                                         titleForFooterInSection:sectionIndex] !=nil)
            || ([[self dataSource] respondsToSelector:@selector(gridView:viewForFooterInSection:)] && [[self dataSource] gridView:self 
                                                                                                           viewForFooterInSection:sectionIndex] !=nil) );
}

- (CGFloat)__widthForFooterAtSectionIndex:(NSInteger)sectionIndex
                         usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    if([self __hasFooterInSection:sectionIndex] == NO)
        return 0.;
    
    // If layout is horizontal, we set the headerWidth to the default value '_kNRGridViewDefaultHeaderWidth'
    // Otherwise, the headerWidth is set to the width of the grid view
    CGFloat footerWidth = (layoutStyle == NRGridViewLayoutStyleHorizontal 
                           ? _kNRGridViewDefaultHeaderWidth
                           : CGRectGetWidth([self bounds]));
    
    if([self layoutStyle] == NRGridViewLayoutStyleHorizontal
       && [[self dataSource] respondsToSelector:@selector(gridView:widthForFooterInSection:)])
        footerWidth = [[self dataSource] gridView:self 
                          widthForFooterInSection:sectionIndex];
    
    return footerWidth;
}

- (CGFloat)__heightForFooterAtSectionIndex:(NSInteger)sectionIndex
                          usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    if([self __hasFooterInSection:sectionIndex] == NO)
        return 0.;
    
    // If layout is vertical, we set the headerHeight to the default value '_kNRGridViewDefaultHeaderHeight'
    // Otherwise, the headerHeight is set to the height of the grid view
    CGFloat footerHeight = (layoutStyle == NRGridViewLayoutStyleVertical 
                            ? _kNRGridViewDefaultHeaderHeight
                            : CGRectGetHeight([self bounds]));
    
    if([self layoutStyle] == NRGridViewLayoutStyleVertical
       && [[self dataSource] respondsToSelector:@selector(gridView:heightForFooterInSection:)])
        footerHeight = [[self dataSource] gridView:self 
                          heightForFooterInSection:sectionIndex];
    
    return footerHeight;
}


#pragma mark - Visible Sections

- (CGRect)rectForSection:(NSInteger)section
{
    NRGridViewSectionLayout *sectionLayout = [self __sectionLayoutAtIndex:section];
    return [sectionLayout sectionFrame];
}

- (NSArray*)__sectionsInRect:(CGRect)rect
{
    NSMutableArray* sectionsInRect = [[NSMutableArray alloc] init];
    for(NRGridViewSectionLayout *sectionLayout in _sectionLayouts)
    {
        if(CGRectIntersectsRect([sectionLayout sectionFrame], rect))
            [sectionsInRect addObject:sectionLayout];
    }
    return [sectionsInRect autorelease];
}

- (NRGridViewSectionLayout*)__sectionLayoutAtIndex:(NSInteger)section
{
    return (NRGridViewSectionLayout*)[_sectionLayouts objectAtIndex:section];
}


#pragma mark - Section Headers

- (CGRect)rectForHeaderInSection:(NSInteger)section
{
    return [self __rectForHeaderInSection:section 
                         usingLayoutStyle:[self layoutStyle]];;
}

- (CGRect)__rectForHeaderInSection:(NSInteger)section
                  usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    NRGridViewSectionLayout *sectionLayout = [self __sectionLayoutAtIndex:section];
    CGRect sectionHeaderFrame =  [sectionLayout headerFrame];
    
    if(layoutStyle == NRGridViewLayoutStyleVertical){
        if(CGRectGetMinY(sectionHeaderFrame) < [self contentOffset].y)
            sectionHeaderFrame.origin.y = [self contentOffset].y;
        if(CGRectGetMaxY(sectionHeaderFrame) > CGRectGetMaxY([sectionLayout contentFrame]))
            sectionHeaderFrame.origin.y = CGRectGetMaxY([sectionLayout contentFrame]) - CGRectGetHeight(sectionHeaderFrame) ;
        
    }else if(layoutStyle == NRGridViewLayoutStyleHorizontal){
        if(CGRectGetMinX(sectionHeaderFrame) < [self contentOffset].x)
            sectionHeaderFrame.origin.x = [self contentOffset].x;
        if(CGRectGetMaxX(sectionHeaderFrame) > CGRectGetMaxX([sectionLayout contentFrame]))
            sectionHeaderFrame.origin.x = CGRectGetMaxX([sectionLayout contentFrame]) - CGRectGetWidth(sectionHeaderFrame) ;
        
    }
    
    return sectionHeaderFrame; 
}

- (UIView*)__visibleHeaderForSection:(NSInteger)section
{
    if([self __hasHeaderInSection:section] == NO)
        return nil;

    UIView *visibleHeader = nil;
    for(NRGridViewSectionLayout *sectionLayout in _sectionLayouts)
    {
        if([sectionLayout section] == section)
        {
            visibleHeader = [[sectionLayout headerView] retain];
            break;
        }
    }
    return [visibleHeader autorelease];
}

- (UIView*)__headerForSection:(NSInteger)section
{
    if([self __hasHeaderInSection:section] == NO)
        return nil;
    
    NRGridViewSectionLayout* sectionLayout = [self __sectionLayoutAtIndex:section];
    UIView *header = [[sectionLayout headerView] retain];
    
    if(header == nil){
        // header needs to be created...
        if([[self dataSource] respondsToSelector:@selector(gridView:viewForHeaderInSection:)])
        {
            header = [[[self dataSource] gridView:self 
                           viewForHeaderInSection:section] retain];
        }
        else if([[self dataSource] respondsToSelector:@selector(gridView:titleForHeaderInSection:)])
        {
            header = [[NRGridViewHeader alloc] initWithFrame:CGRectZero];
            [[(NRGridViewHeader*)header titleLabel] setText:[[self dataSource] gridView:self
                                                                titleForHeaderInSection:section]];
        }
        
        [sectionLayout setHeaderView:header];                    
    }
    
    return [header autorelease];
}



#pragma mark - Section Footers

- (CGRect)rectForFooterInSection:(NSInteger)section
{
    NRGridViewSectionLayout *sectionLayout = [self __sectionLayoutAtIndex:section];    
    return [sectionLayout footerFrame]; 
}


- (UIView*)__visibleFooterForSection:(NSInteger)section
{
    if([self __hasFooterInSection:section] == NO)
        return nil;
    
    UIView *visibleFooter = nil;
    for(NRGridViewSectionLayout *sectionLayout in _sectionLayouts)
    {
        if([sectionLayout section] == section)
        {
            visibleFooter = [[sectionLayout footerView] retain];
            break;
        }
    }
    return [visibleFooter autorelease];
}

- (UIView*)__footerForSection:(NSInteger)section
{
    if([self __hasFooterInSection:section] == NO)
        return nil;
    
    NRGridViewSectionLayout* sectionLayout = [self __sectionLayoutAtIndex:section];
    UIView *footer = [[sectionLayout footerView] retain];
    
    if(footer == nil){
        // header needs to be created...
        if([[self dataSource] respondsToSelector:@selector(gridView:viewForFooterInSection:)])
        {
            footer = [[[self dataSource] gridView:self 
                           viewForFooterInSection:section] retain];
        }
        else if([[self dataSource] respondsToSelector:@selector(gridView:titleForFooterInSection:)])
        {
            footer = [[NRGridViewHeader alloc] initWithFrame:CGRectZero];
            [[(NRGridViewHeader*)footer titleLabel] setText:[[self dataSource] gridView:self
                                                                titleForFooterInSection:section]];
        }
        
        [sectionLayout setFooterView:footer];                    
    }
    
    return [footer autorelease];
}


#pragma mark - Cells Stuff

- (CGRect)rectForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return [self __rectForCellAtIndexPath:indexPath
                         usingLayoutStyle:[self layoutStyle]];
}

- (CGRect)__rectForCellAtIndexPath:(NSIndexPath*)indexPath 
                  usingLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
{
    CGRect cellFrame = CGRectZero;
    cellFrame.size = [self cellSize];

    NRGridViewSectionLayout *sectionLayout = [self __sectionLayoutAtIndex:indexPath.section];
    
    if(layoutStyle == NRGridViewLayoutStyleVertical){
        NSInteger numberOfCellsPerLine = [self __numberOfCellsPerLineUsingSize:[self cellSize]
                                                                   layoutStyle:layoutStyle];
        
        if(numberOfCellsPerLine > 0)
        {
            CGFloat lineWidth = numberOfCellsPerLine*[self cellSize].width;
            
            NSInteger currentLine = (NSInteger)floor(indexPath.itemIndex/numberOfCellsPerLine);
            NSInteger currentColumn = (NSInteger)(indexPath.itemIndex - numberOfCellsPerLine*currentLine);
            
            cellFrame.origin.y = CGRectGetMinY([sectionLayout contentFrame]) + floor([self cellSize].height * currentLine);
            cellFrame.origin.x = floor([self cellSize].width * currentColumn) + floor(CGRectGetWidth([self bounds])/2. - lineWidth/2.);
        }
        
    }else if(layoutStyle == NRGridViewLayoutStyleHorizontal)
    {
        NSInteger numberOfCellsPerColumn = [self __numberOfCellsPerColumnUsingSize:[self cellSize]
                                                                       layoutStyle:layoutStyle];
        
        if(numberOfCellsPerColumn > 0)
        {
            CGFloat columnHeight = numberOfCellsPerColumn*[self cellSize].height;
            
            NSInteger currentColumn = (NSInteger)floor(indexPath.itemIndex/numberOfCellsPerColumn);
            NSInteger currentLine = (NSInteger)(indexPath.itemIndex - numberOfCellsPerColumn*currentColumn);
            
            cellFrame.origin.x = CGRectGetMinX([sectionLayout contentFrame]) + floor([self cellSize].width * currentColumn);
            cellFrame.origin.y = floor([self cellSize].height * currentLine) + floor(CGRectGetHeight([self bounds])/2. - columnHeight/2.);
        }
        
    }
    
    return cellFrame;
}


- (void)__throwCellsInReusableQueue:(NSSet*)cellsSet
{
    [cellsSet makeObjectsPerformSelector:@selector(__setIndexPath:) withObject:nil];
    [cellsSet makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [_reusableCellsSet unionSet:cellsSet];
    [_visibleCellsSet minusSet:cellsSet];
}
- (void)__throwCellInReusableQueue:(NRGridViewCell*)cell
{
    [cell __setIndexPath:nil];
    [cell removeFromSuperview];
    [_reusableCellsSet addObject:cell];
    [_visibleCellsSet removeObject:cell];
}


- (NRGridViewCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier
{
    NRGridViewCell* dequeuedCell = nil;
    
    if(identifier != nil){
        NSPredicate *dequeueablePredicate = [NSPredicate predicateWithFormat:@"reuseIdentifier isEqualToString: %@",identifier];
        NSSet *dequeuableSet = [_reusableCellsSet filteredSetUsingPredicate:dequeueablePredicate];
        
        dequeuedCell = [[dequeuableSet anyObject] retain];
        if(dequeuedCell != nil){
            [_reusableCellsSet removeObject:dequeuedCell];
            [dequeuedCell prepareForReuse];
        }
    }
        
    return [dequeuedCell autorelease];
}

#pragma mark - Scrolling

- (void)scrollRectToSection:(NSInteger)section 
                   animated:(BOOL)animated
             scrollPosition:(NRGridViewScrollPosition)scrollPosition
{
    CGRect sectionRect = [self rectForSection:section];
    CGPoint contentOffsetForSection = CGPointZero;
    
    if(scrollPosition == NRGridViewScrollPositionNone 
       && CGRectContainsRect([self bounds], sectionRect))
            return; // no scroll, as specified in NRGridViewScrollPositionNone's description.
    
    if([self layoutStyle] == NRGridViewLayoutStyleVertical)
    {
        if(scrollPosition == NRGridViewScrollPositionNone){
            if(CGRectGetMaxY(sectionRect) > CGRectGetMaxY([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtBottom;
            else if(CGRectGetMinY(sectionRect) < CGRectGetMinY([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtTop;
        }
        
        
        switch (scrollPosition) {
            case NRGridViewScrollPositionAtTop:
                contentOffsetForSection.y = CGRectGetMinY(sectionRect);
                break;
            case NRGridViewScrollPositionAtMiddle:
                contentOffsetForSection.y = floor(CGRectGetMidY(sectionRect) - CGRectGetHeight([self bounds])/2.);
                break;
            case NRGridViewScrollPositionAtBottom:
                contentOffsetForSection.y = CGRectGetMaxY(sectionRect) - CGRectGetHeight([self bounds]);
                break;
            default:
                break;
        }
        
        
        if(contentOffsetForSection.y<0)
            contentOffsetForSection.y = 0;
        else if(contentOffsetForSection.y> [self contentSize].height-CGRectGetHeight([self bounds]))
            contentOffsetForSection.y = [self contentSize].height - CGRectGetHeight([self bounds]);
        
    }else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal)
    {
        if(scrollPosition == NRGridViewScrollPositionNone){
            if(CGRectGetMaxX(sectionRect) > CGRectGetMaxX([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtRight;
            else if(CGRectGetMinX(sectionRect) < CGRectGetMinX([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtLeft;
        }
        
        
        switch (scrollPosition) {
            case NRGridViewScrollPositionAtLeft:
                contentOffsetForSection.x = CGRectGetMinX(sectionRect);
                break;
            case NRGridViewScrollPositionAtMiddle:
                contentOffsetForSection.x = floor(CGRectGetMidX(sectionRect) - CGRectGetWidth([self bounds])/2.);
                break;
            case NRGridViewScrollPositionAtRight:
                contentOffsetForSection.x = CGRectGetMaxX(sectionRect) - CGRectGetWidth([self bounds]);
                break;
            default:
                break;
        }
        
        if(contentOffsetForSection.x<0)
            contentOffsetForSection.x = 0;
        else if(contentOffsetForSection.x > [self contentSize].width - CGRectGetWidth([self bounds]))
            contentOffsetForSection.x = [self contentSize].width - CGRectGetWidth([self bounds]);
    }
      
    [self setContentOffset:contentOffsetForSection animated:animated];
}

- (void)scrollRectToItemAtIndexPath:(NSIndexPath*)indexPath 
                           animated:(BOOL)animated
                     scrollPosition:(NRGridViewScrollPosition)scrollPosition
{
    CGRect itemRect = [self rectForItemAtIndexPath:indexPath];
    CGPoint contentOffsetForItem = CGPointZero;
    
    if(scrollPosition == NRGridViewScrollPositionNone 
       && CGRectContainsRect([self bounds], itemRect))
        return; // no scroll, as specified in NRGridViewScrollPositionNone's description.
    
    if([self layoutStyle] == NRGridViewLayoutStyleVertical)
    {
        contentOffsetForItem.x = [self contentOffset].x;
        
        if(scrollPosition == NRGridViewScrollPositionNone){
            if(CGRectGetMaxY(itemRect) > CGRectGetMaxY([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtBottom;
            else if(CGRectGetMinY(itemRect) < CGRectGetMinY([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtTop;
        }
        
        
        switch (scrollPosition) {
            case NRGridViewScrollPositionAtTop:
                contentOffsetForItem.y = CGRectGetMinY(itemRect);
                break;
            case NRGridViewScrollPositionAtMiddle:
                contentOffsetForItem.y = floor(CGRectGetMidY(itemRect) - CGRectGetHeight([self bounds])/2.);
                break;
            case NRGridViewScrollPositionAtBottom:
                contentOffsetForItem.y = CGRectGetMinY(itemRect) - (CGRectGetHeight([self bounds]) - CGRectGetHeight(itemRect));
                break;
            default:
                break;
        }
        
        
        if(contentOffsetForItem.y<0)
            contentOffsetForItem.y = 0;
        else if(contentOffsetForItem.y > [self contentSize].height - CGRectGetHeight([self bounds]))
            contentOffsetForItem.y = [self contentSize].height - CGRectGetHeight([self bounds]);
        
    }else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal)
    {
        contentOffsetForItem.y = [self contentOffset].y;

        if(scrollPosition == NRGridViewScrollPositionNone){
            if(CGRectGetMaxX(itemRect) > CGRectGetMaxX([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtRight;
            else if(CGRectGetMinX(itemRect) < CGRectGetMinX([self bounds]))
                scrollPosition = NRGridViewScrollPositionAtLeft;
        }
        
        
        switch (scrollPosition) {
            case NRGridViewScrollPositionAtLeft:
                contentOffsetForItem.x = CGRectGetMinX(itemRect);
                break;
            case NRGridViewScrollPositionAtMiddle:
                contentOffsetForItem.x = floor(CGRectGetMidX(itemRect) - CGRectGetWidth([self bounds])/2.);
                break;
            case NRGridViewScrollPositionAtRight:
                contentOffsetForItem.x = CGRectGetMinX(itemRect) - (CGRectGetWidth([self bounds]) - CGRectGetWidth(itemRect));
                break;
            default:
                break;
        }
        
        if(contentOffsetForItem.x<0)
            contentOffsetForItem.x = 0;
        else if(contentOffsetForItem.x > [self contentSize].width - CGRectGetWidth([self bounds]))
            contentOffsetForItem.x = [self contentSize].width - CGRectGetWidth([self bounds]);
    }
    
    [self setContentOffset:contentOffsetForItem animated:animated];
}


#pragma mark - Reloading Content

- (void)__reloadContentSize
{        
    [_sectionLayouts release], _sectionLayouts=nil;
    _sectionLayouts = [[NSMutableArray alloc] init];
    
    CGSize contentSize = CGSizeZero;
    NSInteger numberOfSections  = ([[self dataSource] respondsToSelector:@selector(numberOfSectionsInGridView:)]
                                   ? [[self dataSource] numberOfSectionsInGridView:self]
                                   : 1);
    
    for(NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++)
    {        
        NSInteger numberOfCellsInSection = [[self dataSource] gridView:self 
                                                numberOfItemsInSection:sectionIndex];

        NRGridViewSectionLayout *sectionLayout = [[NRGridViewSectionLayout alloc] init];
        [sectionLayout setLayoutStyle:[self layoutStyle]];
        [sectionLayout setSection:sectionIndex];
        [sectionLayout setNumberOfItems:numberOfCellsInSection];
        
        
        CGSize sectionHeaderSize = CGSizeMake([self __widthForHeaderAtSectionIndex:sectionIndex 
                                                                  usingLayoutStyle:[self layoutStyle]], 
                                              [self __heightForHeaderAtSectionIndex:sectionIndex
                                                                   usingLayoutStyle:[self layoutStyle]]);
        CGSize sectionFooterSize = CGSizeMake([self __widthForFooterAtSectionIndex:sectionIndex 
                                                                  usingLayoutStyle:[self layoutStyle]], 
                                              [self __heightForFooterAtSectionIndex:sectionIndex
                                                                   usingLayoutStyle:[self layoutStyle]]);
        
        if([self layoutStyle] == NRGridViewLayoutStyleVertical)
        {
            CGFloat contentHeightInSection = [self __heightForContentInSection:sectionIndex 
                                                                   forCellSize:[self cellSize] 
                                                              usingLayoutStyle:[self layoutStyle]];
                        
            [sectionLayout setHeaderFrame:CGRectMake(0, 
                                                     contentSize.height, 
                                                     sectionHeaderSize.width, 
                                                     sectionHeaderSize.height)];
            [sectionLayout setContentFrame:CGRectMake(0, 
                                                      CGRectGetMaxY([sectionLayout headerFrame]), 
                                                      sectionHeaderSize.width, 
                                                      contentHeightInSection)];
            [sectionLayout setFooterFrame:CGRectMake(0, 
                                                     CGRectGetMaxY([sectionLayout contentFrame]), 
                                                     sectionFooterSize.width, 
                                                     sectionFooterSize.height)];

            
            contentSize.height += CGRectGetHeight([sectionLayout sectionFrame]);
            
        }else if([self layoutStyle] == NRGridViewLayoutStyleHorizontal)
        {
            CGFloat contentWidthInSection = [self __widthForContentInSection:sectionIndex 
                                                                 forCellSize:[self cellSize] 
                                                            usingLayoutStyle:[self layoutStyle]];
            
            [sectionLayout setHeaderFrame:CGRectMake(contentSize.width, 
                                                     0, 
                                                     sectionHeaderSize.width, 
                                                     sectionHeaderSize.height)];
            [sectionLayout setContentFrame:CGRectMake(CGRectGetMaxX([sectionLayout headerFrame]), 
                                                      0, 
                                                      contentWidthInSection, 
                                                      sectionHeaderSize.height)];
            [sectionLayout setFooterFrame:CGRectMake(CGRectGetMaxX([sectionLayout contentFrame]), 
                                                     0, 
                                                     sectionFooterSize.width, 
                                                     sectionFooterSize.height)];
            
            contentSize.width += CGRectGetWidth([sectionLayout sectionFrame]);
        }
        
        [_sectionLayouts addObject:sectionLayout];
        [sectionLayout release];
    }
 
    [self setContentSize:contentSize];
}

- (void)reloadData
{
    [self __reloadContentSize];
    
    [self __throwCellsInReusableQueue:_visibleCellsSet];
    [self setSelectedCellIndexPath:nil];
    
    [self setNeedsLayout];
}

#pragma mark - Layouting

- (void)setContentOffset:(CGPoint)offset
{
    [super setContentOffset:offset];
    if([self longPressOptions] & NRGridViewLongPressUnhighlightUponScroll)
    {
        [self unhighlightPressuredCellAnimated:YES];
    }
}

- (void)__layoutCellsWithLayoutStyle:(NRGridViewLayoutStyle)layoutStyle
              visibleCellsIndexPaths:(NSArray*)visibleCellsIndexPaths
{
    UIImageView *verticalScrollIndicator = nil, *horizontalScrollIndicator = nil;
    object_getInstanceVariable(self, "_verticalScrollIndicator", (void*)&verticalScrollIndicator);
    object_getInstanceVariable(self, "_horizontalScrollIndicator", (void*)&horizontalScrollIndicator);

    
    // better than calling -respondsToSelector: each time.
    BOOL informDelegateBeforeDisplayingCell = [[self delegate] respondsToSelector:@selector(gridView:willDisplayCell:atIndexPath:)]; 
   
    NSArray *visibleSections = [self __sectionsInRect:[self bounds]];
    
    // sections layout that won't be visible
    NSMutableSet *sectionLayoutsOffScreen = [[NSMutableSet alloc] initWithArray:_sectionLayouts];
    [sectionLayoutsOffScreen minusSet:[NSSet setWithArray:visibleSections]];
    [sectionLayoutsOffScreen makeObjectsPerformSelector:@selector(setHeaderView:) withObject:nil];
    [sectionLayoutsOffScreen release];
    /**/
    
    for(NRGridViewSectionLayout *sectionLayout in visibleSections)
    {
        NSInteger sectionIndex = [sectionLayout section];
        CGRect sectionContentFrame = [sectionLayout contentFrame];
        
        UIView *sectionHeaderView = [self __headerForSection:sectionIndex];
        [sectionHeaderView setFrame:[self __rectForHeaderInSection:sectionIndex 
                                                  usingLayoutStyle:layoutStyle]];
        if([sectionHeaderView superview] == nil)
            [self addSubview:sectionHeaderView];
        
        UIView *sectionFooterView = [self __footerForSection:sectionIndex];
        [sectionFooterView setFrame:[self rectForFooterInSection:sectionIndex]];
        if([sectionFooterView superview] == nil)
            [self addSubview:sectionFooterView];

        
        // enumerate all cells visible cells for sectionIndex.
        @autoreleasepool {
            
            NSInteger numberOfCellsInSection = [[self dataSource] gridView:self 
                                                    numberOfItemsInSection:sectionIndex];
            NSInteger firstVisibleCellIndex=0;
            NSInteger cellIndexesRange=0;
            
            if(layoutStyle == NRGridViewLayoutStyleVertical){
                NSInteger numberOfCellsPerLine = [self __numberOfCellsPerLineUsingSize:[self cellSize]
                                                                           layoutStyle:layoutStyle];
                
                NSInteger firstVisibleLineIndex = floor((CGRectGetMinY([self bounds])-CGRectGetMinY(sectionContentFrame)) / [self cellSize].height);
                if(firstVisibleLineIndex<0)
                    firstVisibleLineIndex = 0;
                
                NSInteger lastVisibleLineIndex = floor((CGRectGetMaxY([self bounds])-CGRectGetMinY(sectionContentFrame)) / [self cellSize].height);

                firstVisibleCellIndex = firstVisibleLineIndex * numberOfCellsPerLine;
                cellIndexesRange = ((lastVisibleLineIndex+1) * numberOfCellsPerLine) - firstVisibleCellIndex;
                
            }else if(layoutStyle == NRGridViewLayoutStyleHorizontal)
            {
                NSInteger numberOfCellsPerColumn = [self __numberOfCellsPerColumnUsingSize:[self cellSize]
                                                                               layoutStyle:layoutStyle];
                
                NSInteger firstVisibleColumnIndex = floor((CGRectGetMinX([self bounds])-CGRectGetMinX(sectionContentFrame)) / [self cellSize].width);
                if(firstVisibleColumnIndex<0)
                    firstVisibleColumnIndex = 0;
                
                NSInteger lastVisibleColumnIndex = floor((CGRectGetMaxX([self bounds])-CGRectGetMinX(sectionContentFrame)) / [self cellSize].width);
                
                firstVisibleCellIndex = firstVisibleColumnIndex * numberOfCellsPerColumn;
                cellIndexesRange = ((lastVisibleColumnIndex+1) * numberOfCellsPerColumn) - firstVisibleCellIndex;
            }
            
            if(firstVisibleCellIndex + cellIndexesRange > numberOfCellsInSection)
                cellIndexesRange = numberOfCellsInSection - firstVisibleCellIndex;
            if(cellIndexesRange <0)
                cellIndexesRange=0;            
            
            
            NSMutableIndexSet *sectionVisibleContentIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(firstVisibleCellIndex, cellIndexesRange)];
            
            if([visibleCellsIndexPaths count]>0){
                NSArray* visibleIndexPathsForSection = [visibleCellsIndexPaths filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"section == %i",sectionIndex]];
                if([visibleIndexPathsForSection count]>0){
                    NSArray* visibleIndexesForSection = [visibleIndexPathsForSection valueForKeyPath:@"@unionOfObjects.row"];
                    NSInteger minVisibleIndexForSection = [[visibleIndexesForSection valueForKeyPath:@"@min.integerValue"] integerValue];                        
                    [sectionVisibleContentIndexes removeIndexesInRange:NSMakeRange(minVisibleIndexForSection, [visibleIndexesForSection count])];
                }
            }
            
            [sectionVisibleContentIndexes enumerateIndexesUsingBlock:^(NSUInteger cellIndexInSection, BOOL *stop)
             {
                 NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItemIndex:cellIndexInSection 
                                                                       inSection:sectionIndex];                         
                 // insert cell.
                 NRGridViewCell *cell = [[self dataSource] gridView:self 
                                             cellForItemAtIndexPath:cellIndexPath];
                 [cell __setIndexPath:cellIndexPath];
                 [cell setFrame:[self __rectForCellAtIndexPath:cellIndexPath 
                                              usingLayoutStyle:layoutStyle]];                         
                 if([self selectedCellIndexPath])
                     [cell setSelected:[cellIndexPath isEqual:[self selectedCellIndexPath]]];
                 
                 if(informDelegateBeforeDisplayingCell)
                     [[self delegate] gridView:self 
                               willDisplayCell:cell 
                                   atIndexPath:cellIndexPath];
                 
//                 [self insertSubview:cell atIndex:0];
                 [self addSubview:cell];
                 [_visibleCellsSet addObject:cell];
             }];
            
            
        }
    }
    
    [self bringSubviewToFront:verticalScrollIndicator];
    [self bringSubviewToFront:horizontalScrollIndicator];
}   

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(CGRectIsEmpty([self bounds]))
        return;
    
    [_highlightedCell setHighlighted:NO animated:NO];
    [_highlightedCell release], _highlightedCell=nil;

    NSMutableArray *visibleCellsIndexPaths = [[NSMutableArray alloc] init];
    NSSet *visibleCellsSetCopy = [_visibleCellsSet copy];
    for(NRGridViewCell* visibleCell in visibleCellsSetCopy)
    {
        [visibleCell setFrame:[self __rectForCellAtIndexPath:[visibleCell __indexPath] 
                                            usingLayoutStyle:[self layoutStyle]]];
        
        if(CGRectIntersectsRect([visibleCell frame], [self bounds]) == NO)
        {
            [self __throwCellInReusableQueue:visibleCell];
        }else{
            [visibleCellsIndexPaths addObject:[visibleCell __indexPath]]; // gather the index path of the enumerated cell if it's still visible on screen.
        }
    }
    [visibleCellsSetCopy release];
    
    
    [self __layoutCellsWithLayoutStyle:[self layoutStyle]
                visibleCellsIndexPaths:visibleCellsIndexPaths];
    
    [visibleCellsIndexPaths release];
    
}


#pragma mark - Handling Highlight/(De)Selection


- (void)selectCellAtIndexPath:(NSIndexPath*)indexPath 
                   autoScroll:(BOOL)autoScroll 
               scrollPosition:(NRGridViewScrollPosition)scrollPosition
                     animated:(BOOL)animated
{
    if(_selectedCellIndexPath != indexPath)
    {
        [self deselectCellAtIndexPath:_selectedCellIndexPath 
                             animated:animated];
        
        // no release needed because -deselectCellAtIndexPath:_selectedCellIndexPath does it for us.
        _selectedCellIndexPath = [indexPath retain];
        
        [[self cellAtIndexPath:indexPath] setSelected:YES animated:animated];
    }
    
    if(autoScroll && indexPath)
    {
        [self scrollRectToItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    }
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    [self selectCellAtIndexPath:indexPath autoScroll:NO scrollPosition:NRGridViewScrollPositionNone animated:animated];
}


- (void)deselectCellAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated
{
    [[self cellAtIndexPath:indexPath] setSelected:NO animated:animated];

    if([_selectedCellIndexPath isEqual:indexPath])
    {
        [_selectedCellIndexPath release];
        _selectedCellIndexPath = nil;
    }
}

- (void)unhighlightPressuredCellAnimated:(BOOL)animated
{
    [_longPressuredCell setHighlighted:NO animated:animated];
    [_longPressuredCell release], _longPressuredCell=nil;
}

#pragma mark -

- (void)__handleTapGestureRecognition:(UIGestureRecognizer*)tapGestureRecognizer
{
    if(tapGestureRecognizer == _tapGestureRecognizer)
    {
        [self deselectCellAtIndexPath:_selectedCellIndexPath animated:YES];
        
        CGPoint touchLocation = [tapGestureRecognizer locationInView:self];
        
        if([[self delegate] respondsToSelector:@selector(gridView:didSelectHeaderForSection:)]){
            for(NRGridViewSectionLayout* aSectionLayout in _sectionLayouts)
            {
                if([aSectionLayout headerView] 
                   && CGRectContainsPoint([[aSectionLayout headerView] frame], touchLocation))
                {
                    [[self delegate] gridView:self didSelectHeaderForSection:[aSectionLayout section]];
                    return;
                }
            }
        }
        
        
        for(NRGridViewCell *aCell in _visibleCellsSet)
        {
            if(CGRectContainsPoint([aCell frame], 
                                   touchLocation))
            {
                if([[self delegate] respondsToSelector:@selector(gridView:willSelectCellAtIndexPath:)])
                    [[self delegate] gridView:self willSelectCellAtIndexPath:[aCell __indexPath]];

                [self selectCellAtIndexPath:[aCell __indexPath] animated:YES];
                
                if([[self delegate] respondsToSelector:@selector(gridView:didSelectCellAtIndexPath:)])
                    [[self delegate] gridView:self didSelectCellAtIndexPath:[aCell __indexPath]];
                
                break;
            }
        }
    }
}

- (void)__handleLongPressGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    if(gestureRecognizer == _longPressGestureRecognizer)
    {
        if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            CGPoint touchLocation = [gestureRecognizer locationInView:self];
            
            for(NRGridViewCell *aCell in _visibleCellsSet)
            {
                if(CGRectContainsPoint([aCell frame], 
                                       touchLocation))
                {
                    if(_longPressuredCell != aCell)
                    {
                        [self unhighlightPressuredCellAnimated:YES];
                        
                        _longPressuredCell = [aCell retain];
                        [_longPressuredCell setHighlighted:YES animated:YES];
                    }

                    [[self delegate] gridView:self didLongPressCellAtIndexPath:[aCell __indexPath]];
                    
                    break;
                }
            }
        }
        else if(([gestureRecognizer state] == UIGestureRecognizerStateEnded 
                 && ([self longPressOptions] & NRGridViewLongPressUnhighlightUponPressGestureEnds))
                || [gestureRecognizer state] == UIGestureRecognizerStateCancelled)
        {
            [self unhighlightPressuredCellAnimated:YES];
        }

    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if([touches count] == 1)
    {
        UITouch* touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        
        [_highlightedCell setHighlighted:NO animated:YES];
        [_highlightedCell release], _highlightedCell=nil;
        
        if([self longPressOptions] & NRGridViewLongPressUnhighlightUponAnotherTouch)
        {
            [self unhighlightPressuredCellAnimated:YES];
        }
        
        for(NRGridViewCell *aCell in _visibleCellsSet)
        {
            if(CGRectContainsPoint([aCell frame], 
                                   touchLocation))
            {
                [aCell setHighlighted:YES animated:YES];
                _highlightedCell = [aCell retain];                
                break;
            }
        }
    }
     
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_highlightedCell setHighlighted:(_longPressuredCell==_highlightedCell) animated:YES];
    [_highlightedCell release], _highlightedCell=nil;
    [super touchesCancelled:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_highlightedCell setHighlighted:(_longPressuredCell==_highlightedCell) animated:YES];
    [_highlightedCell release], _highlightedCell=nil;
    [super touchesEnded:touches withEvent:event];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([[touch view] isKindOfClass:[UIButton class]] 
       && (gestureRecognizer == _longPressGestureRecognizer || gestureRecognizer == _tapGestureRecognizer))
        return NO;
    return YES;
}


#pragma mark - Memory

- (void)dealloc
{
    [_longPressuredCell release];
    [_longPressGestureRecognizer release];
    [_sectionLayouts release];
    [_highlightedCell release];
    [_tapGestureRecognizer release];
    [_reusableCellsSet release];
    [_visibleCellsSet release];
    [_selectedCellIndexPath release];
    [super dealloc];
}

@end
