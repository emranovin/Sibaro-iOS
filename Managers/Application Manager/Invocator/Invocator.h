//
//  DirectoryReader.h
//  AppExplorer
//
//  Created by Cardasis, Jonathan (J.) on 7/13/16.
//  Copyright © 2016 Cardasis, Jonathan (J.). All rights reserved.
//

#if __has_include(<UIKit/UIKit.h>)
  #include <UIKit/UIKit.h>

@interface Invocator : NSObject
+ (nullable id) performClassSelector:(nonnull SEL)selector target:(nonnull id)target args: (nullable NSArray*)args;
@end

#endif
