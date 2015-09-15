//
//  GameManager.h
//  Author: Thomas Taylor
//
//  Manages the scenes in the game
//
//  15/12/2011: Created class
//

#import "cocos2d.h"
#import "CommonDataTypes.h"
#import <Foundation/Foundation.h>
#import "Level.h"

@interface GameManager : NSObject

{
    CCArray* levelData;
    Difficulty levelDifficulty;
    SceneTypes currentScene;
    Level* currentLevel;
    BOOL gamePaused;
    BOOL debug;
    BOOL demo;
}

@property (readonly) SceneTypes currentScene;
@property (readwrite, retain) Level* currentLevel;
@property (readwrite) BOOL gamePaused;
@property (readwrite) BOOL debug;
@property (readwrite) BOOL demo;

+(GameManager*)sharedGameManager;
-(void)loadLevelData;
-(void)loadLevel:(int)levelID;
-(void)loadRandomLevel;
-(void)runSceneWithID:(SceneTypes)_sceneID;
-(void)pauseGame;
-(void)resumeGame;
-(void)incrementSecondCounter;
-(void)resetSecondCounter;
-(NSString*)getGameTimeInMins;
-(int)getGameTimeInSecs;
-(void)setLevelDifficulty:(Difficulty)_difficulty;
-(int)getLevelCount;

@end
