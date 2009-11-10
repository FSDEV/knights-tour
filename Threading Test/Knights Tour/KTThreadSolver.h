//
//  KTThreadSolver.h
//  Knights Tour
//
//  Created by Chris Miller on 11/7/09.
//  Copyright 2009 FSDEV. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FSLibrary/FSGeometry.h>

#import "KTBoard.h"

void reset_solver();

@interface KTThreadSolver : NSObject {
	KTBoard * _board;
	FSPoint * _start;
	NSInteger _iter;
	BOOL _dispatch;
	__weak id _dg;
}

- (id)initThreadedWithBoard:(KTBoard *)board
		   startingLocation:(FSPoint *)start
				  iteration:(NSNumber *)iter
				   delegate:(id)dg;

- (id)initDispatchWithBoard:(KTBoard *)board
		   startingLocation:(FSPoint *)start
				  iteration:(NSNumber *)iter
				   delegate:(id)dg;

- (void)solve;

@end
