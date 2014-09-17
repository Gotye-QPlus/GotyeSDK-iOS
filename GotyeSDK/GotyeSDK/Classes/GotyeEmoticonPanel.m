//
//  GotyeEmoticonPanel.m
//  Gotye
//
//  Created by Peter on 12-7-9.
//  Copyright (c) 2012年 AiLiao. All rights reserved.
//

#import "GotyeEmoticonPanel.h"
#import "GotyeImageManager.h"
#import "GotyeSDKResource.h"

#define kGotyeEmotionPanel_emotiSize (IS_IPAD ? 56 : 44)
#define kGotyeEmotionPanel_xOffset (IS_IPAD ? 15 : 6)
#define kSystemEmoticonCount (99)

@interface GotyeEmoticonPanel()
{
    CGFloat _heightForPortrait;
}
@end

@implementation GotyeEmoticonPanel

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"view.frame"];
}

- (IBAction)pageValueChanged:(id)sender
{
    [_emoticonView scrollRectToVisible:CGRectMake(_pageControl.currentPage * self.view.frame.size.width, 0, _emoticonView.frame.size.width, _emoticonView.frame.size.height)
                             animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == _emoticonView)
    {
        NSInteger pageNo = (scrollView.contentOffset.x + self.view.frame.size.width / 2) / self.view.frame.size.width;
        
        _pageControl.currentPage = pageNo;
    }
}

- (void)emoticonClick:(UIButton*)emoticonButton
{
    if(_textInput != nil)
    {
        NSMutableString *text = [[NSMutableString alloc]initWithString:_textInput.text];
        [text appendString:[[NSString alloc]initWithFormat:@"[s%d]", emoticonButton.tag]];
        _textInput.text = text;
        
        [_textInput.delegate textViewDidChange:_textInput];
        NSRange range = NSMakeRange(_textInput.text.length - 1, 1);
        [_textInput scrollRangeToVisible:range];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _heightForPortrait = self.view.frame.size.height;
    
    [self addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    int numberOfColumn = (_emoticonView.frame.size.width - kGotyeEmotionPanel_xOffset * 2) / kGotyeEmotionPanel_emotiSize;
    int numberOfRow = _emoticonView.frame.size.height / kGotyeEmotionPanel_emotiSize;
    
    NSInteger row, col, page;
    for (int i = 0; i < kSystemEmoticonCount; i++) {
        row = (i / numberOfColumn) % numberOfRow;
        col = i % numberOfColumn;
        page = i / (numberOfRow * numberOfColumn);
        UIButton *emoticonButton = [[UIButton alloc] initWithFrame:CGRectMake(kGotyeEmotionPanel_xOffset + col * kGotyeEmotionPanel_emotiSize + page * self.view.frame.size.width, row * kGotyeEmotionPanel_emotiSize, kGotyeEmotionPanel_emotiSize, kGotyeEmotionPanel_emotiSize)];
        NSString* name = [[NSString alloc] initWithFormat:@"smiley_%d", i + 1];
        [emoticonButton setImage:[[GotyeImageManager sharedImageManager]getImageWithPath:[GotyeSDKResource pathForResource:name ofType:@"png"]] forState:UIControlStateNormal];
        emoticonButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [emoticonButton setTag:i + 1];
        [emoticonButton addTarget:self action:@selector(emoticonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_emoticonView addSubview:emoticonButton];
    }
    
    _emoticonView.contentSize = CGSizeMake(self.view.frame.size.width * (page + 1), _emoticonView.frame.size.height);
    _pageControl.numberOfPages = page + 1;
}

- (void)changeToLandscapeMode
{
    [super changeToLandscapeMode];
    
    CGRect frame = self.view.frame;
    frame.size.height = 128;
    
    self.view.frame = frame;
}

- (void)changeToPortraitMode
{
    CGRect frame = self.view.frame;
    frame.size.height = _heightForPortrait;
    
    self.view.frame = frame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != self || ![keyPath isEqualToString:@"view.frame"]) {
        return;
    }
    
    NSValue *newFrameValue = change[NSKeyValueChangeNewKey];
    NSValue *oldFrameValue = change[NSKeyValueChangeOldKey];
    
    if (![newFrameValue isMemberOfClass:[NSNull class]] && ![oldFrameValue isMemberOfClass:[NSNull class]] && [newFrameValue CGRectValue].size.width == [oldFrameValue CGRectValue].size.width && [newFrameValue CGRectValue].size.height == [oldFrameValue CGRectValue].size.height) {
        return;
    }
    
    int numberOfColumn = (_emoticonView.frame.size.width - kGotyeEmotionPanel_xOffset * 2) / kGotyeEmotionPanel_emotiSize;
    int numberOfRow = _emoticonView.frame.size.height / kGotyeEmotionPanel_emotiSize;
    
    //iPad中不知道为啥会出现width和height是0的情况
    if (numberOfRow == 0 || numberOfColumn == 0) {
        return;
    }
    
    int row, col, page, index;
    
    for (UIView *subview in self.emoticonView.subviews) {
        if (![subview isKindOfClass:[UIButton class]]) {
            continue;
        }
        
        index = subview.tag - 1;
        row = (index / numberOfColumn) % numberOfRow;
        col = index % numberOfColumn;
        page = index / (numberOfRow * numberOfColumn);
        
        CGRect frame = subview.frame;
        frame.origin.x = kGotyeEmotionPanel_xOffset + col * kGotyeEmotionPanel_emotiSize + page * self.view.frame.size.width;
        frame.origin.y = row * kGotyeEmotionPanel_emotiSize;
        subview.frame = frame;
    }
    
    _emoticonView.contentSize = CGSizeMake(self.view.frame.size.width * (page + 1), _emoticonView.frame.size.height);
    _pageControl.numberOfPages = page + 1;
    
}

@end
