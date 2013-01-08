#import "NSObject+AssociatedObject.h"
#include <objc/runtime.h>

@interface NSObject (AssociatedObject)
@property (nonatomic, strong) NSObject *mapKey;
@property (nonatomic, strong) NSObject *mapNext;
@property (nonatomic, assign) id weakMap;
@end