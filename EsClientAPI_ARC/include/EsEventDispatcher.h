//
//  EsEventDispatcher.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 7/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsEventDispatcherEvent.h"

#define EsEventDispatcher_MaxPriority 1000

@interface EsEventDispatcher : NSObject {
	@private
	NSMutableDictionary* listeners_;
}

- (void) addEventListenerWithTarget:(id) target action:(SEL) action eventIdentifier:(int) eventIdentifier priority:(int) priority;
- (void) addEventListenerWithTarget:(id) target action:(SEL) action eventIdentifier:(int) eventIdentifier;
- (void) removeEventListenerWithTarget:(id) target action:(SEL) action eventIdentifier:(int) eventIdentifier;
- (void) dispatchEvent:(EsEventDispatcherEvent*) event;

@end

@interface EsEventDispatcherListener : NSObject {
}

@property(weak) id target;
@property SEL action;
@property int priority;

@end
