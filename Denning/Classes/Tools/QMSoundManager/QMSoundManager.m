//
//  QMSoundManager.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSoundManager.h"

static NSString * const kSystemSoundTypeCAF = @"caf";
static NSString * const kSystemSoundTypeAIF = @"aif";
static NSString * const kSystemSoundTypeAIFF = @"aiff";
static NSString * const kystemSoundTypeWAV = @"wav";

static NSString * const kQMSoundManagerSettingKey = @"kQMSoundManagerSettingKey";

@interface QMSoundManager()

@property (strong, nonatomic) NSMutableDictionary *sounds;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation QMSoundManager

- (void)dealloc {
    
    NSNotificationCenter *notifcationCenter =
    [NSNotificationCenter defaultCenter];
    [notifcationCenter removeObserver:self];
}

+ (instancetype)instance {
    
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _on = YES;
        
        _sounds = [NSMutableDictionary dictionary];
        
        NSNotificationCenter *notifcationCenter =
        [NSNotificationCenter defaultCenter];
        
        [notifcationCenter addObserver:self
                              selector:@selector(didReceiveMemoryWarningNotification:)
                                  name:UIApplicationDidReceiveMemoryWarningNotification
                                object:nil];
    }
    
    return self;
}

- (void)setOn:(BOOL)on {
    
    _on = on;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:on forKey:kQMSoundManagerSettingKey];
    [userDefaults synchronize];
    
    if (!on) {
        
        [self stopAllSounds];
    }
}

#pragma mark - Playing sounds

- (void)playSoundWithName:(NSString *)filename extension:(NSString *)extension {
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    if (self.sounds[filename]) {
        
        self.audioPlayer = self.sounds[filename];
    }
    else {
        
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        
        if (error) {
            
            ILog(@"%@",[error localizedDescription]);
        }
        else {
            
            self.sounds[filename] = self.audioPlayer;
        }
    }
    
    [self.audioPlayer play];
}

- (void)playVibrateSound {
    
    if (self.on) {
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)stopAllSounds {
    
    if (self.audioPlayer) {
        
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    
    [self.sounds removeAllObjects];
}

#pragma mark - Did Receive Memory Warning Notification

- (void)didReceiveMemoryWarningNotification:(NSNotification *)__unused notification {
    
    [self.sounds removeAllObjects];
}

#pragma mark - Default sounds

static NSString *const kQMReceivedSoundName = @"received";
static NSString *const kQMSendSoundName = @"sent";
static NSString *const kQMCallingSoundName = @"calling";
static NSString *const kQMBusySoundName = @"busy";
static NSString *const kQMEndOfCallSoundName = @"end_of_call";
static NSString *const kQMRingtoneSoundName = @"ringtone";

+ (void)playMessageReceivedSound {
    
    [[[self class] instance] playSoundWithName:kQMReceivedSoundName
                                     extension:kystemSoundTypeWAV];
}

+ (void)playMessageSentSound {
    
    [[[self class] instance] playSoundWithName:kQMSendSoundName
                                     extension:kystemSoundTypeWAV];
}

+ (void)playCallingSound {
    
    [[[self class] instance] playSoundWithName:kQMCallingSoundName
                                     extension:kystemSoundTypeWAV];
}

+ (void)playBusySound {
    
    [[[self class] instance] playSoundWithName:kQMBusySoundName
                                     extension:kystemSoundTypeWAV];
}

+ (void)playEndOfCallSound {
    
    [[[self class] instance] playSoundWithName:kQMEndOfCallSoundName
                                     extension:kystemSoundTypeWAV];
}

+ (void)playRingtoneSound {
    
    [[[self class] instance] playSoundWithName:kQMRingtoneSoundName
                                     extension:kystemSoundTypeWAV];
    [[[self class] instance] playVibrateSound];
}

@end
