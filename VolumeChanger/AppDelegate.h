//
//  AppDelegate.h
//  VolumeChanger
//
//  Created by Julian Nadeau on 2013-10-09.
//  Copyright (c) 2013 Julian Nadeau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GraphView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet GraphView *graphView;
@property (assign) IBOutlet NSTextField *time;
@property (assign) IBOutlet NSTextField *currentVolumeLabel;
@property (assign) IBOutlet NSButton *goButton;
@property (assign) IBOutlet NSStepper *stepper;

@end
