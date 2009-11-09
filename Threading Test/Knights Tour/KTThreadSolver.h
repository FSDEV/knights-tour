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

@interface KTThreadSolver : NSObject {
	KTBoard * _board;
	FSPoint * _start;
	NSInteger _iter;
	__weak id _dg;
}

- (id)initWithBoard:(KTBoard *)board
   startingLocation:(FSPoint *)start
		  iteration:(NSNumber *)iter
		   delegate:(id)dg;

- (void)solve;

@end
