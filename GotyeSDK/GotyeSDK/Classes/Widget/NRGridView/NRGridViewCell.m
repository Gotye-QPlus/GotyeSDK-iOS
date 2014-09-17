//
//  NRGridViewCell.m
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

#import "NRGridViewCell.h"
#import "NRGridConstants.h"

@interface NRGridViewCellSelectionBackgroundView : UIView
@end
@implementation NRGridViewCellSelectionBackgroundView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self)
        [self setBackgroundColor:[UIColor clearColor]];
    return self;
}
- (void)drawRect:(CGRect)rect
{    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat cornerRadius = 6.;
    CGContextSaveGState(ctx);
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:[self bounds] 
                                                           cornerRadius:cornerRadius];
    CGContextAddPath(ctx, [roundedPath CGPath]);
    CGContextRestoreGState(ctx);

    CGContextClip(ctx);

    CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();

    CGFloat locations[2] = {0.0, 1.0};
    CGColorRef top, bottom;
    top = [[UIColor colorWithRed:157./255. green:181./255. blue:205./255. alpha:1.] CGColor];
    bottom = [[UIColor colorWithRed:113./255. green:139./255. blue:179./255. alpha:1.] CGColor];
    
    CGFloat components[8] = {CGColorGetComponents(top)[0],CGColorGetComponents(top)[1],CGColorGetComponents(top)[2],CGColorGetComponents(top)[3] 
        ,CGColorGetComponents(bottom)[0],CGColorGetComponents(bottom)[1],CGColorGetComponents(bottom)[2],CGColorGetComponents(bottom)[3]};
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(spaceRef, components, locations, (size_t)2);
    CGContextDrawLinearGradient(ctx, gradient, [self bounds].origin, CGPointMake(CGRectGetMinX([self bounds]), CGRectGetMaxY([self bounds])), (CGGradientDrawingOptions)NULL);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(spaceRef);
    
    CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:149./255. green:175./255. blue:194./255. 
                                                         alpha:1.] CGColor]);
    CGContextFillRect(ctx, CGRectMake(CGRectGetMinX([self bounds])-cornerRadius/2., 
                                      CGRectGetMinY([self bounds]), 
                                      CGRectGetWidth([self bounds])-cornerRadius/2.,
                                      1.));

}

@end

@interface NRGridViewCell()
- (void)__commonInit;

@property (nonatomic, readonly) BOOL needsRelayout;

@end

@implementation NRGridViewCell
@dynamic needsRelayout;

@synthesize reuseIdentifier = _reuseIdentifier;

@synthesize contentView = _contentView;

@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel, detailedTextLabel = _detailedTextLabel;

@synthesize selectionBackgroundView = _selectionBackgroundView;
@synthesize backgroundView = _backgroundView;

@synthesize selected = _selected, highlighted = _highlighted;

- (void)__commonInit 
{
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_contentView];
    [self setSelectionBackgroundView:[[[NRGridViewCellSelectionBackgroundView alloc] init] autorelease]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        NSAssert(NO, 
                 @"%@: can't be instanciated using -initWithFrame. Please use -initWithReusableIdentifier", 
                 NSStringFromClass([self class]));
        
    }
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        NSAssert(reuseIdentifier != nil, 
                 @"%@: reusableIdentifier cannot be nil", 
                 NSStringFromClass([self class]));
        
        [self __commonInit];
        _reuseIdentifier = [reuseIdentifier copy];
    }
    return self;
}

#pragma mark -

- (void)prepareForReuse
{
    [self setSelected:NO];
    [self setHighlighted:NO];
}


#pragma mark - Getters

- (BOOL)needsRelayout
{
    return ([self superview] != nil);
}

- (UIImageView*)imageView
{
    if(_imageView == nil)
    {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setClipsToBounds:YES];
        
        [[self contentView] addSubview:_imageView];
    }
    return [[_imageView retain] autorelease];
}

- (UILabel*)textLabel
{
    if(_textLabel == nil)
    {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_textLabel setBackgroundColor:[UIColor clearColor]];
        [_textLabel setTextColor:[UIColor blackColor]];
        [_textLabel setHighlightedTextColor:[UIColor whiteColor]];
        [_textLabel setNumberOfLines:0];
        [_textLabel setLineBreakMode:UILineBreakModeTailTruncation];
        [_textLabel setAdjustsFontSizeToFitWidth:YES];
        [_textLabel setTextAlignment:UITextAlignmentLeft];
        
        [[self contentView] addSubview:_textLabel];
    }
    return [[_textLabel retain] autorelease];
}

- (UILabel*)detailedTextLabel
{
    if(_detailedTextLabel == nil)
    {
        _detailedTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_detailedTextLabel setBackgroundColor:[UIColor clearColor]];
        [_detailedTextLabel setTextColor:[UIColor blackColor]];
        [_detailedTextLabel setHighlightedTextColor:[UIColor whiteColor]];
        [_detailedTextLabel setNumberOfLines:0];
        [_detailedTextLabel setLineBreakMode:UILineBreakModeTailTruncation];
        [_detailedTextLabel setAdjustsFontSizeToFitWidth:YES];
        [_detailedTextLabel setTextAlignment:UITextAlignmentLeft];
        
        [[self contentView] addSubview:_detailedTextLabel];
    }
    return [[_detailedTextLabel retain] autorelease];
}

#pragma mark - Setters

- (void)setBackgroundView:(UIView *)backgroundView
{
    if(_backgroundView != backgroundView)
    {
        [_backgroundView removeFromSuperview];
        [_backgroundView release];
        _backgroundView = [backgroundView retain];
        
        if(backgroundView)
        {
            [self insertSubview:backgroundView atIndex:0];
            if([self needsRelayout])
                [self setNeedsLayout];
        }
    }
}

- (void)setSelectionBackgroundView:(UIView *)selectionBackgroundView
{
    if(_selectionBackgroundView != selectionBackgroundView)
    {
        [_selectionBackgroundView removeFromSuperview];
        _selectionBackgroundView = [selectionBackgroundView retain];

        [selectionBackgroundView setAlpha:(CGFloat)([self isSelected] || [self isHighlighted])];

        if(selectionBackgroundView)
        {
            if([self backgroundView])
                [self insertSubview:selectionBackgroundView aboveSubview:[self backgroundView]];
            else
                [self insertSubview:selectionBackgroundView atIndex:0];
                
            if([self needsRelayout])
                [self setNeedsLayout];
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if(_selected != selected)
    {
        _selected = selected;
        
        void (^selectionBlock)() = ^{
            // use Ivars directly to avoid instanciating them using getters... maybe you won't use textLabel or detailedTextLabel.. right?
            [_textLabel setHighlighted:([self isHighlighted] || selected)];
            [_detailedTextLabel setHighlighted:([self isHighlighted] || selected)];

            [[self selectionBackgroundView] setAlpha:([self isHighlighted] || selected)];
        };
        
        if(animated)
        {
            [UIView animateWithDuration:_kNRGridDefaultAnimationDuration 
                             animations:^{
                                 selectionBlock();
                             }];
        }else{
            selectionBlock();
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [self setHighlighted:highlighted animated:NO];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if(_highlighted != highlighted)
    {
        _highlighted = highlighted;
        
        void (^highlightBlock)() = ^{
            // use Ivars directly to avoid instanciating them using getters... maybe you won't use textLabel or detailedTextLabel.. right?
            [_textLabel setHighlighted:(highlighted || [self isSelected])];
            [_detailedTextLabel setHighlighted:(highlighted || [self isSelected])];

            [[self selectionBackgroundView] setAlpha:(highlighted || [self isSelected])];
        };
        
        if(animated)
        {
            [UIView animateWithDuration:_kNRGridDefaultAnimationDuration 
                             animations:^{
                                 highlightBlock();
                             }];
        }else{
            highlightBlock();
        }
    }
}

#pragma mark - Layout
static CGSize const _kNRGridViewCellLayoutPadding = {5,5};
static CGSize const _kNRGridViewCellLayoutSpacing = {5,5};

- (void)layoutSubviews
{
    CGRect cellBounds = [self bounds];
    [[self selectionBackgroundView] setFrame:cellBounds];
    [self sendSubviewToBack:[self selectionBackgroundView]];
    [self sendSubviewToBack:[self backgroundView]];
    
    CGRect contentViewFrame = CGRectMake(_kNRGridViewCellLayoutPadding.width, 
                                         _kNRGridViewCellLayoutPadding.height, 
                                         CGRectGetWidth(cellBounds) - _kNRGridViewCellLayoutPadding.width*2, 
                                         CGRectGetHeight(cellBounds) - _kNRGridViewCellLayoutPadding.height*2);
    [[self contentView] setFrame:contentViewFrame];

    CGRect contentViewBounds = [[self contentView] bounds];
    
    // Layout content...
    CGRect imageViewFrame = CGRectZero;
    if([[self imageView] image] != nil){
        imageViewFrame.size.width = ([[[self imageView] image] size].width > CGRectGetWidth(contentViewBounds) 
                                     ? CGRectGetWidth(contentViewBounds) 
                                     : [[[self imageView] image] size].width);
        imageViewFrame.size.height = CGRectGetHeight(contentViewBounds);
    }
    
    CGRect textLabelFrame = CGRectZero;
    if(CGRectIsEmpty(imageViewFrame) == NO)
        textLabelFrame.origin.x = CGRectGetMaxX(imageViewFrame)+_kNRGridViewCellLayoutSpacing.width;
    textLabelFrame.size.width = CGRectGetWidth(contentViewBounds) - CGRectGetMidX(textLabelFrame);
    
    CGSize estimatedTextLabelSize = [[[self textLabel] text] sizeWithFont:[[self textLabel] font] 
                                                        constrainedToSize:CGSizeMake(CGRectGetWidth(textLabelFrame), CGFLOAT_MAX) 
                                                            lineBreakMode:[[self textLabel] lineBreakMode]];
    textLabelFrame.size.height = estimatedTextLabelSize.height;
    
    
    CGRect detailedTextLabelFrame = CGRectZero;
    detailedTextLabelFrame.origin.x = CGRectGetMinX(textLabelFrame);
    detailedTextLabelFrame.size.width = CGRectGetWidth(textLabelFrame);
    CGSize estimatedDetailedTextLabelSize = [[[self detailedTextLabel] text] sizeWithFont:[[self detailedTextLabel] font] 
                                                                constrainedToSize:CGSizeMake(CGRectGetWidth(detailedTextLabelFrame), CGFLOAT_MAX) 
                                                                    lineBreakMode:[[self detailedTextLabel] lineBreakMode]];
    detailedTextLabelFrame.size.height = estimatedDetailedTextLabelSize.height;

    if(CGRectGetHeight(detailedTextLabelFrame) <= 0)
    {
        
        // There is no text available for the detail label. Thus, the textLabel can fit the entire cell-height.
        textLabelFrame.size.height = CGRectGetHeight(contentViewBounds);
        
    }else{
        
        // We must calculate the y axis of both labels.
        CGFloat labelsMaxHeight = floor(CGRectGetHeight(contentViewBounds)/2.);
        CGFloat availableHeight = CGRectGetHeight(contentViewBounds);
        
        CGSize textLabelSizeForOneLine = [@" " sizeWithFont:[[self textLabel] font] 
                                          constrainedToSize:CGSizeMake(CGRectGetWidth(textLabelFrame), CGFLOAT_MAX) 
                                              lineBreakMode:[[self textLabel] lineBreakMode]];
        CGSize detailedTextLabelSizeForOneLine = [@" " sizeWithFont:[[self detailedTextLabel] font] 
                                                  constrainedToSize:CGSizeMake(CGRectGetWidth(detailedTextLabelFrame), CGFLOAT_MAX) 
                                                      lineBreakMode:[[self detailedTextLabel] lineBreakMode]];
        
        if(estimatedTextLabelSize.height > labelsMaxHeight)
            estimatedTextLabelSize.height = labelsMaxHeight;
        
        NSInteger textLabelNumberOfLines = (NSInteger)floor(estimatedTextLabelSize.height / textLabelSizeForOneLine.height);
        estimatedTextLabelSize.height = textLabelSizeForOneLine.height*textLabelNumberOfLines;
        textLabelFrame.size.height = estimatedTextLabelSize.height;

        availableHeight -= estimatedTextLabelSize.height;
                
        if(estimatedDetailedTextLabelSize.height > availableHeight)
            estimatedDetailedTextLabelSize.height = availableHeight;
        
        NSInteger detailedTextLabelNumberOfLines = (NSInteger)floor(estimatedDetailedTextLabelSize.height / detailedTextLabelSizeForOneLine.height);
        estimatedDetailedTextLabelSize.height = detailedTextLabelSizeForOneLine.height*detailedTextLabelNumberOfLines;
        detailedTextLabelFrame.size.height = estimatedDetailedTextLabelSize.height;
        
        textLabelFrame.origin.y =  floor(CGRectGetHeight(contentViewBounds)/2. - (CGRectGetHeight(textLabelFrame) + CGRectGetHeight(detailedTextLabelFrame))/2.);
        detailedTextLabelFrame.origin.y = CGRectGetMaxY(textLabelFrame);
        
    }

    if(CGSizeEqualToSize(estimatedTextLabelSize, CGSizeZero) 
       && CGSizeEqualToSize(estimatedDetailedTextLabelSize, CGSizeZero)
       && [[self imageView] image] != nil)
    {
        // center imageView
        imageViewFrame.origin.x = floor(CGRectGetWidth(contentViewBounds)/2. - CGRectGetWidth(imageViewFrame)/2.);
        imageViewFrame.origin.y = floor(CGRectGetHeight(contentViewBounds)/2. - CGRectGetHeight(imageViewFrame)/2.);
    }
    
    
    [[self imageView] setFrame:imageViewFrame];
    [[self textLabel] setFrame:textLabelFrame];
    [[self detailedTextLabel] setFrame:detailedTextLabelFrame];
}


#pragma mark - Memory

- (void)dealloc
{    
    [_contentView release];
    [_reuseIdentifier release];
    
    [_imageView release];
    [_textLabel release];
    [_detailedTextLabel release];
    
    [_selectionBackgroundView release];
    [_backgroundView release];
    
    [super dealloc];
}

@end
