//
//  KTSolver.m
//  Knights Tour
//
//  Created by Chris Miller on 11/6/09.
//  Copyright 2009 FSDEV. All rights reserved.
//

#import "KTSolver.h"

#include <stdio.h>

static NSMutableArray * KTSolverLegalMoves = nil;

static NSUInteger backtracks = 0;

@implementation KTSolver

+ (KTBoard *)serialSolverForBoard:(KTBoard *)board
					startingPoint:(FSPoint *)start
						iteration:(NSInteger)iter {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[board setTileAt:start
			 toValue:iter];
	
	if(iter==(board.size.dimensions.x+1)*(board.size.dimensions.y+1)-1) {
		return board; // end of the line
	}
	
	NSMutableArray * branches = [[board getSortedBranchesForPoint:start] retain];
	
	KTBoard * result = nil;
	while([branches count]>0) {
		result = [KTSolver serialSolverForBoard:board
								  startingPoint:[branches lastObject]
									  iteration:iter+1];
		if(result==nil) {
			[branches removeLastObject];
		} else {
			[branches release];
			return result;
		}
	}
	
	[branches release];
	[board setTileAt:start
			 toValue:-1];
	
	[pool release];
	
	++backtracks;
	
	return nil; // there are no solutions from this branch
}

- (id)init {
	FSLog2(FSLogLevelError, @"Please don't make a solver!");
	return nil;
}

@end
