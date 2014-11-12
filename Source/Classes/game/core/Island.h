#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Common.h"
#import "GameObject.h"

@class GameEngineLayer;

@interface Island : GameObject

@property(readwrite,assign) float startX, startY, endX, endY, ndir, t_min, t_max;
@property(readwrite,strong) Island *next, *prev;
@property(readwrite,assign) BOOL can_land;

+(int)link_islands:(NSMutableArray*)islands;

-(void)link_finish;
-(void)post_link_finish;

-(void)set_pt1:(CGPoint)start pt2:(CGPoint)end;

-(Vec3D)get_normal_vec;
-(line_seg)get_line_seg;
-(float)get_t_given_position:(CGPoint)position;
-(CGPoint)get_position_given_t:(float)t;
-(Vec3D)get_tangent_vec;

@end
