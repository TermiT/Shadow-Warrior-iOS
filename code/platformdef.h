//
//  platformdef.h
//  lowang
//
//  Created by Sergei Shubin on 14/8/12.
//  Copyright (c) 2012 s.v.shubin@gmail.com. All rights reserved.
//

#ifndef lowang_platformdef_h
#define lowang_platformdef_h

#ifdef __APPLE__
#include <TargetConditionals.h>
#ifdef TARGET_OS_IPHONE
#define LOWANG_IOS 1
#endif
#endif

#endif
