#import "GameMain.h"
#import "GameEngineScene.h"

#import "Resource.h"

@implementation GameMain
+(CCScene*)main; {
	[Resource load_all];
	NSLog(@"%@",cocos2dVersion());
	return [GameEngineScene cons];
}
@end
