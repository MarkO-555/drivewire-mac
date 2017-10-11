//
//  NetworkConnectionViewController.m
//  DriveWire MacServer
//
//  Created by Boisy Pitre on 4/19/15.
//
//

#import "NetworkConnectionViewController.h"

@interface NetworkConnectionViewController ()

@end

@implementation NetworkConnectionViewController

- (id)initWithChannel:(VirtualSerialChannel *)channel;
{
    if (self = [super initWithNibName:@"NetworkConnectionView" bundle:[NSBundle bundleForClass:[self class]]])
    {
        self.channel = channel;
        self.channel.delegate = self;
        [self loadView];
    }
    
    return self;
}

- (void)dealloc;
{
    self.channel = nil;
}

- (void)awakeFromNib;
{
    self.name = [NSString stringWithFormat:@"Virtual Channel %ld", self.channel.number];
    [self.outgoingLED setOffColor:[NSColor blackColor]];
    [self.outgoingLED setOnColor:[NSColor redColor]];
    [self.incomingLED setOffColor:[NSColor blackColor]];
    [self.incomingLED setOnColor:[NSColor redColor]];
    [self.incomingLED setBlinkTime:0.25];
    [self.outgoingLED setBlinkTime:0.25];
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
}

#pragma mark -
#pragma mark VirtualSerialChannelDelegate Methods

- (void)didConnect:(VirtualSerialChannel *)channel;
{
    self.status = @"Connected";
}

- (void)didDisconnect:(VirtualSerialChannel *)channel;
{
    self.status = @"Disconnected";
}

- (void)didReceiveData:(VirtualSerialChannel *)channel;
{
    [self.incomingLED turnOn];
}

- (void)didSendData:(VirtualSerialChannel *)channel;
{
    [self.outgoingLED turnOn];
}

@end