#import "GamePhysicsImplementation.h"
#import "Island.h"
#import "Vec3D.h"

//Used in move along island
#define ABS_MAX_SPEED 20
#define SLOPE_ACCEL 0.5
#define FRICTION 0.96
#define TO_GROUND_ROTATION_SPEED 0.3

//Used in freefall
#define CENTERING_UP_VEC_SPD 0.07
#define MAX_LOSS 0.3

@implementation GamePhysicsImplementation

+(void)player_move:(id<PhysicsObject>)player with_islands:(NSMutableArray*)islands {
    if (player.current_island == NULL) {
        player.position = [GamePhysicsImplementation player_free_fall:player islands:islands];
    } else {
        player.position = [GamePhysicsImplementation player_move_along_island:player islands:islands];
    }
}

+(CGPoint)player_move_along_island:(id<PhysicsObject>)player islands:(NSMutableArray*)islands {
    float MIN_SPEED = [player get_speed];
    
    Island *i = player.current_island;
    Vec3D tangent_vec = [i get_tangent_vec];
    
    player.last_ndir = (i.ndir < 0)?-1:1;
    
    if (tangent_vec.y < 0) {
        float ang = vec_ang_rad(tangent_vec);
        if (ang < -M_PI_2) {
            ang = ang + M_PI;
        }
        float pct = ABS(ang/M_PI_2);
        
        player.vx += SLOPE_ACCEL *pct;
        player.vy += SLOPE_ACCEL *pct;
        
        MIN_SPEED += (ABS_MAX_SPEED - MIN_SPEED)*(pct);
    }
    

    float mov_speed = sqrtf(powf(player.vx, 2) + powf(player.vy, 2)) * dt_scale_get();
    
    if (mov_speed > ABS_MAX_SPEED * dt_scale_get()) {
        mov_speed = ABS_MAX_SPEED;
    }
    if (mov_speed > MIN_SPEED  * dt_scale_get()) {
        player.vx *= FRICTION;
        player.vy *= FRICTION;
    }
    if (mov_speed < MIN_SPEED) {
        float acc = (MIN_SPEED - mov_speed)/5;
        player.vx += acc;
        player.vy += acc;
    }
	
	player.up_vec = vec_cross(vec_z(), tangent_vec);
	player.up_vec = vec_norm(player.up_vec);
	player.up_vec = vec_scale(player.up_vec,i.ndir);
    
	
	float tar_rad = -vec_ang_rad(tangent_vec);
    float tar_deg = rad_to_deg(tar_rad);
    float dir = shortest_dist_from_cur(player.rotation, tar_deg);
    player.rotation += dir*TO_GROUND_ROTATION_SPEED;
    
    CGPoint position_final;
    
    if (player.movedir > 0) {
		
        float t = [i get_t_given_position:player.position];
        float t_final = t+mov_speed;
        position_final = [i get_position_given_t:t_final];
        
        if (position_final.x == SEG_NO_VALUE() || position_final.y == SEG_NO_VALUE()) {
            if (i.next != NULL) {
                float t_sum = mov_speed;
                t_sum -= [i get_t_given_position:ccp(i.endX,i.endY)] - t;
                player.current_island = i.next;
                if ([player.current_island get_position_given_t:t_sum].x != SEG_NO_VALUE() && [player.current_island get_position_given_t:t_sum].y != SEG_NO_VALUE()) {
                    position_final = [player.current_island get_position_given_t:t_sum];
                } else {
                    position_final = ccp(player.current_island.endX,player.current_island.endY);
                }
                
            } else {
                
                position_final = ccp(player.position.x + tangent_vec.x*mov_speed, player.position.y + tangent_vec.y*mov_speed);
                
                player.current_island = NULL;
                player.vx = tangent_vec.x * mov_speed / dt_scale_get();
                player.vy = tangent_vec.y * mov_speed / dt_scale_get();
            }
        }
        
    } else {
        float t = [i get_t_given_position:player.position];
        float t_final = t+mov_speed*player.movedir;
        if (t_final >= 0) {
            position_final = [i get_position_given_t:t_final];
            
        } else {
            float remainder_t = ABS(t_final);
            while (remainder_t > 0) {
                i = i.prev;
                if (i != NULL) {
                    if (remainder_t < i.t_max) {
                        player.current_island = i;
                        position_final = [i get_position_given_t:i.t_max - remainder_t];
                        break;
                        
                    } else {
                        remainder_t -= i.t_max;
                        
                    }
                    
                } else {
                    player.current_island = NULL;
                    position_final = ccp(
						player.position.x + tangent_vec.x*mov_speed*player.movedir,
						player.position.y + tangent_vec.y*mov_speed*player.movedir
					);
                    player.vx = tangent_vec.x * mov_speed * player.movedir;
                    player.vy = tangent_vec.y * mov_speed * player.movedir;
                    break;
                    
                }
            }
            
        }
        
    }
    
    return position_final;
}

+(CGPoint)player_free_fall:(id<PhysicsObject>)player islands:(NSMutableArray*)islands {
    float GRAVITY = -0.5;
    player.up_vec = vec_cons(0, 1, 0);
    
    CGPoint player_pre = player.position;
    CGPoint player_post = ccp(player.position.x+player.vx * dt_scale_get(),player.position.y+player.vy * dt_scale_get());
    line_seg player_mov = line_seg_cons(player_pre, player_post);
    Vec3D player_mov_vec = vec_cons(player_mov.b.x - player_mov.a.x, player_mov.b.y - player_mov.a.y,0);
    
    Island* contact_island = NULL;
    CGPoint contact_intersection;
    line_seg contact_segment;
    
    for (Island *i in islands) {     
        line_seg island_seg = [i get_line_seg];
        CGPoint intersection = line_seg_intersection(player_mov, island_seg);
        Vec3D inormal_vec = [i get_normal_vec];
        if (
			i.can_land &&
			intersection.x != SEG_NO_VALUE() &&
			intersection.y != SEG_NO_VALUE() &&
			ABS(vec_rad_angle_between(player_mov_vec, inormal_vec)) >= M_PI / 2
		) {
            contact_island = i;
            contact_intersection = intersection;
            contact_segment = island_seg;
        }
    }
    
    if (contact_island != NULL) {
        float extrat = sqrtf(powf(player_post.x - contact_intersection.x,2)+ powf(player_post.y - contact_intersection.y,2))/ dt_scale_get();
        float cur_t = [contact_island get_t_given_position:contact_intersection];
        
        if (extrat+cur_t > contact_island.t_max) {
            player_post = ccp(contact_island.endX,contact_island.endY);
        } else {
            player_post = [contact_island get_position_given_t:cur_t+extrat];
        }
        player.current_island = contact_island;
        
        Vec3D a = vec_cons(player_mov.b.x - player_mov.a.x,player_mov.b.y - player_mov.a.y,0);
        Vec3D b = vec_cons(contact_segment.b.x - contact_segment.a.x,contact_segment.b.y - contact_segment.a.y,0);
        float theta = vec_rad_angle_between(a, b);
        if (theta < M_PI) {
            player.vx *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
            player.vy *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
        } else {
            player.vx *= MAX_LOSS * dt_scale_get();
            player.vy *= MAX_LOSS * dt_scale_get();
        }
        
    } else {
        float grav_const = GRAVITY;
        player.vx += grav_const * player.up_vec.x * dt_scale_get();
        player.vy += grav_const * player.up_vec.y * dt_scale_get();
    }
    
	//note: rotation code for this is in Player.m
    return player_post;
}


@end
