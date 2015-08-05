#import "DPPWeakBlockObserver.h"
#import <objc/runtime.h>

@interface DPPWeakBlockObserver()
{
    __weak id   _object;
    BOOL        _signalChangeNextRunloop;
    NSArray*    _observingProperies;
}

@end

@implementation NSObject(DPPWeakBlockObserver)


-(DPPWeakBlockObserver*)blockObserveIncludingProperties:(NSArray*)properyNames
                                              withBlock:(void (^)(id object))block
{
    return [DPPWeakBlockObserver blockObserverObservingObject:self
                                          includingProperties:properyNames
                                                    withBlock:block];
}

-(DPPWeakBlockObserver*)blockObserveExcludingProperties:(NSArray*)properyNames
                                              withBlock:(void (^)(id object))block
{
    return [DPPWeakBlockObserver blockObserverObservingObject:self
                                          excludingProperties:properyNames
                                                    withBlock:block];
}

-(DPPWeakBlockObserver*)blockObservePropertiesWithBlock:(void (^)(id object))block
{
    return [self blockObserveIncludingProperties:nil
                                       withBlock:block];
}


-(NSArray*)dpp_PropertyNamesForClass:(Class)class
{
    NSMutableArray* propertyNames = [NSMutableArray new];
    
    if([class superclass])
    {
        [propertyNames addObjectsFromArray:[self dpp_PropertyNamesForClass:[class superclass]]];
    }
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            [propertyNames addObject:[NSString stringWithCString:propName
                                                        encoding:[NSString defaultCStringEncoding]]];
        }
    }
    free(properties);
    return propertyNames;
}

-(NSArray*)dpp_PropertyNames
{
    return [self dpp_PropertyNamesForClass:[self class]];
}

@end

@implementation DPPWeakBlockObserver

@synthesize block = _block;

+(instancetype)blockObserverObservingObject:(id)object withBlock:(void (^)(id object))block
{
    return [[DPPWeakBlockObserver alloc] initWithObservingObject:object withBlock:block];
}

+(instancetype)blockObserverObservingObject:(id)object
                        includingProperties:(NSArray*)properyNames
                                  withBlock:(DPPSimpleBlock)block
{
    return [[DPPWeakBlockObserver alloc] initWithObservingObject:object
                                             includingProperties:properyNames
                                                       withBlock:block];
}

+(instancetype)blockObserverObservingObject:(id)object
                        excludingProperties:(NSArray*)properyNames
                                  withBlock:(DPPSimpleBlock)block
{
    return [[DPPWeakBlockObserver alloc] initWithObservingObject:object
                                             excludingProperties:properyNames
                                                       withBlock:block];
}


-(instancetype)initWithObservingObject:(id)object withBlock:(DPPSimpleBlock)block
{
    return [self initWithObservingObject:object
                     includingProperties:nil
                               withBlock:block];
}

-(instancetype)initWithObservingObject:(id)object
                   includingProperties:(NSArray*)properyNames
                             withBlock:(DPPSimpleBlock)block
{
    self = [super init];
    if(self)
    {
        _block = [block copy];
        _object = object;
        _observingProperies = properyNames;
        [self observeProperties];
    }
    return self;
}

-(instancetype)initWithObservingObject:(id)object
                   excludingProperties:(NSArray*)properyNames
                             withBlock:(DPPSimpleBlock)block
{
    NSMutableArray* propertiesToObserve = [object dpp_PropertyNames].mutableCopy;
    [propertiesToObserve removeObjectsInArray:properyNames];
    return [self initWithObservingObject:object
                     includingProperties:propertiesToObserve
                               withBlock:block];
}



-(void)observeProperties
{
    for(id property in [self observingProperties])
    {
        NSAssert([property isKindOfClass:[NSString class]],@"Properties must be specified with strings");
        [_object addObserver:self forKeyPath:property options:0 context:nil];
        
    }
}

-(void)removeObservers
{
    for(id property in [self observingProperties])
    {
        NSAssert([property isKindOfClass:[NSString class]],@"Properties must be specified with strings");
        [_object removeObserver:self forKeyPath:property context:nil];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSAssert(NSThread.isMainThread,
             @"This class is designed to be used on the main thread only. %@",
             [NSThread callStackSymbols]);
    
    if(!_signalChangeNextRunloop) // protect against multiple call per runloop cycle....
    {//if we're not already about to signal a change, do it
        _signalChangeNextRunloop = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!_paused)
            {
                if(_block)
                {
                    _block(_object);
                }
            }
            _signalChangeNextRunloop = NO;
        });
    }
}

-(void)pause
{
    if(!_paused)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(paused))];
        _paused = YES;
        [self didChangeValueForKey:NSStringFromSelector(@selector(paused))];
    }
}

-(void)resume
{
    if(_paused)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(paused))];
        _paused = NO;
        [self didChangeValueForKey:NSStringFromSelector(@selector(paused))];
    }
}

-(NSArray*)observingProperties
{
    if(_observingProperies == nil)
    {//LH default to all
        _observingProperies = [_object dpp_PropertyNames];
    }
    return _observingProperies;
}

-(void)dealloc
{
    [self removeObservers];
}

@end

