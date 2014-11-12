#import "MapLoader.h"

#import "LineIsland.h"

@implementation GameMap
    @synthesize assert_links;
    @synthesize connect_pts_x1,connect_pts_x2,connect_pts_y1,connect_pts_y2;
    @synthesize game_objects,n_islands;
    @synthesize player_start_pt;
@end

@implementation MapLoader

#define DOTMAP @"map"

static NSMutableDictionary* cached_json;

+(void) precache_map:(NSString *)map_file_name {
    if (cached_json == NULL) {
        cached_json = [[NSMutableDictionary alloc] init];
    }
    if ([cached_json objectForKey:map_file_name]) {
        return;
    }
    
    NSString *islandFilePath = [[NSBundle mainBundle] pathForResource:map_file_name ofType:DOTMAP];
	NSString *islandInputStr = [[NSString alloc] initWithContentsOfFile : islandFilePath encoding:NSUTF8StringEncoding error:NULL];
   
#if 0
	NSDictionary *j_map_data = [islandInputStr objectFromJSONString];
#else
	NSError *e = nil;
	NSDictionary *j_map_data = [NSJSONSerialization
						  JSONObjectWithData:[islandInputStr dataUsingEncoding:NSUTF8StringEncoding]
						  options: NSJSONReadingMutableContainers
						  error: &e];
	if (e) NSLog(@"%@",e);
#endif
	
	[cached_json setValue:j_map_data forKey:map_file_name];
}

+(NSDictionary*)get_jsondict:(NSString *)map_file_name {
	
    if (![cached_json objectForKey:map_file_name]) {
        [MapLoader precache_map:map_file_name];
    }
    return [cached_json objectForKey:map_file_name];
}

+(GameMap*) load_map:(NSString *)map_file_name {
    NSDictionary *j_map_data = [MapLoader get_jsondict:map_file_name];
    
    NSArray *islandArray = [j_map_data objectForKey:(@"islands")];
	int islandsCount = (int)[islandArray count];
	
    GameMap *map = [[GameMap alloc] init];
    map.n_islands = [[NSMutableArray alloc] init];
    map.game_objects = [[NSMutableArray alloc] init];
    
    float start_x = getflt(j_map_data, @"start_x");
	float start_y = getflt(j_map_data, @"start_y");
    map.player_start_pt = ccp(start_x,start_y);
    
    int assert_links = ((NSString*)[j_map_data objectForKey:(@"assert_links")]).intValue;
    map.assert_links = assert_links;
    
    NSDictionary* connect_pts = [j_map_data objectForKey:(@"connect_pts")];
    if(connect_pts != NULL) {
        map.connect_pts_x1 = getflt(connect_pts, @"x1");
        map.connect_pts_x2 = getflt(connect_pts, @"x2");
        map.connect_pts_y1 = getflt(connect_pts, @"y1");
        map.connect_pts_y2 = getflt(connect_pts, @"y2");
    }
    
	for(int i = 0; i < islandsCount; i++){
		NSDictionary *currentIslandDict = (NSDictionary *)[islandArray objectAtIndex:i];
        CGPoint start = ccp(getflt(currentIslandDict,@"x1"),getflt(currentIslandDict,@"y1"));
        CGPoint end = ccp(getflt(currentIslandDict,@"x2"),getflt(currentIslandDict,@"y2"));
        
        Island *currentIsland;
        
        float height = getflt(currentIslandDict, @"hei");
        NSString *ndir_str = [currentIslandDict objectForKey:@"ndir"];
        
        float ndir = 0;
        if ([ndir_str isEqualToString:@"left"]) {
            ndir = 1;
        } else if ([ndir_str isEqualToString:@"right"]) {
            ndir = -1;
        }
        BOOL can_land = ((NSString *)[currentIslandDict objectForKey:@"can_fall"]).boolValue;
        
        NSString *ground_type = (NSString *)[currentIslandDict objectForKey:@"ground"];
        
        if (ground_type == NULL || [ground_type isEqualToString:@"open"]) {
			currentIsland = [LineIsland cons_pt1:start pt2:end height:height ndir:ndir can_land:can_land];
        } else {
            NSLog(@"unrecognized ground type!!");
            continue;
        }
		[map.n_islands addObject:currentIsland];
	}
    
    
    NSArray *coins_array = [j_map_data objectForKey:@"objects"];
    
    for(int i = 0; i < [coins_array count]; i++){
		int cur_size = (int)[map.game_objects count];
        NSDictionary *j_object = (NSDictionary *)[coins_array objectAtIndex:i];
        NSString *type = (NSString *)[j_object objectForKey:@"type"];
        
		/*
        if([type isEqualToString:@"dogbone"]){
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            int bid = ((NSString*)[j_object  objectForKey:@"bid"]).intValue;
            [map.game_objects addObject:[DogBone cons_x:x y:y bid:bid]];
        }
		*/
		
		if ([map.game_objects count] == cur_size) {
			NSLog(@"map loader error on:%@",type);
		}
		
    }
    return map;
}

float getflt(NSDictionary* j_object,NSString* key) {
    return ((NSString*)[j_object objectForKey:key]).floatValue;
}

BOOL getbool(NSDictionary* j_object,NSString* key) {
    return ((NSString*)[j_object objectForKey:key]).boolValue;
}
@end