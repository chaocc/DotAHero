//
//  Autogenerated by CocoaTouchApiGenerator
//
//  DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
//



#import "EsMessage.h"
#import "EsMessageType.h"
#import "EsRequest.h"
#import "EsResponse.h"
#import "EsEvent.h"
#import "EsEntity.h"
#import "EsObject.h"
#import "ThriftPublicMessageEvent.h"
#import "EsFlattenedEsObject.h"
#import "ThriftFlattenedEsObject.h"

/**
 * This event occurs when a public message is sent to a room to which the client belongs. The event contains the name of the user that sent it, the message, room and zone id, and an optional 
 EsObject.
 * 
 * This shows how to send a simple public message and capture the event.

<pre>
private var _es:ElectroServer;
private var _room:Room;

private function initialize():void {
        _es.engine.addEventListener(MessageType.PublicMessageEvent.name, onPublicMessageEvent);
}

private function sendTestMessage():void {
        //create the message object
        var pmr:PublicMessageRequest = new PublicMessageRequest();

        //configure it
        pmr.message = "Hello World!";
        pmr.roomId = _room.id;
        pmr.zoneId = _room.zoneId;

        //send it
        _es.engine.send(pmr);
}
</pre>


                 This shows how to send a public message to a room with an EsObject attached, and capture the event.
<pre>
private var _es:ElectroServer;
private var _room:Room;

private function initialize():void {
        _es.engine.addEventListener(MessageType.PublicMessageEvent.name, onPublicMessageEvent);
}

private function sendTestMessage():void {
        //create the message object
        var pmr:PublicMessageRequest = new PublicMessageRequest();

        //configure it
        pmr.message = "Hello World!";
        pmr.roomId = _room.id;
        pmr.zoneId = _room.zoneId;

        //create an EsObject to send
        var esob:EsObject = new EsObject();
        esob.setBoolean("playAudioWithMessage", true);

        //put it on the message
        pmr.esObject = esob;

        //send it
        _es.engine.send(pmr);
}

private function onPublicMessageEvent(e:PublicMessageEvent):void {
        trace(e.userName + " says '" + e.message + "'");
        trace("playAudioWithMessage: " + e.esObject.getBoolean("playAudioWithMessage").toString());
}
</pre>
 */
@interface EsPublicMessageEvent : EsEvent {
@private
	BOOL message_set_;
	NSString* message_;
	BOOL userName_set_;
	NSString* userName_;
	BOOL zoneId_set_;
	int32_t zoneId_;
	BOOL roomId_set_;
	int32_t roomId_;
	BOOL esObject_set_;
	EsObject* esObject_;
}

/**
 * The chat message.
 */
@property(strong,nonatomic) NSString* message;
/**
 * The name of the user that sent the message.
 */
@property(strong,nonatomic) NSString* userName;
/**
 * The id of the zone that contains the room.
 */
@property(nonatomic) int32_t zoneId;
/**
 * The id of the room that received the message.
 */
@property(nonatomic) int32_t roomId;
/**
 * Optional EsObject property.
 */
@property(strong,nonatomic) EsObject* esObject;

- (id) init;
- (id) initWithThriftObject: (id) thriftObject;
- (void) fromThrift: (id) thriftObject;
- (ThriftPublicMessageEvent*) toThrift;
- (id) newThrift;
@end
