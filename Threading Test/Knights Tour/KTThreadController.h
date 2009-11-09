//
//  KTThreadController.h
//  Knights Tour
//
//  Created by Chris Miller on 11/7/09.
//  Copyright 2009 FSDEV. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FSLibrary/FSGeometry.h>
#import <FSLibrary/FSLog.h>
#import <time.h>

#import "KTBoard.h"
#import "KTThreadSolver.h"

@interface KTThreadController : NSObject {
	KTBoard * _board;
	FSPoint * _start;
	clock_t t_start;
	clock_t t_end;
	KTThreadSolver * _solver;
	BOOL _finished;
}

@property(readonly, assign) BOOL finished;

- (id)initWithBoard:(KTBoard *)board
   startingLocation:(FSPoint *)start;

- (void)run;

- (void)foundSolution:(KTBoard *)board;

@end
