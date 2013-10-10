#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>

#define MIN_SYSTEM_VOLUME   0.0
#define MAX_SYSTEM_VOLUME   1.0

@interface ANSystemSoundWrapper : NSObject {
	
}

+ (float)systemVolume;
+ (void)setSystemVolume:(float)volume;

@end
