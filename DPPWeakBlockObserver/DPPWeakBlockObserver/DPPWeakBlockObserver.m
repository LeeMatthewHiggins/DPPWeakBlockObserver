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

-(NSArray*)propertyNames
{//LH little bit of dirty runtime code
    NSMutableArray* propertyNames = [NSMutableArray new];
    
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

@end

@implementation DPPWeakBlockObserver

+(instancetype)blockObserverObservingObject:(id)object withBlock:(void (^)(id object))block
{
    return [[DPPWeakBlockObserver alloc] initObservingObject:object withBlock:block];
}

+(instancetype)blockObserverObservingObject:(id)object
                         includingProperties:(NSArray*)properyNames
                                  withBlock:(void (^)(id object))block
{
    return [[DPPWeakBlockObserver alloc] initObservingObject:object
                                      includingProperties:properyNames
                                               withBlock:block];
}

+(instancetype)blockObserverObservingObject:(id)object
                        excludingProperties:(NSArray*)properyNames
                                  withBlock:(void (^)(id object))block
{
    return [[DPPWeakBlockObserver alloc] initObservingObject:object
                                          excludingProperties:properyNames
                                                   withBlock:block];
}


-(instancetype)initObservingObject:(id)object withBlock:(void (^)(id object))block
{
    return [self initObservingObject:object
                  includingProperties:nil
                           withBlock:block];
}

-(instancetype)initObservingObject:(id)object
                includingProperties:(NSArray*)properyNames
                         withBlock:(void (^)(id object))block
{
    if(object == nil)
    {
        return nil;
    }
    self = [super init];
    if(self)
    {
        self.block = block;
        _object = object;
        _observingProperies = properyNames;
        [self observeProperties];
    }
    return self;
}

-(instancetype)initObservingObject:(id)object
               excludingProperties:(NSArray*)properyNames
                         withBlock:(void (^)(id object))block
{
    NSMutableArray* propertiesToObserve = [object propertyNames].mutableCopy;
    [propertiesToObserve removeObjectsInArray:properyNames];
    return [self initObservingObject:object
                 includingProperties:propertiesToObserve
                           withBlock:block];
}


-(NSString*)propertyNameFromObject:(id)object
{
    if([object isKindOfClass:[NSString class]])
    {
        return object;
    }
    return nil;
}

-(void)observeProperties
{
    for(id property in [self observingProperties])
    {
        NSString* propertyName = [self propertyNameFromObject:property];
        if(propertyName)
        {
            [_object addObserver:self forKeyPath:propertyName options:0 context:nil];
        }
    }
}

-(void)removeObservers
{
    for(id property in [self observingProperties])
    {
        NSString* propertyName = [self propertyNameFromObject:property];
        if(propertyName)
        {
            [_object removeObserver:self forKeyPath:propertyName context:nil];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(!_signalChangeNextRunloop) // protect against multiple call per runloop cycle....
    {//if we're not already about to signal a change, do it
        _signalChangeNextRunloop = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!_paused)
            {
                if(_block)
                    _block(_object);
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
        _observingProperies = [_object propertyNames];
    }
    return _observingProperies;
}

-(void)dealloc
{
    [self removeObservers];
}

@end

