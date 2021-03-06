//
//  MenuScene.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/5/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "MenuScene.h"
#import "SKLabelButton.h"
#import "SKSpriteButton.h"
#import "InfinityGameScene.h"
#import "AppDelegate.h"
#import "ThirtyGameScene.h"
#import "HelpView.h"

#import <GameKit/GameKit.h>
#import <Parse/Parse.h>

@interface MenuScene () <SKLabelButtonDelegate, SKSpriteButtonDelegate, GKGameCenterControllerDelegate, UIAlertViewDelegate, HelpViewDelegate>

@property (nonatomic, strong) SKSpriteNode *logoButton;

// Menu Items
@property (nonatomic, strong) SKSpriteButton *infinityModeButton;
@property (nonatomic, strong) SKSpriteButton *thirtySecondModeButton;
@property (nonatomic, strong) SKSpriteButton *leaderboardsButton;
@property (nonatomic, strong) SKSpriteButton *helpButton;
@property (nonatomic, strong) HelpView *hv;

@end

@implementation MenuScene

static const int MENU_ITEMS_HEIGHT_4_INCH = 230;
static const int MENU_ITEMS_HEIGHT_3_5_INCH = 175;

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

/*
 * Setup elements of the scene
 */
- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        // Set the background color
        self.backgroundColor = [SKColor whiteColor];

        // Setup the title
        [self setupTitle];
        
        // Setup the menu items
        [self setupMenuItems];
        
        [self setUserInteractionEnabled:YES];
    }
    
    return self;
}

/*
 * Sets up the head title
 */
- (void)setupTitle {
    
    self.logoButton = [SKSpriteNode spriteNodeWithImageNamed:@"logo"];
    self.logoButton.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 100);
    if (!isiPhone5) {
        [self.logoButton setScale:.75f];
        self.logoButton.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 80);
    }

    [self addChild:self.logoButton];
}

/*
 * Set's up the menu items
 */
- (void)setupMenuItems
{
    float yCenter = 0;
    if (isiPhone5) {
        yCenter= MENU_ITEMS_HEIGHT_4_INCH;
    } else {
        yCenter = MENU_ITEMS_HEIGHT_3_5_INCH;
    }
    float xCenter = CGRectGetMidX(self.frame);
    
    self.infinityModeButton = [SKSpriteButton spriteButtonWithUpImage:@"infinityModeButton" downImage:@"infinityModeButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.infinityModeButton setDelegate:self];
    [self.infinityModeButton setPosition:CGPointMake(xCenter - 78, yCenter + 78)];
    [self.infinityModeButton setEnabled:YES];
    [self.infinityModeButton setName:@"infinityModeButton"];
    [self addChild:self.infinityModeButton];

    self.thirtySecondModeButton = [SKSpriteButton spriteButtonWithUpImage:@"30secondModeButton" downImage:@"30secondModeButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.thirtySecondModeButton setDelegate:self];
    [self.thirtySecondModeButton setPosition:CGPointMake(xCenter + 78, yCenter + 78)];
    [self.thirtySecondModeButton setEnabled:YES];
    [self.thirtySecondModeButton setName:@"30secondModeButton"];
    [self addChild:self.thirtySecondModeButton];
    
    self.leaderboardsButton = [SKSpriteButton spriteButtonWithUpImage:@"leaderboardsButton" downImage:@"leaderboardsButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.leaderboardsButton setDelegate:self];
    [self.leaderboardsButton setPosition:CGPointMake(xCenter - 78, yCenter - 78)];
    [self.leaderboardsButton setEnabled:YES];
    [self.leaderboardsButton setName:@"leaderboardsButton"];
    [self addChild:self.leaderboardsButton];
    
    self.helpButton = [SKSpriteButton spriteButtonWithUpImage:@"helpButton" downImage:@"helpButtonPressed" disabledImage:nil buttonMode:kTouchUpInside];
    [self.helpButton setDelegate:self];
    [self.helpButton setPosition:CGPointMake(xCenter + 78, yCenter - 78)];
    [self.helpButton setEnabled:YES];
    [self.helpButton setName:@"helpButton"];
    [self addChild:self.helpButton];
    
}

/*
 * Called from the SKSpriteButton delegate
 */
- (void)buttonHit:(SKSpriteButton *)button
{
    if ([button.name isEqualToString:@"infinityModeButton"]) {
        // Present the game scene
        InfinityGameScene *igs = [[InfinityGameScene alloc] initWithSize:self.frame.size];
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.3f];
        [self.view presentScene:igs transition:transition];
    } else if ([button.name isEqualToString:@"leaderboardsButton"]) {
        
        if ([GKLocalPlayer localPlayer].isAuthenticated) {
            //Show the game center
            GKGameCenterViewController *gcvc = [[GKGameCenterViewController alloc] init];
            if (gcvc != nil)
            {
                gcvc.gameCenterDelegate = self;
                gcvc.viewState = GKGameCenterViewControllerStateLeaderboards;
                
                [self.view.window.rootViewController presentViewController:gcvc animated: YES completion:nil];
            }
        } else {
            // Show the game center authentication screen
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Game Center"
                                      message:@"Log in through Game Center"
                                      delegate:self
                                      cancelButtonTitle:@"No"
                                      otherButtonTitles:@"Rad!", nil];
            [alertView show];
            
        }
        
    } else if ([button.name isEqualToString:@"30secondModeButton"]) {
        ThirtyGameScene *tgs = [[ThirtyGameScene alloc] initWithSize:self.frame.size];
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.3f];
        [self.view presentScene:tgs transition:transition];
    } else if ([button.name isEqualToString:@"helpButton"]) {
        if (!self.hv) {
            self.hv = [[HelpView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) gameMode:@"infinity"];
            [self.hv setDelegate:self];
        }
        [self.hv setAlpha:0.0f];
        [self.view addSubview:self.hv];
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.hv setAlpha:1.0f];
        } completion:nil];
    }
}

- (void)didExitHelpView
{
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.hv setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.hv removeFromSuperview];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
    }
}

/*
 * Called from the delegate
 */
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


/*
 * For the SKLabelButtonDelegate
 */
- (void)labelButtonHit:(SKLabelButton *)button
{
    // Do something.
}

/*
 * Get the touches
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

@end
