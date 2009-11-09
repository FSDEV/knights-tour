//
//  KTSolver.h
//  Knights Tour
//
//  Created by Chris Miller on 11/6/09.
//  Copyright 2009 FSDEV. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FSLibrary/FSLog.h>
#import <FSLibrary/FSGeometry.h>

#import "KTBoard.h"

@interface KTSolver : NSObject {
	
}

+ (KTBoard *)serialSolverForBoard:(KTBoard *)board
					startingPoint:(FSPoint *)start
						iteration:(NSInteger)iter;

@end
