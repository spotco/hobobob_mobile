#import "LineIsland.h"
#import "GameEngineScene.h"
#import "Common.h"
#import "Vec3D.h"
#import "Resource.h"

@implementation LineIsland  {
    BOOL do_draw;
    
	GLRenderObject *main_fill, //main body texture fill
                  *corner_fill; //wedge main body texture between cur and next (optional)
    HitRect cache_hitrect;
    
    BOOL has_gen_hitrect;
    BOOL has_transformed_renderpts;
}

+(LineIsland*)cons_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	LineIsland *new_island = [LineIsland node];
    new_island.fill_hei = height;
    new_island.self.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
    new_island.can_land = can_land;
	[new_island cons_tex];
	
	return new_island;
}

-(id)init {
	self = [super init];
	has_gen_hitrect = NO;
	has_transformed_renderpts = NO;
	self.next = NULL;
	self.prev = NULL;
	self.can_land = NO;
	return self;
}

-(void)check_should_render:(GameEngineScene *)g {
	do_draw = YES;
}


-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    CGSize size = CGSizeMake([self get_hit_rect].x2-[self get_hit_rect].x1, [self get_hit_rect].y2-[self get_hit_rect].y1);
    GLKVector2 center = GLKVector2Make(size.width/2.0, size.height/2.0);
    GLKVector2 extents = GLKVector2Make(size.width/2.0, size.height/2.0);
	
	if (CCRenderCheckVisbility(transform, center, extents))
	{
        CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:self.renderState globalSortOrder:0];
		for (int i = 0; i < main_fill.pts; i++) {
			CCVertex vert;
			vert.position = GLKVector4Make(main_fill.tri_pts[i].x, main_fill.tri_pts[i].y, 0, 1);
			vert.texCoord1 = GLKVector2Make(main_fill.tex_pts[i].x, main_fill.tex_pts[i].y);
			vert.color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
			CCRenderBufferSetVertex(buffer, i, CCVertexApplyTransform(vert, transform));
		}
		CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
		CCRenderBufferSetTriangle(buffer, 1, 1, 2, 3);
	}
}

-(HitRect)get_hit_rect {
    if (has_gen_hitrect == NO) {
        has_gen_hitrect = YES;
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
        cache_hitrect = hitrect_cons_x1y1_x2y2(x_min, y_min, x_max, y_max);
    }
    return cache_hitrect;
}

-(CCTexture*)get_tex_fill { return [Resource get_tex:TEX_WAREHOUSE_GROUND_TEX]; }

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
}



-(void)link_finish {
    if (self.next != NULL) {
        [self cons_corner_tex];
		render_object_transform(corner_fill, [self position]);
    }
    
    if (!has_transformed_renderpts) {
        has_transformed_renderpts = YES;
		render_object_transform(main_fill, [self position]);
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
}


@end
