# DPPWeakBlockObserver
Simple block based observing of property changes (based on KVO)

Usage:
```
DPPWeakBlockObserver* blockObserver = [anObject blockObservePropertiesWithBlock:^(id object) {
                                                                         if(object)
                                                                         {
                                                                             NSLog(@"Object changed: %@",object);
                                                                         }
                                                                     }];
                                                                     
```

Will observe changes for the life of the observer.
Does not retain the observed object.
