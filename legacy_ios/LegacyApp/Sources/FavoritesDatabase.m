#import "FavoritesDatabase.h"
#import <sqlite3.h>

@interface FavoritesDatabase ()

@property (nonatomic, assign) sqlite3 *db;

@end

@implementation FavoritesDatabase

+ (instancetype)sharedDatabase {
    static FavoritesDatabase *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[FavoritesDatabase alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self openDatabase];
    }
    return self;
}

- (void)openDatabase {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = paths.firstObject;
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *dbPath = [directory stringByAppendingPathComponent:@"music_favorites.sqlite"];

    if (sqlite3_open(dbPath.UTF8String, &_db) != SQLITE_OK) {
        _db = NULL;
        return;
    }
    const char *createTableSQL = "CREATE TABLE IF NOT EXISTS favorites (track_id INTEGER PRIMARY KEY);";
    sqlite3_exec(_db, createTableSQL, NULL, NULL, NULL);
}

- (BOOL)isFavorite:(NSInteger)trackId {
    if (!self.db) {
        return NO;
    }
    const char *sql = "SELECT 1 FROM favorites WHERE track_id = ?;";
    sqlite3_stmt *statement = NULL;
    BOOL result = NO;
    if (sqlite3_prepare_v2(self.db, sql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, trackId);
        result = sqlite3_step(statement) == SQLITE_ROW;
    }
    sqlite3_finalize(statement);
    return result;
}

- (void)setFavorite:(BOOL)favorite forTrackId:(NSInteger)trackId {
    if (!self.db) {
        return;
    }
    const char *sql = favorite
        ? "INSERT OR REPLACE INTO favorites (track_id) VALUES (?);"
        : "DELETE FROM favorites WHERE track_id = ?;";
    sqlite3_stmt *statement = NULL;
    if (sqlite3_prepare_v2(self.db, sql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int64(statement, 1, trackId);
        sqlite3_step(statement);
    }
    sqlite3_finalize(statement);
}

@end
