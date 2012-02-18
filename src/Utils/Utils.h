//
//  Utils.h
//  Cogito
//
//  A class of static 'util' methods
//
//  18/12/2011: Created class
//

#import "cocos2d.h"
#import "CommonDataTypes.h"
#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(NSString*)getActionAsString:(Action)_action;
+(NSString*)getBooleanAsString:(BOOL)_bool;
+(NSString*)getLearningTypeAsString:(MachineLearningType)_learningType;
+(NSString*)getObjectAsString:(GameObjectType)_object;
+(NSString*)getRatingAsString:(GameRating)_rating;
+(NSString*)getStateAsString:(CharacterStates)_state;
+(NSDictionary*)loadPlistFromFile:(NSString*)_filename;
+(void)listAvailableFonts;

@end
