//
//  RTToast.h
//  RTToastDemo
//
//  Created by ColaBean on 2017/7/22.
//  Copyright © 2017年 ColaBean. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface RTToastStackPool : NSObject

+ (instancetype)pool;
@property (nonatomic, strong) UIView *showInView;
@property (nonatomic, assign, readonly) BOOL isEmpty;
@property (nonatomic, assign, readonly) BOOL moreThanData;

- (void)addObj:(id)aObjct msg:(NSString *)msg;
- (void)addObject:(NSDictionary *)aDict;
- (void)removeFirstObject;
- (id)firstObject;

- (id)obj;
- (NSString *)msg;

@end

@interface RTToast : NSObject

+ (void)hint:(NSString *)msg showView:(UIView *)showView;

@end

@interface RTToast (Helper)

+ (CGSize)title:(NSString *)title sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

@end
