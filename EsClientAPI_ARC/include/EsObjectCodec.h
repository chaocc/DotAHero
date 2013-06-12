//
//  EsObjectCodec.h
//  cocoa-touch
//
//  Created by Jason von Nieda on 9/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EsFlattenedEsObject.h"
#import "EsFlattenedEsObjectRO.h"


@interface EsObjectCodec : NSObject {

}
+ (EsFlattenedEsObject*) flattenEsObject: (EsObject*) esObject;
+ (EsFlattenedEsObjectRO*) flattenEsObjectRO: (EsObject*) esObject;
+ (EsObject*) unflattenEsObject: (EsFlattenedEsObject*) fEsObject;
+ (EsObject*) unflattenEsObjectRO: (EsFlattenedEsObjectRO*) fEsObject;
@end
