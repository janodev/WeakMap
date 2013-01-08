
// BSD License. Created by jano@jano.com.es

#import "NSObject+AssociatedObject.h"

extern NSString *const kMapKey;
extern NSString *const kMapNext;

/** 
 * Hash table implementation with separate chaining. 
 * Read Θ(1). Set/remove Θ(1+n/m) assuming uniform distribution, or O(n) worst case.
 */
@interface WeakMap : NSObject <NSFastEnumeration>

@property (nonatomic,assign,readonly) NSUInteger count;

- (id) initWithCapacity:(NSUInteger)capacity;
- (void) addEntry:(NSObject*)entry withKey:(NSObject*)key;
- (NSObject*) entryForKey:(NSObject*)key;
- (void) removeEntry:(NSObject*)entry;
- (BOOL) hasEntry:(NSObject*)entry;
- (NSString*) componentsJoinedByString:(NSString*)string;


@end
