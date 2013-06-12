/*
 *  DLOG.h
 *  cocoa-touch
 *
 *  Created by Jason von Nieda on 10/2/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

//#define DEBUG 1

#ifdef DEBUG
// DLOG takes a format argument and 0 or more args:
// DLOG(@"");
// DLOG(@"%d", x);
#define DLOG(fmt, ...) NSLog(@"%s: " fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define DLOG(...)
#endif