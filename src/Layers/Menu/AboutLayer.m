//
//  AboutLayer.m
//  Author: Thomas Taylor
//
//  The 'about' layer
//
//  16/12/2011: Created class
//

#import "AboutLayer.h"

@interface AboutLayer()

-(void)onBackButtonPressed;

@end

@implementation AboutLayer

#pragma mark -
#pragma mark Initialisation

/**
 * Initialises the scene
 * @return self
 */
-(id)init
{
	self = [super init];
    
	if (self != nil) 
    {
		CGSize winSize = [CCDirector sharedDirector].winSize; 
		CCSprite *background = [CCSprite spriteWithFile:@"AboutBackground.png"];
		[background setPosition:ccp(winSize.width/2, winSize.height/2)];
		[self addChild:background];
        
        //create the menu buttons
        CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"Back.png" selectedImage:@"Back_down.png" disabledImage:nil target:self selector:@selector(onBackButtonPressed)];
        
        // create menu with the items
        buttons = [CCMenu menuWithItems:backButton, nil];
        
        // position the menu
        [buttons alignItemsVerticallyWithPadding:winSize.height * 0.059f];
        [buttons setPosition: ccp(winSize.width * 0.2, winSize.height * 0.1)];
        
        // add the menu
        [self addChild:buttons];
    }
	return self;
}

#pragma mark -

/**
 * Loads the main menu scene
 */
-(void)onBackButtonPressed 
{
	[[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

@end
