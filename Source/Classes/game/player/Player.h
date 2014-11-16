#import "CCSprite.h"
#import "GamePhysicsImplementation.h"
@class GameEngineScene;

@interface Player : CCSprite <PhysicsObject>
+(Player*)cons;
-(void)update_game:(GameEngineScene*)g;

-(HitRect)get_hit_rect;

-(void)jump;
-(void)slide;
-(void)kick;
-(void)roll;

-(Island*)last_island;
@end
