
// BSD License. Created by jano@jano.com.es

#import "WeakMap.h"

NSString *const kMapKey  = @"kMapKey";
NSString *const kMapNext = @"kMapNext";

const float kMapLoadFactor = 0.75;
const NSUInteger kMapDefaultCapacity = 10;

@interface WeakMap()
@property (nonatomic,assign,readwrite) NSUInteger count;
-(NSUInteger) indexForKey:(NSObject*)key;
-(float) currentLoad;
@end


@implementation WeakMap {
    id __weak *_objs;     
    NSUInteger _capacity;    
    unsigned long _mutations;
    NSUInteger _slotsFilled;
    CGFloat _loadFactor;
}


#pragma mark - ARContainer

-(NSUInteger) count {
    return _count;
}

- (id)init {
    return [self initWithCapacity:kMapDefaultCapacity];
}

-(BOOL) isEmpty {
    return _count == 0;
}


#pragma mark - ARMapProtocol


- (id) initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self){
        _loadFactor = kMapLoadFactor;
        _capacity = capacity;
        _objs = (id __weak *)calloc(capacity,sizeof(*_objs));
        _count = 0;
        _mutations = 0;
    }
    return self;
}


-(void) keyRemoved:(NSString*)key {
    NSLog(@"KeyRemoved: %@",key);
    NSUInteger index = [self indexForKey:key];
    _objs[index] = nil;
    _count--;
}


-(void) addEntry:(NSObject*)entry withKey:(NSObject*)key {
    _mutations++;
    
    entry.mapKey = key;
    entry.weakMap = self;
    
    if ([self currentLoad]>_loadFactor){
        [self expandCapacity];
    }
    
    NSUInteger index = [self indexForKey: entry.mapKey];
    if (_objs[index]==nil){
        _objs[index] = entry;
        _slotsFilled++;
        _count++;
    } else {
        NSObject *bucket = _objs[index];
        while (![ bucket.mapKey  isEqual: entry.mapKey] && ( bucket.mapNext!=nil)){
            bucket =  bucket.mapNext;
        }
        if ([ bucket.mapKey  isEqual: entry.mapKey]){
            _objs[index] = entry;
        } else {
            bucket.mapNext=entry;
            _count++;
        }
    }
}


-(NSObject*) entryForKey:(NSObject*)key {
    NSUInteger index = [self indexForKey:key];
    NSObject* entry = _objs[index];
    if (entry!=nil){
        while ((entry!=nil) && (![ entry.mapKey isEqual:key])){
            entry =  entry.mapNext;
        }
    }
    return entry;
}


-(BOOL) hasEntry:(NSObject*)entry {
    NSObject *e = [self entryForKey: entry.mapKey];
    return e!=nil && [e isEqual:entry];
}


-(void) removeEntry:(NSObject*)entry {
    _mutations++;
    NSUInteger index = [self indexForKey: entry.mapKey];
    if (_objs[index]==nil){
    } else {
        if ([ [_objs[index] mapKey] isEqual: entry.mapKey]){
            if ([_objs[index] mapNext]==nil){
                _objs[index] = nil;
                _count--;
                _slotsFilled--;
            } else {
                _objs[index] = [_objs[index] mapNext];
                _count--;
            }
        } else {
            NSObject *prev = _objs[index];
            while ([prev mapNext]!=nil && ![[[prev mapNext] mapKey] isEqual: entry.mapKey]){
                prev = [prev mapNext];
            }
            if (prev==nil){
                NSLog(@"No entry for key %@",  entry.mapKey);
            } else {
                NSObject *value = prev.mapNext.mapNext==nil ? nil : prev.mapNext.mapNext;
                prev.mapNext=value;
                _slotsFilled--;
            }
        }
    }
}


-(NSString*) componentsJoinedByString:(NSString*)string
{
    NSMutableString *mString = [NSMutableString new];
    for (NSUInteger i=0; i<_capacity; i++) {
        if (_objs[i]!=nil) {
            NSObject *entry = _objs[i];
            if (entry!=nil){
                do {
                    [mString appendFormat:@"[%@,%@]", entry.mapKey,entry];
                    entry =  entry.mapNext;
                } while (entry!=nil);
            }
        }
        if ((i+1)<_slotsFilled) [mString appendString:string];
    }
    return mString;
}


-(NSString*) description {
    return _count==0 ? @"<empty>" : [self componentsJoinedByString:@","];
}

#pragma mark - Internal


-(void) freePointers:(__weak id*)pointers size:(NSUInteger)size {
    for (NSUInteger i=0; i<size; i++) {
        //pointers[i] = nil;
    }
    free(pointers);
}


-(float) currentLoad {
    return _capacity>0 ? _slotsFilled/(float)_capacity : 1.0;
}


- (void) dealloc {
    [self freePointers:_objs size:_capacity];
}


-(void) expandCapacity
{
    NSUInteger newCapacity = _capacity>0 ? _capacity*2 : 1;
    id __weak *newObjs = (id __weak *)calloc(newCapacity,sizeof(*newObjs));
    if (_objs!=nil){

        NSUInteger newSlotsFilled = 0;
        for (NSObject *entry in self) {
            NSUInteger index = [ entry.mapKey hash] % newCapacity;
            if (newObjs[index]==nil){
                newObjs[index] = entry;
                newSlotsFilled++;
            } else {
                NSObject *e = newObjs[index];
                while (![ e.mapKey isEqual: entry.mapKey] && ( e.mapNext!=nil)){
                    e =  e.mapNext;
                }
                if ([ e.mapKey isEqual: entry.mapKey]){
                    newObjs[index] = entry;
                } else {
                    e.mapNext=entry;
                }
            }
        }
        
        id __weak *old = _objs;
        _objs = newObjs;
        [self freePointers:old size:_capacity];
        _capacity = newCapacity;
        _slotsFilled = newSlotsFilled;
    }
}


-(NSUInteger) indexForKey:(NSObject*)key {
    return _capacity>0 ? ([key hash] % _capacity) : 1;
}


#pragma mark - NSFastEnumeration


- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState*)state
                                   objects: (id __unsafe_unretained*)stackbuf
                                     count: (NSUInteger)len
{
    state->mutationsPtr = (unsigned long *) &_mutations;
    
    NSInteger count = MIN(len, [self count] - state->state);
    
    if (count>0){
        NSUInteger index = 0;
        NSUInteger p = state->extra[0];
        NSObject *e = (__bridge NSObject*)(state->extra[1]==0 ? nil : (void*)state->extra[1]);
        do {
            while (e!=nil){
                stackbuf[index] = e;
                e =  e.mapNext;
                state->extra[1] = (NSUInteger)e;
                index++;
                if (index==count) break;
            }
            if (index==count) {
                break;
            } else {
                e = _objs[p];
                state->extra[1] = (NSUInteger)e;
                p++;
                state->extra[0] = p;
            }
        } while (!(p>_capacity));
    }
    
    state->itemsPtr = stackbuf;
    state->state += count;
    return count;
}


@end
