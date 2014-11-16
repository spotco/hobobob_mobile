#import "Player.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineScene.h"

#import "CCTexture_Private.h"

@implementation Player {
	CCAction *_anim_stand, *_anim_run, *_anim_jump, *_anim_roll, *_anim_kick, *_anim_rocket, *_anim_win, *_anim_slide;
	CCAction *_current_anim;
	
	CCSprite *_img;
	
	float _anim_ct;
	
	Island *_last_island;
}

@synthesize vx,vy;
@synthesize current_island;
@synthesize up_vec;
@synthesize last_ndir,movedir;

-(Island*)last_island {
	return _last_island;
}

-(float)get_speed {
	return 15;
}
-(float)get_gravity {
	return -1.5;
}

+(Player*)cons {
	return [Player node];
}
-(id)init {
	self = [super init];
	
	_img = (CCSprite*)[[[CCSprite node]
					   set_anchor_pt:ccp(1,0)] add_to:self];
	[self cons_anims];
	[self run_anim:_anim_run];
	[self set_scale:2];
	self.movedir = 1;
	
	return self;
}

-(void)update_game:(GameEngineScene*)g {
	if (current_island != NULL && _anim_ct <= 0) {
		[self run_anim:_anim_run];
	}
	_anim_ct-=dt_scale_get();
	if (current_island != NULL) _last_island = current_island;
}

-(void)jump {
	[self run_anim:_anim_jump];
}
-(void)slide {
	[self run_anim:_anim_slide];
	_anim_ct = 25;
}
-(void)kick {
	[self run_anim:_anim_kick];
	_anim_ct = 25;
}
-(void)roll {
	[self run_anim:_anim_roll];
	_anim_ct = 25;
}

-(void)run_anim:(CCAction*)tar {
	if (_current_anim != tar) {
		_current_anim = tar;
		[_img stopAllActions];
		[_img runAction:_current_anim];
	}
}

-(HitRect)get_hit_rect {
	return hitrect_cons_xy_widhei(self.position.x-10, self.position.y, 20, 40);
}

-(void)cons_anims {
	_anim_stand = animaction_cons(@[
		@"jump0006.png"
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
	
	_anim_jump = animaction_nonrepeating_cons(@[
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
	], 0.025, TEX_HOBO_BOB);
	
	_anim_kick = animaction_cons(@[
		@"kick0001.png",
		@"kick0002.png",
		@"kick0003.png",
		@"kick0004.png",
		@"kick0005.png"
	], 0.025, TEX_HOBO_BOB);
	
	_anim_rocket = animaction_cons(@[
		@"rocketing0001.png",
		@"rocketing0002.png",
		@"rocketing0003.png",
		@"rocketing0004.png"
	], 0.1, TEX_HOBO_BOB);
	
	_anim_slide = animaction_cons(@[@"slide.png"], 10, TEX_HOBO_BOB);
	
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
