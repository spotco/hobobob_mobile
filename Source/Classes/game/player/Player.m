#import "Player.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"

#import "CCTexture_Private.h"

@implementation Player {
	CCAction *_anim_stand, *_anim_run, *_anim_jump, *_anim_roll, *_anim_kick, *_anim_rocket, *_anim_win;
	CCAction *_current_anim;
	
	CCSprite *_img;
}
+(Player*)cons {
	return [Player node];
}
-(id)init {
	self = [super init];
	
	_img = (CCSprite*)[[[CCSprite node]
					   set_anchor_pt:ccp(0.5,0)] add_to:self];
	[self cons_anims];
	[self run_anim:_anim_run];
	[self set_scale:2];
	return self;
}

-(void)run_anim:(CCAction*)tar {
	if (_current_anim != tar) {
		_current_anim = tar;
		[_img runAction:_current_anim];
	}
}

-(void)cons_anims {
	_anim_stand = animaction_cons(@[
		@"win0005.png"
	], 0.1, TEX_HOBO_BOB);
	
	_anim_run = animaction_cons(@[
		@"running0001.png",
		@"running0002.png",
		@"running0003.png",
		@"running0004.png",
		@"running0005.png",
		@"running0006.png",
		@"running0007.png",
	], 0.025, TEX_HOBO_BOB);
	
	_anim_jump = animaction_cons(@[
		@"jump0001.png",
		@"jump0002.png",
		@"jump0003.png",
		@"jump0004.png",
		@"jump0005.png",
		@"jump0006.png",
	], 0.1, TEX_HOBO_BOB);
	
	_anim_roll = animaction_cons(@[
		@"roll0001.png",
		@"roll0002.png",
		@"roll0003.png",
		@"roll0004.png",
		@"roll0005.png"
	], 0.1, TEX_HOBO_BOB);
	
	_anim_kick = animaction_cons(@[
		@"kick0001.png",
		@"kick0002.png",
		@"kick0003.png",
		@"kick0004.png",
		@"kick0005.png"
	], 0.1, TEX_HOBO_BOB);
	
	_anim_rocket = animaction_cons(@[
		@"rocketing0001.png",
		@"rocketing0002.png",
		@"rocketing0003.png",
		@"rocketing0004.png"
	], 0.1, TEX_HOBO_BOB);
	
	_anim_win = animaction_cons(@[
		@"win0001.png",
		@"win0002.png",
		@"win0003.png",
		@"win0004.png",
		@"win0005.png",
		@"win0006.png"
	], 0.1, TEX_HOBO_BOB);
}
@end
