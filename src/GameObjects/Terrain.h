//
//  Terrain.h
//  Author: Thomas Taylor
//
//  A basic class to contain terrain relevant data
//
//  05/01/2012: Created class
//

#import "GameManager.h"
#import "GameObject.h"

@interface Terrain : GameObject 

{
    NSString* filename;
    BOOL isWall;
}

@property (readonly) BOOL isWall;

-(id)initObjectType:(GameObjectType)_type withPosition:(CGPoint)_position andFilename:(NSString*)_filename isWall:(BOOL)_isWall;

@end
