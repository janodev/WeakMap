
// BSD License. Created by jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "WeakMap.h"
#import "Car.h"

@interface WeakMapTest : SenTestCase
@end

@implementation WeakMapTest

- (void) xtestIvars {
    Car *honda = [Car new];
    honda.name = @"Honda";
    
    NSString *key = @"some key";
    honda.mapKey = key;
    NSLog(@"honda.mapKey: %@",honda.mapKey);
    STAssertTrue([(NSString*)honda.mapKey isEqualToString:key], (NSString*)honda.mapKey);
}


- (void) testExample {

    WeakMap *weakMap = [[WeakMap alloc] initWithCapacity:10];
    {
        @autoreleasepool {
            // create strong reference
            Car *honda = [Car new];
            honda.name = @"Honda";
            
            // add to the weak map
            [weakMap addEntry:honda withKey:honda.name];
            NSLog(@"description: %@",[weakMap description]);
        }
    }
    
    // after forcing the collection of car...
    NSLog(@"description: %@",[weakMap description]);
}

@end
