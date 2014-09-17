//
//  NRGridView.h
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


#import <UIKit/UIKit.h>
#import "NRGridViewDataSource.h"
#import "NRGridViewDelegate.h"
#import "NRGridViewCell.h"


@interface NSIndexPath (NRGridViewIndexPath)
+ (NSIndexPath*)indexPathForItemIndex:(NSInteger)itemIndex
                            inSection:(NSInteger)section;
@property (readonly) NSInteger itemIndex;
@end

typedef enum{
    NRGridViewLayoutStyleVertical,
    NRGridViewLayoutStyleHorizontal
} NRGridViewLayoutStyle;

typedef enum{
    NRGridViewScrollPositionNone,   // Please refer to UITableViewScrollPositionNone's description.
    NRGridViewScrollPositionAtTop,
    NRGridViewScrollPositionAtLeft  = NRGridViewScrollPositionAtTop, // for horizontal layout convention
    NRGridViewScrollPositionAtMiddle,
    NRGridViewScrollPositionAtBottom,
    NRGridViewScrollPositionAtRight = NRGridViewScrollPositionAtBottom // for horizontal layout convention
} NRGridViewScrollPosition;


/** Possible options that can be combined together to determine when a pressured cell must but un-highlighted. 
 * (cf NRGridViewDelegate if you wish to support the long press gesture on any cell)
 */
typedef enum{
    NRGridViewLongPressUnhighlightUponPressGestureEnds = 0x01,              // Un-highlights the cell when the user's finger lefts the screen
    NRGridViewLongPressUnhighlightUponScroll           = 0x02,              // Un-highlights the cell when the user scrolls the gridView.
    NRGridViewLongPressUnhighlightUponAnotherTouch     = 0x04               // Un-highlights the cell when the user touches the same or another cell
} NRGridViewLongPressUnhighlightOptions;


static CGSize const kNRGridViewDefaultCellSize = {50, 70};

@interface NRGridView : UIScrollView
{
    @private
    NSMutableArray  *_sectionLayouts;
    NSMutableSet    *_reusableCellsSet;
    NSMutableSet    *_visibleCellsSet;
    NRGridViewCell  *_highlightedCell, *_longPressuredCell;
}

- (id)initWithLayoutStyle:(NRGridViewLayoutStyle)layoutStyle;
@property (nonatomic, assign) NRGridViewLayoutStyle layoutStyle;

@property (nonatomic, assign) id<NRGridViewDelegate> delegate;
@property (nonatomic, assign) id<NRGridViewDataSource> dataSource;

/** Determines the size of every cells passed into the gridView. Default value is kNRGridViewDefaultCellSize */
@property (nonatomic, assign) CGSize cellSize;

@property (nonatomic, readonly) NSArray     *visibleCells;
@property (nonatomic, readonly) NSArray     *indexPathsForVisibleCells;

- (void)reloadData;

- (NRGridViewCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier;
- (NRGridViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath; // returns nil if cell is not visible.

/** Handling (de)selection */
@property (nonatomic, retain)   NSIndexPath *selectedCellIndexPath;

- (void)selectCellAtIndexPath:(NSIndexPath*)indexPath 
                     animated:(BOOL)animated;
- (void)selectCellAtIndexPath:(NSIndexPath*)indexPath 
                   autoScroll:(BOOL)autoScroll
               scrollPosition:(NRGridViewScrollPosition)scrollPosition
                     animated:(BOOL)animated;

- (void)deselectCellAtIndexPath:(NSIndexPath*)indexPath 
                       animated:(BOOL)animated;


/** Getting rects, and scroll to specific section/indexPath */
- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForSection:(NSInteger)section;
- (CGRect)rectForItemAtIndexPath:(NSIndexPath*)indexPath;
- (CGRect)rectForFooterInSection:(NSInteger)section;

/** Scrolls to the given 'section' in the grid view. The scrollPosition determines which part of the section will be visible.
 * E.g.: using NRGridViewScrollPositionAtBottom/Right should display the end of the section. */
- (void)scrollRectToSection:(NSInteger)section 
                   animated:(BOOL)animated
             scrollPosition:(NRGridViewScrollPosition)scrollPosition;

- (void)scrollRectToItemAtIndexPath:(NSIndexPath*)indexPath 
                           animated:(BOOL)animated
                     scrollPosition:(NRGridViewScrollPosition)scrollPosition;


/** Long Pressure options (cf NRGridViewDelegate if you wish to support the long press gesture on any cell) 
 * Default value is (NRGridViewLongPressUnhighlightUponScroll|NRGridViewLongPressUnhighlightUponAnotherTouch)
 */
@property (nonatomic, assign) NRGridViewLongPressUnhighlightOptions longPressOptions; 

// You can either manually deselect the pressured cell like we do in our sample app.
- (void)unhighlightPressuredCellAnimated:(BOOL)animated;
- (NSIndexPath*)indexPathForLongPressuredCell;

@end
