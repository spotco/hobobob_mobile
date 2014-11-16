#import <Foundation/Foundation.h>

@interface GameMap : NSObject
    @property(readwrite,strong) NSMutableArray *n_islands, *game_objects;
    @property(readwrite,assign) CGPoint player_start_pt;
    @property(readwrite,assign) int assert_links;
    @property(readwrite,assign) float connect_pts_x1,connect_pts_x2,connect_pts_y1,connect_pts_y2;
@end

@interface MapLoader : NSObject
+(GameMap*) load_map:(NSString *)map_file_name;
+(void)add_url_json_cache:(NSString*)url json:(NSString*)json;
@end