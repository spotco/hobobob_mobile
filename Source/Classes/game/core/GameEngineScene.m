#import "GameEngineScene.h"
#import "Player.h"
#import "Common.h"
#import "MapLoader.h"
#import "GamePhysicsImplementation.h"
#import "Island.h"

@implementation GameEngineScene {
	Player *_player;
	NSMutableArray *_islands;
	
	CameraZoom _target_camera_mapcoord;
	CameraZoom _current_camera_mapcoord;
	CameraZoom _actual_camera_screencoord;
}

+(GameEngineScene*)cons {
	GameEngineScene* rtv = [GameEngineScene node];
	return rtv;
}

-(id)init {
	self = [super init];
	dt_unset();
	_islands = [NSMutableArray array];
	
	GameMap *map = [MapLoader load_map:@"testlevel"];
	for (Island *i in map.n_islands) {
		[_islands add:[i add_to:self]];
	}
	[Island link_islands:_islands];
	_player = (Player*)[[[Player cons] add_to:self] set_pos:map.player_start_pt];
	
	_target_camera_mapcoord = camerazoom_cons(120, 110, 160);
	_current_camera_mapcoord = _target_camera_mapcoord;
	
	return self;
}

-(void)update:(CCTime)delta {
	dt_set(delta);
	[GamePhysicsImplementation player_move:_player with_islands:_islands];
	
	[self update_camera];
	[self follow_player];
}

-(void)follow_player {
	[self follow_point:_player.position];
}

-(void)follow_point:(CGPoint)pt {
	CGSize s = [[CCDirector sharedDirector] viewSize];
	CGPoint halfScreenSize = ccp(s.width/2,s.height/2);
	[self setScale:_actual_camera_screencoord.z];
	[self setPosition:CGPointAdd(
	 ccp(
		 clampf(halfScreenSize.x-pt.x,-999999,999999) * [self scale],
		 clampf(halfScreenSize.y-pt.y,-999999,999999) * [self scale]),
	 ccp(_actual_camera_screencoord.x,_actual_camera_screencoord.y))];
}

-(void)update_camera {
	float scfx = game_screen().width / 480.0;
	float scfy = game_screen().height / 320.0;
	CGPoint fg_offset = ccp(-25 * (CC_CONTENT_SCALE_FACTOR()-1),-10 * (CC_CONTENT_SCALE_FACTOR()-1));
	
	_actual_camera_screencoord.x = scfx * _current_camera_mapcoord.x - 480.0/2 + fg_offset.x;
	_actual_camera_screencoord.y = scfy * _current_camera_mapcoord.y - 320.0/2 + fg_offset.y;
	_actual_camera_screencoord.z = 0.828571-0.00142857*_current_camera_mapcoord.z;
}

-(void)add_particle:(Particle*)p{}
-(void)add_gameobject:(GameObject*)o{}
-(void)remove_gameobject:(GameObject*)o{}
-(void)set_target_camera:(CameraZoom)tar{}
-(void)shake_for:(float)ct intensity:(float)intensity{}
-(void)freeze_frame:(int)ct{}
-(HitRect)get_viewbox{ return hitrect_cons_xy_widhei(0, 0, 9999, 9999); }

@end
