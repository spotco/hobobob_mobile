#import "LineIsland.h"
#import "GameEngineScene.h"
#import "Common.h"
#import "Vec3D.h"
#import "Resource.h"
#import "CCTexture_Private.h"

@implementation LineIsland  {
	GLRenderObject *main_fill, //main body texture fill
                  *corner_fill; //wedge main body texture between cur and next (optional)
				
	BOOL do_draw;
}

+(LineIsland*)cons_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	LineIsland *new_island = [LineIsland node];
    new_island.fill_hei = height;
    new_island.self.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = CGPointZero;
	new_island.can_land = can_land;
	[new_island cons_tex];
	
	return new_island;
}

-(id)init {
	self = [super init];
	self.next = NULL;
	self.prev = NULL;
	self.can_land = NO;
	do_draw = NO;
	return self;
}

-(void)update_game:(GameEngineScene *)g {
	do_draw = hitrect_touch([g get_viewbox], [self get_hit_rect]);
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	if (do_draw)
	{
        render_object_draw(renderer, self.renderState, transform, main_fill);
		if (corner_fill != NULL) render_object_draw(renderer, self.renderState, transform, corner_fill);
	}
}

-(HitRect)get_hit_rect {
	int x_max = main_fill.tri_pts[0].x;
	int x_min = main_fill.tri_pts[0].x;
	int y_max = main_fill.tri_pts[0].y;
	int y_min = main_fill.tri_pts[0].y;
	for (int i = 0; i < 4; i++) {
		x_max = MAX(main_fill.tri_pts[i].x,x_max);
		x_min = MIN(main_fill.tri_pts[i].x,x_min);
		y_max = MAX(main_fill.tri_pts[i].y,y_max);
		y_min = MIN(main_fill.tri_pts[i].y,y_min);
	}
	return hitrect_cons_x1y1_x2y2(x_min, y_min, x_max, y_max);
}

-(CCTexture*)get_tex_fill {
	CCTexture *rtv = [Resource get_tex:TEX_WAREHOUSE_GROUND_TEX];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[rtv setTexParameters:&par];
	return rtv;
}

-(void)cons_tex {
	[self setTexture:[self get_tex_fill]];
    //init islandfill
    main_fill = render_object_cons([self get_tex_fill], 4);
	
	fCGPoint *tri_pts = main_fill.tri_pts;
    
    Vec3D v3t2 = vec_cons((self.endX - self.startX),(self.endY - self.startY),0);
    Vec3D vZ = vec_z();
    Vec3D v3t1 = vec_cross(v3t2, vZ);
    
	vec_norm_m(&v3t1);
	vec_scale_m(&v3t1, self.ndir);
	
    float taille = self.fill_hei;
    
    /**
     32
     10
     **/
    tri_pts[3] = fccp(0,0);
    tri_pts[2] = fccp(self.endX-self.startX,self.endY-self.startY);
    tri_pts[1] = fccp(0+v3t1.x * taille,0+v3t1.y * taille);
    tri_pts[0] = fccp(self.endX-self.startX +v3t1.x * taille ,self.endY-self.startY +v3t1.y * taille);
	
    for (int i = 0; i < 4; i++) {
        main_fill.tex_pts[i] = fccp(( main_fill.tri_pts[i].x+self.startX)/main_fill.texture.pixelWidth,
                                   ( main_fill.tri_pts[i].y+self.startY)/main_fill.texture.pixelHeight);
    }
	render_object_transform(main_fill, ccp(self.startX,self.startY));
}



-(void)link_finish {
    if (self.next != NULL) {
        [self cons_corner_tex];
    }
}

-(void)cons_corner_tex {
	if (![[self.next class] isSubclassOfClass:[LineIsland class]]) return;
    corner_fill = render_object_cons([self get_tex_fill], 3);
    
    fCGPoint* tri_pts = corner_fill.tri_pts;
    Vec3D v3t2 = vec_cons(self.endX - self.startX,self.endY - self.startY,0);
    Vec3D vZ = vec_z();
    Vec3D v3t1 = vec_cross(v3t2, vZ);
	
	vec_norm_m(&v3t1);
	vec_scale_m(&v3t1, self.ndir);
    
    tri_pts[0] = fccp(self.endX-self.startX,self.endY-self.startY);
    tri_pts[1] = fccp(self.endX+v3t1.x*self.fill_hei-self.startX,self.endY+v3t1.y*self.fill_hei-self.startY);
    
    v3t2 = vec_cons((self.next.endX - self.next.startX),(self.next.endY - self.next.startY),0);
    v3t1 = vec_cross(v3t2, vZ);
    
	vec_norm_m(&v3t1);
	vec_scale_m(&v3t1, self.ndir);
    
	tri_pts[2] = fccp(
		self.next.startX+v3t1.x * ([(LineIsland*)self.next fill_hei])-self.startX,
		self.next.startY+v3t1.y * ([(LineIsland*)self.next fill_hei])-self.startY
	);
    
    for (int i = 2; i < 4; i++) {
        corner_fill.tex_pts[i] = fccp(( corner_fill.tri_pts[i].x+self.startX) / corner_fill.texture.pixelWidth,
                                     ( corner_fill.tri_pts[i].y+self.startY) / corner_fill.texture.pixelHeight);
    }
    /**
     main fill
     32
     10
     **/
    
    /**
     corner_fill:
        0
     cur12next
     **/
    corner_fill.tex_pts[0] = main_fill.tex_pts[2];
    corner_fill.tex_pts[1] = main_fill.tex_pts[0];
    corner_fill.tex_pts[2] = fccp(
        (corner_fill.tri_pts[2].x - corner_fill.tri_pts[1].x)/corner_fill.texture.pixelWidth + corner_fill.tex_pts[1].x,
        (corner_fill.tri_pts[2].y - corner_fill.tri_pts[1].y)/corner_fill.texture.pixelHeight + corner_fill.tex_pts[1].y
    );
	
	render_object_transform(corner_fill, ccp(self.startX,self.startY));
}


@end
