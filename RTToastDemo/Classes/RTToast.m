//
//  RTToast.m
//  RTToastDemo
//
//  Created by ColaBean on 2017/7/22.
//  Copyright © 2017年 ColaBean. All rights reserved.
//

#import "RTToast.h"

@implementation RTToastStackPool
{
    NSMutableArray *_pools;
@public
    dispatch_queue_t queue;
    
}

+ (instancetype)pool {
    static RTToastStackPool * _someCls = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _someCls = [[RTToastStackPool alloc] init];
    });
    return _someCls;
}

- (instancetype)init {
    if (self = [super init]) {
        _pools = @[].mutableCopy;
        queue = dispatch_queue_create("com.rt.toast.pool", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (BOOL)isEmpty {
    return ![_pools count];
}

- (BOOL)moreThanData {
    return [_pools count] > 1;
}

- (void)addObj:(id)aObjct msg:(NSString *)msg {
    /**< don't nil. */
    if (!aObjct || !msg) return;
    
    [self addObject:@{@"label":aObjct, @"msg":msg}];
}

- (void)addObject:(NSDictionary *)aDict {
    [_pools addObject:aDict];
}

- (void)removeFirstObject {
    return [_pools removeObjectAtIndex:0];
}

- (id)firstObject {
    return [_pools firstObject];
}

- (id)obj {
    return [[self firstObject] objectForKey:@"label"];
}

- (NSString *)msg {
    return [[self firstObject] objectForKey:@"msg"];
}

@end

#define RTToastDefaultWidth (200)
#define RTToastDefaultHeight (45)

@implementation RTToast

+ (void)performShow {
    if ([[RTToastStackPool pool] moreThanData]) {
        return;
    }
    [self performAnimation];
}

+ (void)performNextTask {
    [[RTToastStackPool pool] removeFirstObject];
    if ([[RTToastStackPool pool] isEmpty]) {
        return;
    }
    [self performAnimation];
}

+ (void)performAnimation {
    RTToastStackPool *stackPool = [RTToastStackPool pool];
    [stackPool.showInView addSubview:[stackPool obj]];
    [self performSelector:@selector(hideToastDelay:) withObject:stackPool afterDelay:3.0];
    [UIView animateWithDuration:0.25 animations:^{
        [stackPool.obj setAlpha:1];
    }];
}

+ (void)hint:(NSString *)msg showView:(UIView *)showView {
    if (!msg || !showView) return;
    
    RTToastStackPool *pool = [RTToastStackPool pool];
    void(^task)(void) = ^() {
        @autoreleasepool {
            //step1: create UI.
            UILabel *label = nil;
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.alpha = 1;
            label.tag = 10001;
            label.layer.cornerRadius = 5;
            label.layer.masksToBounds = YES;
            label.text = msg;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:15];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            label.alpha = 0;
            label.numberOfLines = 0;
            //step2: push in pools. and cache showView in memory.
            [[RTToastStackPool pool] addObj:label msg:msg];
            [RTToastStackPool pool].showInView = showView;
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat deltaY = CGRectGetHeight(showView.frame)-RTToastDefaultHeight*2;
                label.frame = CGRectMake(0.5*(CGRectGetWidth(showView.frame)-RTToastDefaultWidth), deltaY, RTToastDefaultWidth, RTToastDefaultHeight);
                if (msg) {
                    CGSize size = [[self class] title:msg sizeWithFont:label.font maxSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-30, CGFLOAT_MAX)];
                    if (size.width > 180 ) {
                        CGFloat height = size.height>RTToastDefaultHeight?size.height:RTToastDefaultHeight;
                        label.frame = (CGRect){0.5*(CGRectGetWidth(showView.frame)-size.width-20), CGRectGetHeight(showView.bounds)-(RTToastDefaultHeight+height), size.width+20, height};
                    }
                }
                //step3: show
                [self performShow];
            });
        }
    };
    dispatch_async(pool->queue, task);
}

+ (void)hideToastDelay:(RTToastStackPool *)obj {
    NSLog(@"hud end!: %@", [obj msg]);
    id label = [obj obj];
    if ([label isKindOfClass:[UILabel class]]) {
        [UIView animateWithDuration:0.25 animations:^{
            [(UILabel *)label setAlpha:0];
        } completion:^(BOOL finished) {
            [self performNextTask];
            [(UILabel *)label removeFromSuperview];
        }];
    }
}

@end

@implementation RTToast (Helper)

+ (CGSize)title:(NSString *)title sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName: font};
    NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize textSize = [title boundingRectWithSize:maxSize options:option attributes:dict context:nil].size;
    CGSize adjustedSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    return adjustedSize;
}

@end
