#import <Cedar-iOS/SpecHelper.h>

// Cedar matchers don't work correctly with ARC.
#if __has_feature(objc_arc)
#error ARC must be disabled for specs!
#endif
