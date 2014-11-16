#import "GameEngineScene.h"
#import "Player.h"
#import "Common.h"
#import "MapLoader.h"
#import "GamePhysicsImplementation.h"
#import "Island.h"
#import "CCNode+SFGestureRecognizers.h"

#import "Resource.h"
#import "CCTexture_Private.h"

@implementation GameEngineScene {
	Player *_player;
	NSMutableArray *_islands;
	
	CameraZoom _target_camera;
	CameraZoom _current_camera;
	
	CCNode *_game_anchor;
	
	HitRect _cached_worldbounds;
	BOOL _refresh_worldbounds_cache;
	
	CGPoint _player_start_pt;
	CGPoint _last_follow_pt;
	
	CCSprite *_bgwindow;
}

+(GameEngineScene*)cons_with_map_name:(NSString*)map_name {
	GameEngineScene* rtv = [[GameEngineScene node] cons_with_map_name:map_name];
	return rtv;
}

UISwipeGestureRecognizer* swipe_gesture_recognizer(UISwipeGestureRecognizerDirection dir, id tar, SEL sel) {
	UISwipeGestureRecognizer *rtv = [[UISwipeGestureRecognizer alloc] init];
	rtv.direction = dir;
	[rtv addTarget:tar action:sel];
	return rtv;
}

-(id)cons_with_map_name:(NSString*)map_name {
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
	
	GameMap *map = [MapLoader load_map:map_name];
	for (Island *i in map.n_islands) {
		[_islands add:[i add_to:_game_anchor]];
	}
	[Island link_islands:_islands];
	_player_start_pt = map.player_start_pt;
	_player = (Player*)[[[Player cons] add_to:_game_anchor] set_pos:_player_start_pt];
	
	[self addGestureRecognizer:swipe_gesture_recognizer(UISwipeGestureRecognizerDirectionUp, self, @selector(swipe_up))];
	[self addGestureRecognizer:swipe_gesture_recognizer(UISwipeGestureRecognizerDirectionLeft, self, @selector(swipe_left))];
	[self addGestureRecognizer:swipe_gesture_recognizer(UISwipeGestureRecognizerDirectionRight, self, @selector(swipe_right))];
	[self addGestureRecognizer:swipe_gesture_recognizer(UISwipeGestureRecognizerDirectionDown, self, @selector(swipe_down))];
	return self;
}

-(void)swipe_up {
	if (_player.current_island != NULL) {
		Vec3D cur_tangent_vec = [_player.current_island get_tangent_vec];
		Vec3D calc_up = vec_cross(vec_z(), cur_tangent_vec);
		vec_scale_m(&calc_up, 2);
		_player.position = ccp(_player.position.x+calc_up.x,_player.position.y+calc_up.y);
	
		Vec3D tangent = [_player.current_island get_tangent_vec];
		Vec3D up = vec_cross(vec_z(), tangent);
		vec_norm_m(&tangent);
		vec_norm_m(&up);
		Vec3D combined = vec_add(up, tangent);
		vec_norm_m(&combined);
		vec_scale_m(&combined, [_player get_speed]);
		
		_player.vx = combined.x * 0.8;
		_player.vy = combined.y * 2;
		_player.current_island = NULL;
		
		[_player jump];
	}
}

-(void)swipe_down {
	if (_player.current_island == NULL) {
		[_player roll];
		_player.vx *= 0.5;
		_player.vy = -20;
	} else {
		[_player slide];
	}
}
-(void)swipe_left {}
-(void)swipe_right {
	[_player kick];
}

-(void)update:(CCTime)delta {
	dt_set(delta);
	[GamePhysicsImplementation player_move:_player with_islands:_islands];
	
	for (Island *i in _islands) [i update_game:self];
	[_player update_game:self];
	
	[self update_camera];
	[self follow_player];
	
	[_bgwindow setTextureRect:CGRectMake([self get_follow_point].x*0.25, - [self get_follow_point].y*0.25, game_screen().width, game_screen().height)];
	[self check_falloff];
	[self calc_follow_point];
}

-(void)calc_follow_point {
	if ([_player last_island] != NULL) {
		CGPoint calc_pt = [[_player last_island] interpl_line_intersection_pt1:_player.position
																pt2:ccp(
																	_player.position.x-_player.last_island.get_normal_vec.x,
																	_player.position.y-_player.last_island.get_normal_vec.y)];
								
		CGPoint below_island_pos;
		BOOL below_island_found;
		for (Island* i in _islands) {
			if (_player.position.x > i.endX || _player.position.x < i.startX) continue;
			below_island_pos = ccp(
				_player.position.x,
				i.startY+(_player.position.x-i.startX)*((i.endY-i.startY)/(i.endX-i.startX))
			);
			below_island_found = true;
			break;
		}
		if (CGPointDist(_player.position, below_island_pos)*4 < CGPointDist(_player.position, calc_pt)) calc_pt = below_island_pos;

		if (CGPointDist(calc_pt, _last_follow_pt) < 5) {
			_last_follow_pt = calc_pt;
		} else {
			_last_follow_pt = ccp(
				drp(_last_follow_pt.x, calc_pt.x, 5),
				drp(_last_follow_pt.y, calc_pt.y, 5)
			);
		}
	} else {
		_last_follow_pt = _player.position;
	}
}

-(CGPoint)get_follow_point {
	return _last_follow_pt;
}

-(void)follow_player {
	[self follow_point:[self get_follow_point]];
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
		_target_camera.x =  game_screen().width * 0.4 * [self scale] * cosf(tar_ang);
		_target_camera.y = (50/game_screen().height + 1) * game_screen().height * 0.4 * [self scale] * sinf(tar_ang);
		_target_camera.z = 1;
	}
	
	_current_camera.x = drp(_current_camera.x, _target_camera.x, 5);
	_current_camera.y = drp(_current_camera.y, _target_camera.y, 5);
	_current_camera.z = drp(_current_camera.z, _target_camera.z, 5);
}

-(void)check_falloff {
	if (!hitrect_touch([_player get_hit_rect], [self get_world_bounds])) {
		_player.position = _player_start_pt;
		_player.vx = 0;
		_player.vy = 0;
	}
}

-(HitRect)get_world_bounds {
    if (!_refresh_worldbounds_cache) {
        _refresh_worldbounds_cache = YES;
        float min_x = 5000;
        float min_y = 5000;
        float max_x = -5000;
        float max_y = -5000;
        for (Island* i in _islands) {
            max_x = MAX(MAX(max_x, i.endX),i.startX);
            max_y = MAX(MAX(max_y, i.endY),i.startY);
            min_x = MIN(MIN(min_x, i.endX),i.startX);
            min_y = MIN(MIN(min_y, i.endY),i.startY);
        }
        /*for(GameObject* o in game_objects) {
			
            max_x = MAX(max_x, o.position.x);
            max_y = MAX(max_y, o.position.y);
            min_x = MIN(min_x, o.position.x);
            min_y = MIN(min_y, o.position.y);
        }*/
        _cached_worldbounds = hitrect_cons_x1y1_x2y2(min_x, min_y-400, max_x+1000, max_y+1500);
    }
    return _cached_worldbounds;
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}
-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}
-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {}

-(BOOL)fullScreenTouch { return YES; }

-(void)add_particle:(Particle*)p{}
-(void)add_gameobject:(GameObject*)o{}
-(void)remove_gameobject:(GameObject*)o{}
-(void)set_target_camera:(CameraZoom)tar{}
-(void)shake_for:(float)ct intensity:(float)intensity{}
-(void)freeze_frame:(int)ct{}
-(HitRect)get_viewbox{ return hitrect_cons_xy_widhei(_player.position.x-3000, _player.position.y-3000, 6000, 6000); }

@end
