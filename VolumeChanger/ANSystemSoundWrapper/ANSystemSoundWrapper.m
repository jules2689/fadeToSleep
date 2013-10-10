
#import "ANSystemSoundWrapper.h"
#import <CoreAudio/CoreAudio.h>

@implementation ANSystemSoundWrapper

+ (float)systemVolume
{
    // get device
    AudioDeviceID device;
    UInt32 size = sizeof(device);
    
	AudioObjectPropertyAddress propertyAddress = {
		kAudioHardwarePropertyDefaultOutputDevice,
		kAudioObjectPropertyScopeGlobal,
		kAudioObjectPropertyElementMaster
	};
	if (noErr != AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &size, &device))
	{
        NSLog(@"audio-volume error get device");
        return -1;
    }
    
    // try get master volume (channel 0)
    float volume;
    size = sizeof(volume);
	propertyAddress = (AudioObjectPropertyAddress){
		kAudioDevicePropertyVolumeScalar,
		kAudioDevicePropertyScopeOutput,
		0
	};
	if (noErr == AudioObjectGetPropertyData(device, &propertyAddress, 0, NULL, &size, &volume))
	{
		//kAudioDevicePropertyVolumeScalarToDecibels
		return volume;
    }
    
    // otherwise, try seperate channels
    UInt32 channels[2];
    size = sizeof(channels);
	propertyAddress = (AudioObjectPropertyAddress){
		kAudioDevicePropertyPreferredChannelsForStereo,
		kAudioDevicePropertyScopeOutput,
		kAudioObjectPropertyElementWildcard
	};
	if (noErr != AudioObjectGetPropertyData(device, &propertyAddress, 0, NULL, &size, &channels[0]))
	{
        NSLog(@"error getting channel-numbers");
        return -1;
    }
    
    float volumes[2];
    size = sizeof(float);
	propertyAddress = (AudioObjectPropertyAddress){
		kAudioDevicePropertyVolumeScalar,
		kAudioDevicePropertyScopeOutput,
		channels[0]
	};
	if (noErr != AudioObjectGetPropertyData(device, &propertyAddress, 0, NULL, &size, &volumes[0]))
	{
        NSLog(@"error getting volume of channel %d", channels[0]);
        return -1;
    }
	propertyAddress.mElement = channels[1];
	if (noErr != AudioObjectGetPropertyData(device, &propertyAddress, 0, NULL, &size, &volumes[1]))
	{
        NSLog(@"error getting volume of channel %d", channels[1]);
        return -1;
    }
    volume = (volumes[0] + volumes[1]) / 2.00;
    return volume;
}

+ (void)setSystemVolume:(float)volume
{    
    // get default device
    AudioDeviceID device;
    UInt32 size = sizeof(device);
	AudioObjectPropertyAddress propertyAddress = {
		kAudioHardwarePropertyDefaultOutputDevice,
		kAudioObjectPropertyScopeGlobal,
		kAudioObjectPropertyElementMaster
	};
    if (noErr != AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &size, &device))
	{
        NSLog(@"audio-volume error get device");
        return;
    }
    
    // try set master-channel (0) volume
    Boolean canset = false;
    size = sizeof(canset);
	propertyAddress = (AudioObjectPropertyAddress){
		kAudioDevicePropertyVolumeScalar,
		kAudioDevicePropertyScopeOutput,
		0
	};
	if (noErr == AudioObjectIsPropertySettable(device, &propertyAddress, &canset))
	{
        size = sizeof(volume);
		AudioObjectSetPropertyData(device, &propertyAddress, 0, NULL, size, &volume);
        return;
    }
    
    // else, try seperate channes
    UInt32 channels[2];
    size = sizeof(channels);
	propertyAddress = (AudioObjectPropertyAddress){
		kAudioDevicePropertyPreferredChannelsForStereo,
		kAudioDevicePropertyScopeOutput,
		kAudioObjectPropertyElementWildcard
	};
	if (noErr != AudioObjectGetPropertyData(device, &propertyAddress, 0, NULL, &size, &channels[0]))
	{
        NSLog(@"error getting channel-numbers");
        return;
    }
    
    // set volume
    size = sizeof(float);
	propertyAddress = (AudioObjectPropertyAddress){
		kAudioDevicePropertyVolumeScalar,
		kAudioDevicePropertyScopeOutput,
		channels[0]
	};
	if (noErr != AudioObjectSetPropertyData(device, &propertyAddress, 0, NULL, size, &volume))
	{
        NSLog(@"error setting volume of channel %d", channels[0]);
    }
	propertyAddress.mElement = channels[1];
    if (noErr != AudioObjectSetPropertyData(device, &propertyAddress, 0, NULL, size, &volume))
	{
		NSLog(@"error setting volume of channel %d", channels[1]);
    }
}

@end
