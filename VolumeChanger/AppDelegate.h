//
//  AppDelegate.h
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-09.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GraphView.h"
#import "CBLabel.h"
#import "BackgroundView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *view;

//Controls
@property (assign) IBOutlet GraphView *graphView;
@property (assign) IBOutlet CBLabel *time;
@property (assign) IBOutlet CBLabel *currentVolumeLabel;
@property (assign) IBOutlet CBLabel *timeLeftLabel;
@property (assign) IBOutlet NSButton *goButton;
@property (assign) IBOutlet NSButton *resetButton;
@property (assign) IBOutlet NSStepper *stepper;

//Background Images
@property (assign) IBOutlet NSImageView	*dayView;
@property (assign) IBOutlet NSImageView	*moon;

@end
