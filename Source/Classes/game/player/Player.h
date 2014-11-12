#import "CCSprite.h"
#import "GamePhysicsImplementation.h"

typedef enum {
    player_anim_mode_RUN = 1
} player_anim_mode;


@interface Player : CCSprite <PhysicsObject>
+(Player*)cons;
@end
