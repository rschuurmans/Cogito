//
//  GameplayLayer.m
//  Author: Thomas Taylor
//
//  The main layer in the game, handles 
//  the main 'gameplay' elements
//
//  13/11/2011: Created class
//

#import "GameplayLayer.h"

@interface GameplayLayer()

-(void)initDisplay;
-(void)update:(ccTime)deltaTime;
-(NSString*)getUpdatedLemmingString;
-(NSString*)getUpdatedTimeString;
-(void)addLemming;
-(void)createLemmingAtLocation:(CGPoint)spawnLocation withHealth:(int)health withZValue:(int)zValue withID:(int)ID;
-(void)incrementGameTimer;
-(void)onPauseButtonPressed;

@end

@implementation GameplayLayer

#pragma mark -
#pragma mark Memory Allocation

-(void)dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Initialisation

/**
 * Initialises the layer
 * @return self
 */
-(id)init 
{            
    self = [super init];
 
    if (self != nil) 
    {
        self.isTouchEnabled = YES; // enable touch
        srandom(time(NULL)); // set up a random number generator
                
        // reset the relevant data
        [[LemmingManager sharedLemmingManager] reset];
        [[GameManager sharedGameManager] resetSecondCounter];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", kFilenameDefAtlas]];
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", kFilenameDefAtlas]];
                
        [self addChild:sceneSpriteBatchNode z:0];
        [self initDisplay]; // set up the labels/buttons
        
        // Get the level data from GameManager
        [[GameManager sharedGameManager] loadRandomLevel];
        
        currentTerrainLayer = [[TerrainLayer alloc] init:[[GameManager sharedGameManager] currentLevel].name];
        [self addChild:currentTerrainLayer z:kTerrainZValue];
        
        [self schedule:@selector(addLemming) interval:kLemmingSpawnSpeed]; // create some lemmings
        [self scheduleUpdate]; // set the update method to be called every frame
    }
            
    return self;
}

/**
 * Creates the in-game 'menu'
 * Initialises any buttons and labels in the layer
 */
-(void)initDisplay
{    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    // add the pause button
    
    /*CCMenuItem *pauseButton = [CCMenuItemImage itemFromNormalImage:@"Pause.png" selectedImage:@"Pause_down.png" target:self selector:@selector(onPauseButtonPressed)];
    pauseButton.position = ccp(40,30);
    gameplayMenu = [CCMenu menuWithItems:pauseButton, nil];
    gameplayMenu.position = CGPointZero;
    
    [self addChild:gameplayMenu z:kUISpriteZValue];*/
    
    // now add the labels
    
    lemmingText = [CCLabelBMFont labelWithString:[self getUpdatedLemmingString] fntFile:kFilenameDefFontSmall];
    [lemmingText setAnchorPoint:ccp(1,1)];
    [lemmingText setPosition:ccp(winSize.width-10, winSize.height-10)];
    [self addChild:lemmingText z:kUIZValue];
    
    timeText = [CCLabelBMFont labelWithString:[self getUpdatedTimeString] fntFile:kFilenameDefFontSmall];
    [timeText setAnchorPoint:ccp(1,1)];
    [timeText setPosition:ccp(winSize.width-10, winSize.height-30)];
    [self addChild:timeText z:kUIZValue];
}

#pragma mark -
#pragma mark Update

/**
 * Method called every frame
 * @param delta time
 */ 
-(void)update:(ccTime)deltaTime
{
    CCArray* lemmings = [[LemmingManager sharedLemmingManager] lemmings];
    
    CCArray* terrainObjects = [CCArray arrayWithArray:[currentTerrainLayer obstacles]];
    [terrainObjects addObjectsFromArray:[currentTerrainLayer terrain]]; 
    
    for (Lemming *tempLemming in lemmings) 
    {
        [tempLemming updateStateWithDeltaTime:deltaTime andListOfGameObjects:terrainObjects];
    }
    
    //update the display text
    [lemmingText setString:[self getUpdatedLemmingString]];
    [timeText setString:[self getUpdatedTimeString]];
    
    [self incrementGameTimer];
}

/**
 * Returns how many Lemmings have been saved, how many killed
 * @param the string
 */
-(NSString*)getUpdatedLemmingString
{
    return [NSString stringWithFormat:@"left: %i   saved: %i   killed: %i", 
                            [[LemmingManager sharedLemmingManager] lemmingCount],
                            [[LemmingManager sharedLemmingManager] lemmingsSaved],
                            [[LemmingManager sharedLemmingManager] lemmingsKilled]];
}

/**
 * Returns the current time elapsed
 * @param the string
 */
-(NSString*)getUpdatedTimeString
{
    return [NSString stringWithFormat:@"time: %@", [[GameManager sharedGameManager] getGameTimeInMins]];
}

#pragma mark -
#pragma mark Object Creation

/**
 * Adds a lemming to the scene
 */
-(void)addLemming
{
    int lemmingCount = [LemmingManager sharedLemmingManager].lemmingCount;
    CGPoint spawnPoint = [GameManager sharedGameManager].currentLevel.spawnPoint;
    
    [self createLemmingAtLocation:ccp(spawnPoint.x, spawnPoint.y) withHealth:100 withZValue:(lemmingCount+10) withID:lemmingCount];
}

/**
 * Creates a new Lemming object
 * @param withHealth
 * @param atLocation
 * @param withZvalue
 */
-(void)createLemmingAtLocation:(CGPoint)spawnLocation withHealth:(int)health withZValue:(int)zValue withID:(int)ID  
{
    if (![[LemmingManager sharedLemmingManager] lemmingsMaxed]) 
    {
        Lemming *lemming;
        
        MachineLearningType learningType = [[LemmingManager sharedLemmingManager] learningType];
        
        Class class = nil;
        
        switch(learningType) 
        {                
            case kLearningMixed:
                // randomly choose a learning type
                learningType = [Utils generateRandomNumberFrom:0 to:kLearningMixed]; 
                break;
                
            case kLearningReinforcement:
                class = [QLearningAgent class];
                break;
                
            case kLearningTree:
                class = [DecisionTreeAgent class];
                break;
                
            case kLearningShortestRoute:
                class = [ShortestRouteAgent class];
                break;
         
            case kLearningNone:
                class = [Lemming class];
                
            default:
                CCLOG(@"%@.createLemmingAtLocation: Error, learning type not recognised: %@", NSStringFromClass([self class]), [Utils getLearningTypeAsString:learningType]);
                break;
        }
        
        lemming = [[class alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kFilenameDefLemmingFrame]];
        
        lemming.ID = ID;
        lemming.health = health;
        
        if([[GameManager sharedGameManager] debug])
        {
            CCLabelBMFont *debugLabel = [CCLabelBMFont labelWithString:@"" fntFile:kFilenameDefFontDebug];
            [self addChild:debugLabel];
            [lemming setDebugLabel:debugLabel];
        }
        
        [[LemmingManager sharedLemmingManager] addLemming:lemming]; 
        
        // set the helmet/umbrella uses from the level data
        lemming.helmetUses = [GameManager sharedGameManager].currentLevel.helmetUses;
        lemming.umbrellaUses = [GameManager sharedGameManager].currentLevel.umbrellaUses;
        
        [lemming setPosition:spawnLocation]; 
        [sceneSpriteBatchNode addChild:lemming z:zValue tag:kLemmingSpriteTagValue];
        [lemming release];
    }
    else [self unschedule:@selector(addLemming)];
}

#pragma mark -

/**
 * Called every frame, increments the game timer
 */
-(void)incrementGameTimer
{
    if(frameCounter == kFrameRate)
    {
        [[GameManager sharedGameManager] incrementSecondCounter];  
        frameCounter = 0;
    }
    else frameCounter++;
}

#pragma mark -
#pragma mark Event Handling

/**
 * Called when pause button's pressed
 */
-(void)onPauseButtonPressed
{    
    if(pauseMenu == nil) 
    {
        pauseMenu = [PauseMenuLayer node];
        [self addChild:pauseMenu z:kPauseMenuZValue];
    }
    
    if(![[GameManager sharedGameManager] gamePaused]) [pauseMenu animateIn];
}

/**
 * Detects when touch input ends
 * @param the touch
 * @param the event
 */
-(void)ccTouchesEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(![pauseMenu animating]) [self onPauseButtonPressed];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { }

@end
