#import "Island.h"

@implementation Island

@synthesize startX, startY, endX, endY, ndir, t_min, t_max;
@synthesize next,prev;
@synthesize can_land;

+(int) link_islands:(NSMutableArray*)islands {
    int ct = 0;
    for(Island *i in islands) {
        if (i.next != NULL) {
            continue;
        }
        
        for(Island *j in islands) {
            if (fuzzyeq(i.endX, j.startX, 0.1) && fuzzyeq(i.endY, j.startY, 0.1)) {
                i.next = j;
                j.prev = i;
                ct++;
                break;
            }
        }
    }
    for (Island *i in islands) {
        [i link_finish];
    }
    for (Island *i in islands) {
        [i post_link_finish];
    }
    return ct;
}

-(void)set_pt1:(CGPoint)start pt2:(CGPoint)end {
	startX = start.x;
	startY = start.y;
	endX = end.x;
	endY = end.y;
	
	self.t_min = 0;
    self.t_max = sqrtf(powf(self.endX - self.startX, 2) + powf(self.endY - self.startY, 2));
}

-(void)post_link_finish {}
-(void)link_finish {}

-(Vec3D)get_normal_vec {
    Vec3D line_vec = vec_cons(endX-startX, endY-startY, 0);
    Vec3D normal_vec = vec_cross(vec_z(), line_vec);
    vec_norm_m(&normal_vec);
	vec_scale_m(&normal_vec, ndir);
    return normal_vec;
}

-(line_seg)get_line_seg {
    return line_seg_cons(ccp(startX,startY), ccp(endX,endY));
}

-(Vec3D)get_tangent_vec {
	return vec_cons_norm(endX-startX, endY-startY, 0);
}

-(float)get_t_given_position:(CGPoint)position {
    float dx = powf(position.x - startX, 2);
    float dy = powf(position.y - startY, 2);
    float f = sqrtf( dx+dy );
    return f;
}

-(CGPoint)get_position_given_t:(float)t {
    if (t > t_max || t < t_min) {
        return ccp(SEG_NO_VALUE(),SEG_NO_VALUE());
    } else {
        float frac = t/t_max;
        Vec3D dir_vec = vec_cons(endX-startX, endY-startY, 0);
		vec_scale_m(&dir_vec, frac);
        CGPoint pos = ccp(startX+dir_vec.x,startY+dir_vec.y);
        return pos;
    }
}

@end
