//
//  LTRAddEditListViewController.m
//  lister
//
//  Created by Geoff Cornwall on 7/31/13.
//  Copyright (c) 2013 Geoff Cornwall. All rights reserved.
//

#import "LTRAddEditListViewController.h"
#import "LTRHTTPClient.h"
#import "LTRUtility.h"

@interface LTRAddEditListViewController ()

@end

@implementation LTRAddEditListViewController

- (id)init {
	self = [super init];
	if (self) {
        _editMode = FALSE;
	}
	return self;
}

- (id)initForEdit:(LTRList *)list {
	self = [super init];
	if (self) {
		_editList = list;
        _editMode = TRUE;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // TestFlight / GAI
    [TestFlight passCheckpoint:@"ADD_LISTS"];
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-32232417-4"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"appview", kGAIHitType, @"ADD_LISTS", kGAIScreenName, nil];
    [tracker send:params];

    _randomColor = [LTRUtility randomColor];
    self.view.backgroundColor = _randomColor;

    if (_editMode) {
        self.navigationItem.title = @"Edit List";
    }
    else {
        self.navigationItem.title = @"Add List";
    }
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // Set the needed frames
    CGRect newListFrame;
    CGRect labelFrame;
    CGRect switchFrame;
    if (!IS_IPHONE5) {
        newListFrame = CGRectMake(20, 100, 280, 50);
        labelFrame = CGRectMake(45, 175, 175, 30);
        switchFrame = CGRectMake(223, 175, 50, 30);
    }
    else {
        newListFrame = CGRectMake(20, 125, 280, 50);
        labelFrame = CGRectMake(45, 200, 175, 30);
        switchFrame = CGRectMake(223, 200, 50, 30);
    }

    _newList = [[UITextField alloc] initWithFrame:newListFrame];
    _newList.borderStyle = UITextBorderStyleRoundedRect;
    _newList.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    _newList.autocorrectionType = UITextAutocorrectionTypeNo;
    _newList.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _newList.keyboardType = UIKeyboardTypeDefault;
    _newList.returnKeyType = UIReturnKeyDone;
    _newList.clearButtonMode = UITextFieldViewModeWhileEditing;
    _newList.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _newList.delegate = self;
    [_newList becomeFirstResponder];

    if (_editMode) {
        _newList.text = _editList.listName;
    }
    else {
        _newList.placeholder = @"Give your list a name...";
    }
    
    [self.view addSubview:_newList];
    
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    label.text = @"Allow anyone to add to it?";
    [self.view addSubview:label];
    
    _switch = [[UISwitch alloc] initWithFrame:switchFrame];
    [_switch setOnTintColor:[UIColor blackColor]];
    if (_editMode) [_switch setOn:_editList.isOpen];
    [self.view addSubview:_switch];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addList:(id)sender {
    [[LTRHTTPClient sharedInstance] addList:[LTRUtility URLEncodeString:_newList.text] isOpen:_switch.isOn onCompletion:^(BOOL success, NSDictionary *json) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)editList:(id)sender {
    [[LTRHTTPClient sharedInstance] editList:_editList onCompletion:^(BOOL success, NSDictionary *json) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)done:(id)sender {
    if (_editMode) {
        _editList.listName = _newList.text;
        _editList.isOpen = _switch.isOn;
        [self editList:nil];
    }
    else {
        [self addList:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self done:nil];
    return YES;
}

@end
