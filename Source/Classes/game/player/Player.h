#import "CCSprite.h"
#import "GamePhysicsImplementation.h"
@class GameEngineScene;

typedef enum {
    player_anim_mode_RUN = 1
} player_anim_mode;


@interface Player : CCSprite <PhysicsObject>
+(Player*)cons;
-(void)update_game:(GameEngineScene*)g;

-(void)jump_anim;
@end
