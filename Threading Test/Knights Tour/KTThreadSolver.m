//
//  KTThreadSolver.m
//  Knights Tour
//
//  Created by Chris Miller on 11/7/09.
//  Copyright 2009 FSDEV. All rights reserved.
//

#import "KTThreadSolver.h"

static const NSUInteger maxThreads = 100;
static NSUInteger activeThreads = 0;
static BOOL solutionFound = NO;
static CGFloat sleepTime = 0.001;

void reset_solver() {
	activeThreads=0;
	solutionFound=NO;
}

@implementation KTThreadSolver

- (id)initThreadedWithBoard:(KTBoard *)board
		   startingLocation:(FSPoint *)start
				  iteration:(NSNumber *)iter
				   delegate:(id)dg {
	if(self=[super init]) {
		_board = [board retain];
		_start = [start retain];
		_iter = [iter integerValue];
		_dispatch = NO;
		_dg = dg;
	}
	return self;
}

- (id)initDispatchWithBoard:(KTBoard *)board
		   startingLocation:(FSPoint *)start
				  iteration:(NSNumber *)iter
				   delegate:(id)dg {
	if(self=[super init]) {
		_board = [board retain];
		_start = [start retain];
		_iter = [iter integerValue];
		_dispatch = YES;
		_dg = dg;
	}
	return self;
}

- (void)dealloc {
	[_board release];
	[_start release];
	[super dealloc];
}

- (void)solve {
	NSInteger thisThread = ++activeThreads;
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[_board setTileAt:_start
			 toValue:_iter];
	
	if(_iter==(_board.size.dimensions.x)*(_board.size.dimensions.y)-1) {
		solutionFound = YES;
		[_dg foundSolution:_board];
		--activeThreads;
		if(!_dispatch)
			[NSThread exit];
		return;
	}
	
	NSMutableArray * branches = [[_board getSortedBranchesForPoint:_start] retain];
	if([branches count]==0)
		goto skipLoop;
	
	KTBoard * result = nil; KTThreadSolver * call = nil;
	while([branches count]>0) {
		if(solutionFound) {
			--activeThreads;
			if(!_dispatch)
				[NSThread exit];
			return;
		}
		
		if(_dispatch)
			call =
			[[KTThreadSolver alloc] initDispatchWithBoard:[[KTBoard alloc] initWithBoard:_board]
										 startingLocation:[branches lastObject]
												iteration:[NSNumber numberWithInteger:_iter+1]
												 delegate:_dg];
		else
			call = // but if there are still threads to be made, then use a parallel solver
			[[KTThreadSolver alloc] initThreadedWithBoard:[[KTBoard alloc] initWithBoard:_board]
										 startingLocation:[branches lastObject]
												iteration:[NSNumber numberWithInteger:_iter+1]
												 delegate:_dg];

		
		if(activeThreads>=maxThreads) // essentially, if the maximum number of threads has been
			[call solve];
		else
			if(_dispatch)
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
							   ^{ [call solve]; });
			else
				[[[NSThread alloc] initWithTarget:call
										 selector:@selector(solve)
										   object:nil]
				 start];
		
		[branches removeLastObject];
		
		//[NSThread sleepForTimeInterval:sleepTime];
	}
	
	skipLoop:
	
	[branches release];
	[_board release];
	
	[pool drain];
	[pool release];
	
	--activeThreads;
	
	if(!_dispatch)
		[NSThread exit];
	
	return;
}

@end
