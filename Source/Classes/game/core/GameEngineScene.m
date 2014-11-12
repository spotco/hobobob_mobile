#import "GameEngineScene.h"
#import "Player.h"
#import "Common.h"
#import "MapLoader.h"
#import "GamePhysicsImplementation.h"
#import "Island.h"

#import "Resource.h"
#import "CCTexture_Private.h"

@implementation GameEngineScene {
	Player *_player;
	NSMutableArray *_islands;
	
	CameraZoom _target_camera;
	CameraZoom _current_camera;
	
	CCNode *_game_anchor;
	
	CCSprite *_bgwindow;
}

+(GameEngineScene*)cons {
	GameEngineScene* rtv = [GameEngineScene node];
	return rtv;
}

-(id)init {
	self = [super init];
	self.userInteractionEnabled = YES;
	dt_unset();
	_current_camera = camerazoom_cons(0, 0, 0.1);
	_islands = [NSMutableArray array];
	
	_game_anchor = [[CCNode node] add_to:self];
	
	CCSprite *bgsky = (CCSprite*)[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_BACKGROUND_SKY]] set_anchor_pt:ccp(0,0)] add_to:self z:-1];
	scale_to_fit_screen_x(bgsky);
	scale_to_fit_screen_y(bgsky);
	
	CCSprite *bgbldgs = (CCSprite*)[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_BACKGROUND_BUILDINGS]] set_anchor_pt:ccp(0,0)] add_to:self z:-1];
	scale_to_fit_screen_x(bgbldgs);
	scale_to_fit_screen_y(bgbldgs);
	bgbldgs.scaleY = bgbldgs.scaleY*0.75;
	
	_bgwindow = (CCSprite*)[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_BACKGROUND_WINDOW]] set_anchor_pt:ccp(0,0)] add_to:self z:-1];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[_bgwindow.texture setTexParameters:&par];
	[_bgwindow setTextureRect:CGRectMake(0, 0, game_screen().width, game_screen().height)];
	
	GameMap *map = [MapLoader load_map:@"testlevel"];
	for (Island *i in map.n_islands) {
		[_islands add:[i add_to:_game_anchor]];
	}
	[Island link_islands:_islands];
	_player = (Player*)[[[Player cons] add_to:_game_anchor] set_pos:map.player_start_pt];
	
	return self;
}

-(void)update:(CCTime)delta {
	dt_set(delta);
	[GamePhysicsImplementation player_move:_player with_islands:_islands];
	
	for (Island *i in _islands) [i update_game:self];
	[_player update_game:self];
	
	[self update_camera];
	[self follow_player];
	
	[_bgwindow setTextureRect:CGRectMake(_player.position.x*0.25, -_player.position.y*0.25, game_screen().width, game_screen().height)];
}

-(void)follow_player {
	[self follow_point:_player.position];
}

-(void)follow_point:(CGPoint)pt {
	CGSize s = [CCDirector sharedDirector].viewSize;
	CGPoint halfScreenSize = ccp(s.width/2,s.height/2);
	[_game_anchor setScale:_current_camera.z];
	[_game_anchor setPosition:CGPointAdd(
	 ccp(
		 clampf(halfScreenSize.x-pt.x,-999999,999999) * [self scale],
		 clampf(halfScreenSize.y-pt.y,-999999,999999) * [self scale]),
	 ccp(_current_camera.x,_current_camera.y))];
}

-(void)update_camera {
	if (_player.current_island != NULL) {
		float tar_ang = vec_ang_rad(_player.up_vec) + 3.14 * 0.75;
		_target_camera.x = game_screen().width * 0.35 * [self scale] * cosf(tar_ang);
		_target_camera.y = game_screen().height * 0.35 * [self scale] * sinf(tar_ang);
		_target_camera.z = 1;
	} else {
		_target_camera.x = 0;
		_target_camera.y = 0;
		_target_camera.z = 1;
	}
	
	_current_camera.x = drp(_current_camera.x, _target_camera.x, 5);
	_current_camera.y = drp(_current_camera.y, _target_camera.y, 5);
	_current_camera.z = drp(_current_camera.z, _target_camera.z, 5);
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	if (_player.current_island != NULL) {
		float mov_speed = sqrtf(powf(_player.vx, 2) + powf(_player.vy, 2));
	
		Vec3D tangent = [_player.current_island get_tangent_vec];
		Vec3D up = vec_cross(vec_z(), tangent);
		vec_norm_m(&tangent);
		vec_norm_m(&up);
		
		vec_scale_m(&tangent, mov_speed);
		vec_scale_m(&up, _player.current_island.ndir * 20);
		
		Vec3D combined = vec_add(up, tangent);
		Vec3D cur_tangent_vec = [_player.current_island get_tangent_vec];
		Vec3D calc_up = vec_cross(vec_z(), cur_tangent_vec);
		vec_scale_m(&calc_up, 2);
		_player.position = ccp(_player.position.x+calc_up.x,_player.position.y+calc_up.y);
		
		_player.vx = combined.x;
		_player.vy = combined.y;
		_player.current_island = NULL;
		
		[_player jump_anim];
	}
}
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}
-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}

-(void)add_particle:(Particle*)p{}
-(void)add_gameobject:(GameObject*)o{}
-(void)remove_gameobject:(GameObject*)o{}
-(void)set_target_camera:(CameraZoom)tar{}
-(void)shake_for:(float)ct intensity:(float)intensity{}
-(void)freeze_frame:(int)ct{}
-(HitRect)get_viewbox{ return hitrect_cons_xy_widhei(0, 0, 9999, 9999); }

@end
