#import "GameEngineScene.h"
#import "Player.h"
#import "Common.h"

#import "Resource.h"
#import "LineIsland.h"

@implementation GameEngineScene {
	Player *_player;
	NSMutableArray *_islands;
}

+(GameEngineScene*)cons {
	GameEngineScene* rtv = [GameEngineScene node];
	return rtv;
}

-(id)init {
	self = [super init];
	dt_unset();
	_player = (Player*)[[[Player cons] add_to:self] set_pos:game_screen_pct(0.5, 0.0)];
	
	[[LineIsland cons_pt1:ccp(0,0) pt2:ccp(100,100) height:100 ndir:1 can_land:YES] add_to:self];
	
	return self;
}

-(void)update:(CCTime)delta {
	dt_set(delta);
}

-(void)add_particle:(Particle*)p{}
-(void)add_gameobject:(GameObject*)o{}
-(void)remove_gameobject:(GameObject*)o{}
-(void)set_target_camera:(CameraZoom)tar{}
-(void)shake_for:(float)ct intensity:(float)intensity{}
-(void)freeze_frame:(int)ct{}
-(HitRect)get_viewbox{ return hitrect_cons_xy_widhei(0, 0, 9999, 9999); }

@end
