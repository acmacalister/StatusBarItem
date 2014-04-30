//
//  RSSRequest.m
//  StatusBarItem
//
//  Created by Austin Cherry on 4/29/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//

#import "RSSRequest.h"

typedef NS_ENUM(NSInteger, RSSOperationState) {
    RSSOperationPausedState      = -1,
    RSSOperationReadyState       = 1,
    RSSOperationExecutingState   = 2,
    RSSOperationFinishedState    = 3,
};

@interface RSSRequest ()

@property(nonatomic,strong)NSString *saveURL;
@property(nonatomic,strong)NSMutableData *receivedData;
@property(nonatomic,strong)NSURLConnection *urlConnection;
@property(nonatomic,assign)RSSOperationState state;
@property(readwrite, nonatomic, assign, getter = isCancelled)BOOL cancelled;

@property(nonatomic,assign)long long contentLength;
@property(nonatomic,strong)RSSRequestSuccess success;
@property(nonatomic,strong)RSSRequestFailure failure;

@property(nonatomic)long long expectedLength;
@property(nonatomic,strong)RSSRequestProgress progress;

@end

@implementation RSSRequest

////////////////////////////////////////////////////////////////////////////////////////////////////
-(instancetype)initWithURL:(NSString*)url
{
    if(self = [super init])
    {
        self.receivedData = [[NSMutableData alloc] init];
        self.saveURL = url;
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setSuccessBlock:(RSSRequestSuccess)success
{
    self.success = success;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFailureBlock:(RSSRequestFailure)failure
{
    self.failure = failure;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setProgressBlock:(RSSRequestProgress)progress expectedLength:(long long)length
{
    self.progress = progress;
    self.expectedLength = length;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSData*)responseData
{
    return self.receivedData;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(XMLElement*)responseElement
{
    NSString *str = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    return [str XMLObjectFromString];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)url
{
    return self.saveURL;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
-(long long)responseLength
{
    return self.contentLength;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
    if(self.progress && self.expectedLength > 0)
    {
        float increment = 100.0f/self.expectedLength;
        float current = (increment*self.receivedData.length);
        current = current*0.01f;
        if(current > 1)
            current = 1;
        self.progress(self,current);
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading:(NSURLConnection *)currentConnection
{
    if(self.success)
        self.success(self);
    [self finish];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)currentConnection didFailWithError:(NSError *)error
{
    if(self.failure)
        self.failure(self,error);
    [self finish];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
    if ([response isKindOfClass:[NSHTTPURLResponse self]])
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSDictionary *headers = [httpResponse allHeaderFields];
        self.contentLength = [[headers objectForKey:@"Content-Length"] longLongValue];
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)start
{
    [self willChangeValueForKey:@"isExecuting"];
    self.state = RSSOperationExecutingState;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSURL* url = [[NSURL alloc] initWithString:self.saveURL];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    /*NSPort* port = [NSPort port];
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop]; // Get the main runloop
    [runLoop addPort:port forMode:NSDefaultRunLoopMode];
    [self.urlConnection scheduleInRunLoop:runLoop forMode:NSDefaultRunLoopMode];*/
    [self.urlConnection start];
    //[runLoop run];
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.state = RSSOperationFinishedState;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)cancel
{
    [self.urlConnection cancel];
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = YES;
    [self willChangeValueForKey:@"isCancelled"];
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isConcurrent
{
    return YES;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isFinished
{
    return self.state == RSSOperationFinishedState;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isExecuting
{
    return self.state == RSSOperationExecutingState;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//factory method
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(RSSRequest*)requestWithURL:(NSString*)url success:(RSSRequestSuccess)success failure:(RSSRequestFailure)failure
{
    RSSRequest *request = [[RSSRequest alloc] initWithURL:url];
    [request setSuccess:success];
    [request setFailure:failure];
    return request;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
