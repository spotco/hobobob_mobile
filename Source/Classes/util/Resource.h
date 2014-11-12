#import "cocos2d.h"

@interface Resource : NSObject

+(void)load_all;
+(CCTexture*)get_tex:(NSString*)key;

#define TEX_PARTICLES @"particles"
#define TEX_WAREHOUSE_GROUND_TEX @"warehouse_groundtex"
#define TEX_BLANK @"blank"
#define TEX_HOBO_BOB @"hobobob"

@end
