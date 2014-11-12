#import "cocos2d.h"
#import "Common.h"
@class Island;

@protocol PhysicsObject <NSObject>
    @property(readwrite,assign) float vx,vy,scaleX,scaleY,rotation;
    @property(readwrite,assign) int last_ndir, movedir;
    @property(readwrite,assign) Vec3D up_vec;
    @property(readwrite,assign) CGPoint position;

	@property(readwrite,strong) Island* current_island;
    -(float)get_speed;
	-(float)get_gravity;
@end

@interface GamePhysicsImplementation:NSObject
+(void)player_move:(id<PhysicsObject>)player with_islands:(NSMutableArray*)islands;
@end
