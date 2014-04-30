//
//  RSSRequest.h
//  StatusBarItem
//
//  Created by Austin Cherry on 4/29/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLKit.h"

@interface RSSRequest : NSOperation

typedef void (^RSSRequestSuccess)(RSSRequest *request);
typedef void (^RSSRequestFailure)(RSSRequest *request,NSError* error);
typedef void (^RSSRequestProgress)(RSSRequest *request,float progress);

@property(nonatomic,strong,readonly)NSString *url;
@property(nonatomic,strong,readonly)NSData *responseData;
@property(nonatomic,assign,readonly)long long responseLength;

-(XMLElement*)responseElement;

-(instancetype)initWithURL:(NSString*)url;

-(void)setSuccessBlock:(RSSRequestSuccess)success;
-(void)setFailureBlock:(RSSRequestFailure)failure;
-(void)setProgressBlock:(RSSRequestProgress)progress expectedLength:(long long)length;

+(RSSRequest*)requestWithURL:(NSString*)url success:(RSSRequestSuccess)success failure:(RSSRequestFailure)failure;

@end
