#import "Island.h"

@interface LineIsland : Island

@property(readwrite,assign) float fill_hei;

+(LineIsland*)cons_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land;
-(CCTexture*)get_tex_fill;

@end
