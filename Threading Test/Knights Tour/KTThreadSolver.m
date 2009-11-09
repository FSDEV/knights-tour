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

@implementation KTThreadSolver

- (id)initWithBoard:(KTBoard *)board
   startingLocation:(FSPoint *)start
		  iteration:(NSNumber *)iter
		   delegate:(id)dg {
	if(self=[super init]) {
		_board = [board retain];
		_start = [start retain];
		_iter = [iter integerValue];
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
			return;
		}
		
		if(activeThreads>=maxThreads) { // essentially, if the maximum number of threads has been
			call = [[KTThreadSolver alloc] initWithBoard:_board // reached, then use a serial solver
										startingLocation:[branches lastObject]
											   iteration:[NSNumber numberWithInteger:_iter+1]
												delegate:_dg];
			[call solve];
		} else {
			call = // but if there are still threads to be made, then use a parallel solver
			[[KTThreadSolver alloc] initWithBoard:[[KTBoard alloc] initWithBoard:_board]
								 startingLocation:[branches lastObject]
										iteration:[NSNumber numberWithInteger:_iter+1]
										 delegate:_dg];
			
			[[[NSThread alloc] initWithTarget:call selector:@selector(solve) object:nil] start];
		}
		
		[branches removeLastObject];
		
		[NSThread sleepForTimeInterval:sleepTime];
	}
	
	skipLoop:
	
	[branches release];
	[_board release];
	
	[pool drain];
	[pool release];
	
	--activeThreads;
	
	[NSThread exit];
	
	return;
}

@end
