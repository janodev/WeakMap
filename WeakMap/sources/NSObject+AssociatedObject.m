
#import "NSObject+AssociatedObject.h"

static const void *kMapKey = &kMapKey;
static const void *kMapNext = &kMapNext;
static const void *kWeakMap = &kWeakMap;

@implementation NSObject (AssociatedObject)
@dynamic mapKey;
@dynamic mapNext;
@dynamic weakMap;

- (NSObject*)mapKey {
    return objc_getAssociatedObject(self, kMapKey);
}
- (void)setMapKey:(NSObject*)mapKey {
    objc_setAssociatedObject(self, kMapKey, mapKey, OBJC_ASSOCIATION_RETAIN);
}

- (NSObject*)mapNext {
    return objc_getAssociatedObject(self, kMapNext);
}
- (void)setMapNext:(NSObject*)mapNext {
    objc_setAssociatedObject(self, kMapNext, mapNext, OBJC_ASSOCIATION_ASSIGN);
}

- (id)weakMap {
    return objc_getAssociatedObject(self, kWeakMap);
}
- (void)setWeakMap:(id)weakMap {
    objc_setAssociatedObject(self, kWeakMap, weakMap, OBJC_ASSOCIATION_ASSIGN);
}


@end