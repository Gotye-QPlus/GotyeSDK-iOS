//
//  NRGridViewDataSource.h
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

#import <Foundation/Foundation.h>

@class NRGridView, NRGridViewCell;
@protocol NRGridViewDataSource <NSObject>

- (NSInteger)gridView:(NRGridView*)gridView numberOfItemsInSection:(NSInteger)section;
- (NRGridViewCell*)gridView:(NRGridView*)gridView cellForItemAtIndexPath:(NSIndexPath*)indexPath;


@optional

- (NSInteger)numberOfSectionsInGridView:(NRGridView*)gridView; // no implementation = 1 section

- (NSString*)gridView:(NRGridView*)gridView titleForHeaderInSection:(NSInteger)section;
- (UIView*)gridView:(NRGridView*)gridView viewForHeaderInSection:(NSInteger)section;
/** If implemented, this method is called if the layout style of the grid view is vertical */
- (CGFloat)gridView:(NRGridView*)gridView heightForHeaderInSection:(NSInteger)section;
/** If implemented, this method is called if the layout style of the grid view is horizontal */
- (CGFloat)gridView:(NRGridView*)gridView widthForHeaderInSection:(NSInteger)section;


- (NSString*)gridView:(NRGridView*)gridView titleForFooterInSection:(NSInteger)section;
- (UIView*)gridView:(NRGridView*)gridView viewForFooterInSection:(NSInteger)section;
/** If implemented, this method is called if the layout style of the grid view is vertical */
- (CGFloat)gridView:(NRGridView*)gridView heightForFooterInSection:(NSInteger)section;
/** If implemented, this method is called if the layout style of the grid view is horizontal */
- (CGFloat)gridView:(NRGridView*)gridView widthForFooterInSection:(NSInteger)section;


@end
