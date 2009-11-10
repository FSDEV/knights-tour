//
//  KTThreadController.m
//  Knights Tour
//
//  Created by Chris Miller on 11/7/09.
//  Copyright 2009 FSDEV. All rights reserved.
//

#import "KTThreadController.h"


@implementation KTThreadController

@synthesize finished = _finished;

- (id)initWithBoard:(KTBoard *)board
   startingLocation:(FSPoint *)start {
	if(self=[super init]) {
		_board = [board retain];
		_start = [start retain];
		_finished = NO;
		reset_solver();
	}
	return self;
}

- (void)dealloc {
	[_board release];
	[_start release];
	
	[super dealloc];
}

- (void)runThreaded {
	t_start=clock();
	_solver = [[KTThreadSolver alloc] initThreadedWithBoard:_board
										   startingLocation:_start
												  iteration:[NSNumber numberWithInteger:0]
												   delegate:self];
	[_solver solve];
}

- (void)runDispatch {
	t_start=clock();
	_solver = [[KTThreadSolver alloc] initDispatchWithBoard:_board
										   startingLocation:_start
												  iteration:[NSNumber numberWithInteger:0]
												   delegate:self];
	[_solver solve];
}

- (void)foundSolution:(KTBoard *)board {
	t_end=clock();
	FSLog2(FSLogLevelInfo, @"Found solution, took %d clocks.",t_end-t_start);
	FSLog2(FSLogLevelInfo, @"SVG of board: \n%@",[board generateSvg:YES]);
	_finished = YES;
}

@end
