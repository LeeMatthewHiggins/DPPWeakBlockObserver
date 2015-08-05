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


typedef  void (^DPPSimpleBlock)(__nullable id object);

@interface DPPWeakBlockObserver : NSObject

@property (nonatomic,readonly)      DPPSimpleBlock __nonnull block;
@property (nonatomic,readonly)      id __nullable object;
@property (nonatomic,readonly)      NSArray* __nullable observingProperties;
@property (nonatomic,readonly)      BOOL  paused;

+(nullable instancetype)blockObserverObservingObject:(__nonnull id)object
                                           withBlock:(__nonnull DPPSimpleBlock)block;

+(nullable instancetype)blockObserverObservingObject:(id __nonnull)object
                                 includingProperties:(NSArray* __nullable)properyNames
                                           withBlock:(DPPSimpleBlock __nonnull)block;

+(nullable instancetype)blockObserverObservingObject:(id __nonnull)object
                                 excludingProperties:(NSArray* __nullable)properyNames
                                           withBlock:(DPPSimpleBlock __nonnull)block;

-(nullable instancetype)initWithObservingObject:(id __nonnull)object
                                      withBlock:(DPPSimpleBlock __nonnull)block;

-(nullable instancetype)initWithObservingObject:(id __nonnull)object
                            includingProperties:(NSArray* __nullable)properyNames
                                      withBlock:(DPPSimpleBlock __nonnull)block NS_DESIGNATED_INITIALIZER;

-(nullable instancetype)initWithObservingObject:(id __nonnull)object
                            excludingProperties:(NSArray* __nullable)properyNames
                                      withBlock:(DPPSimpleBlock __nonnull)block;

-(void)pause; //stop block callback
-(void)resume; //resume block callback

@end

@interface NSObject(DPPWeakBlockObserver)

-(nullable DPPWeakBlockObserver*)blockObserveIncludingProperties:(NSArray* __nullable)properyNames
                                                       withBlock:(DPPSimpleBlock __nonnull)block;

-(nullable DPPWeakBlockObserver*)blockObserveExcludingProperties:(NSArray* __nullable)properyNames
                                                       withBlock:(DPPSimpleBlock __nonnull)block;

-(nullable DPPWeakBlockObserver*)blockObservePropertiesWithBlock:(DPPSimpleBlock __nonnull)block;

@end
