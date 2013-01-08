
#import "Car.h"

@implementation Car
-(NSString*)description {
    return _name;
}
-(void) dealloc {
    NSLog(@"BEGIN dealloc key %@",self.mapKey);
    [self.weakMap performSelector:@selector(keyRemoved:) withObject:self.mapKey];
    NSLog(@"END dealloc key %@",self.mapKey);
}
@end