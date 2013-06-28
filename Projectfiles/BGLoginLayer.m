//
//  BGLoginLayer.m
//  DotAHero
//
//  Created by Killua Liu on 6/19/13.
//
//

#import "BGLoginLayer.h"
#import "BGRoomListLayer.h"

@implementation BGLoginLayer

static BGLoginLayer *instanceOfLoginLayer = nil;

+ (id)sharedLoginScene
{
    NSAssert(instanceOfLoginLayer != nil, @"LoginLayer instance not yet initialized!");
	return instanceOfLoginLayer;
}

-(id) init
{
	if ((self = [super init]))
	{
        instanceOfLoginLayer = self;
        [self conntectServer];
	}
    
	return self;
}

- (void)conntectServer
{
    self.es = [[ElectroServer alloc] init];
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"settings.xml"];
    [_es loadAndConnect:path];
    
    [_es.engine addEventListenerWithTarget:self action:@selector(onConnectionResponse:) eventIdentifier:EsMessageType_ConnectionResponse];
}

- (void)onConnectionResponse:(EsConnectionResponse *)e
{
    NSAssert(e.successful, @"Connnection Failed");
    
    if (e.successful) {
        [_es.engine addEventListenerWithTarget:self action:@selector(onLoginResponse:) eventIdentifier:EsMessageType_LoginResponse];
        
        EsLoginRequest *lr = [[EsLoginRequest alloc] init];
        lr.userName = [NSString stringWithFormat:@"Guest%li", lrint(1000 * random())];
        [_es.engine sendMessage:lr];
    }
}

- (void)onLoginResponse:(EsLoginResponse *)e
{
    NSAssert(e.successful, @"Login Failed");
    [self addChild:[BGRoomListLayer scene]];
//	[[CCDirector sharedDirector] replaceScene:transitionScene];
}

@end
