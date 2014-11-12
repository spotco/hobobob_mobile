#import "Resource.h"
#import "CCTextureCache.h"
#import "CCTexture_Private.h" 

#define _NSSET(...)  [NSMutableSet setWithArray:@[__VA_ARGS__]]
#define streq(a,b) [a isEqualToString:b]

@interface AsyncImgLoad : NSObject
+(AsyncImgLoad*)load:(NSString *)file key:(NSString*)key ;
@property(readwrite,assign) BOOL finished;
@property(readwrite,strong) NSString *key;
@property(readwrite,strong) CCTexture* tex;
@end

@implementation AsyncImgLoad
+(AsyncImgLoad*)load:(NSString *)file key:(NSString*)key {
	return [[AsyncImgLoad alloc] init_with:file key:key];
}
-(id)init_with:(NSString*)file key:(NSString*)key {
	self = [super init];
	self.finished = NO;
	self.key = key;
	
	[[CCTextureCache sharedTextureCache] addImageAsync:file target:self selector:@selector(on_finish:)];
	return self;
}
-(void)on_finish:(CCTexture*)tex {
	self.tex = tex;
	self.finished = YES;
}
@end

@implementation Resource


static NSDictionary* all_textures;
static NSMutableDictionary* loaded_textures;
static NSSet* dont_load;

+(void)initialize {
}

+(void)load_all {
	loaded_textures = [NSMutableDictionary dictionary];
	all_textures = @{
	 TEX_BLANK:@"blank.png",
	 TEX_PARTICLES:@"particles.png",
	 TEX_HOBO_BOB:@"hobobob.png",
	 TEX_WAREHOUSE_GROUND_TEX:@"warehouse_groundtex.png",
	 TEX_BACKGROUND_BUILDINGS:@"background_buildings.png",
	 TEX_BACKGROUND_SKY:@"background_sky.png",
	 TEX_BACKGROUND_WINDOW:@"window.png"
	};
	
	
	dont_load = _NSSET(
	);
	
	/*
	NSMutableArray *imgloaders = [NSMutableArray array];
	for (NSString *key in all_textures.keyEnumerator) {
		if ([dont_load containsObject:key]) continue;
		[imgloaders addObject:[AsyncImgLoad load:all_textures[key] key:key]];
	}
	NSMutableArray *to_remove = [NSMutableArray array];
	while ([imgloaders count] > 0) {
		for (AsyncImgLoad *loader in imgloaders) {
			if (loader.finished) {
				[loader.tex setAntiAliasTexParameters];
				loaded_textures[loader.key] = loader.tex;
				[to_remove addObject:loader];
				loader.tex = NULL;
			}
		}
		[imgloaders removeObjectsInArray:to_remove];
		[to_remove removeAllObjects];
		[NSThread sleepForTimeInterval:0.001];
	}
	*/
	
	for (NSString *key in all_textures) {
		CCTexture* tex = [[CCTextureCache sharedTextureCache] addImage:all_textures[key]];
		[tex setAntialiased:NO];
		loaded_textures[key] = tex;
	}
}

+(CCTexture*)get_tex:(NSString *)key {
	if (loaded_textures[key] != nil) {
		return loaded_textures[key];
	} else {
		CCTexture* tex = [[CCTextureCache sharedTextureCache] addImage:all_textures[key]];
		[tex setAntialiased:NO];
		loaded_textures[key] = tex;
		return loaded_textures[key];
	}
}

-(void)nullcb{}



@end
