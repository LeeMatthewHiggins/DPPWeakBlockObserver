//
//  DPPBlockObserver.h
//  DepthPerPixel ltd
//
//  Created by Lee Higgins on 11/01/2014.
//  Copyright (c) 2015 DepthPerPixel. All rights reserved.
//

//NOTES:
//
// Does not retain the observed object
// Safely removes observers when this object is released
// Designed for simple use, "Call block when the objects properties change"

#import <Foundation/Foundation.h>

@interface DPPWeakBlockObserver : NSObject

@property (nonatomic, copy)     void (^block)(id object);
@property (nonatomic, readonly) id object;
@property (nonatomic,readonly)  NSArray* observingProperties;
@property (nonatomic,readonly)  BOOL  paused;

+(instancetype)blockObserverObservingObject:(id)object
                                  withBlock:(void (^)(id object))block;

+(instancetype)blockObserverObservingObject:(id)object
                         includingProperties:(NSArray*)properyNames
                                  withBlock:(void (^)(id object))block;

+(instancetype)blockObserverObservingObject:(id)object
                         excludingProperties:(NSArray*)properyNames
                                  withBlock:(void (^)(id object))block;

-(instancetype)initObservingObject:(id)object
                         withBlock:(void (^)(id object))block;

-(instancetype)initObservingObject:(id)object
                includingProperties:(NSArray*)properyNames
                         withBlock:(void (^)(id object))block;

-(instancetype)initObservingObject:(id)object
                excludingProperties:(NSArray*)properyNames
                         withBlock:(void (^)(id object))block;

-(void)pause; //stop block callback
-(void)resume; //resume block callback

@end

@interface NSObject(DPPWeakBlockObserver)

-(DPPWeakBlockObserver*)blockObserveIncludingProperties:(NSArray*)properyNames
                                withBlock:(void (^)(id object))block;

-(DPPWeakBlockObserver*)blockObserveExcludingProperties:(NSArray*)properyNames
                                              withBlock:(void (^)(id object))block;

-(DPPWeakBlockObserver*)blockObservePropertiesWithBlock:(void (^)(id object))block;

@end
