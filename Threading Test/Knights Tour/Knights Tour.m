//
//  KTBoard.h
//  Knights Tour
//
//  Created by Chris Miller on 10/27/09.
//  Copyright 2009 FSDEV. All rights reserved.
//

#import <FSLibrary/FSLog.h>
#import <FSLibrary/FSGeometry.h>

#import "KTBoard.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	FSLogSetUpDefaults();

	NSUserDefaults * args = [NSUserDefaults standardUserDefaults];
	
	FSLog2(FSLogLevelInfo, @"This is the Knight's Tour Solver by Chris R Miller");
	FSLog2(FSLogLevelInfo, @"cmiller@fsdev.net see www.fsdev.net for details");
	FSLog2(FSLogLevelInfo, @"   use -h YES for help");
	
	if([args boolForKey:@"h"]) {
		FSLog2(FSLogLevelInfo, @"Command-line arguments:");
		FSLog2(FSLogLevelInfo, @" -h   YES|NO      displays help text");
		FSLog2(FSLogLevelInfo, @" -e   YES|NO      displays an example solution");
		FSLog2(FSLogLevelInfo, @" -w   INTEGER     width of the chessboard");
		FSLog2(FSLogLevelInfo, @" -l   INTEGER     length of the chessboard");
		FSLog2(FSLogLevelInfo, @" -sw  INTEGER     starting column for the solver");
		FSLog2(FSLogLevelInfo, @" -sl  INTEGER     starting row for the solver");
		FSLog2(FSLogLevelInfo, @" -a   YES|NO      whether or not the SVG output will be animated");
		return 0;
	}
	
	[args setBool:YES forKey:@"e"];
	[args setBool:YES forKey:@"a"];
	
	if([args boolForKey:@"e"]) {
		KTBoard * ex = [[KTBoard alloc] initWithFSSize:[[[FSPoint alloc] initWithX:8 y:8] autorelease]
						];
		NSMutableString * turk = [[NSMutableString alloc] initWithString:@" d4 f5 d6 e8 c7 a8 b6 a4 b2 d1 f2 h1 g3 h5 g7 e6 f8 d7 b8 a6 b4 a2 c1 e2 g1 h3 f4 d3 c5 e4 c3 d5 e3 c4 e5 c6 d8 b7 a5 b3 a1 c2 e1 g2 h4 g6 h8 f7 h6 g4 h2 f1 d2 b1 a3 b5 a7 c8 e7 g8 f6 h7 g5 f3 "];
		[turk replaceOccurrencesOfString:@"a" withString:@"1 " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [turk length])];
		[turk replaceOccurrencesOfString:@"b" withString:@"2 " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [turk length])];
		[turk replaceOccurrencesOfString:@"c" withString:@"3 " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [turk length])];
		[turk replaceOccurrencesOfString:@"d" withString:@"4 " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [turk length])];
		[turk replaceOccurrencesOfString:@"e" withString:@"5 " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [turk length])];
		[turk replaceOccurrencesOfString:@"f" withString:@"6 " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [turk length])];
		[turk replaceOccurrencesOfString:@"g" withString:@"7 " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [turk length])];
		[turk replaceOccurrencesOfString:@"h" withString:@"8 " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [turk length])];
		
		NSScanner * scanner = [[NSScanner alloc] initWithString:[turk autorelease]];
		FSPoint * p; NSInteger xx, yy; NSInteger cursor=0;
		
		NSString * tmp;
		
		while([scanner isAtEnd]==NO) {
			[scanner scanInteger:&xx];
			[scanner scanInteger:&yy];
			p = [[FSPoint alloc] initWithX:yy-1
										 y:xx-1];
			[ex setTileAt:p
				  toValue:cursor++];
			[p release];
		}
		
		[scanner release];
		
		FSLog2(FSLogLevelInfo, @"\n%@",[[ex autorelease] generateSvg:[args boolForKey:@"a"]]);
		
		return 0;
	}
	
	FSRect * dimensions = [[FSRect alloc] init];
	FSPoint * startingLocation = [[FSPoint alloc] init];
	FSPoint * dim;
	
	dimensions.origin.x = 0;
	dimensions.origin.y = 0;
	dimensions.dimensions.x = [args integerForKey:@"w"];
	dimensions.dimensions.y = [args integerForKey:@"l"];
	
	startingLocation.x = [args integerForKey:@"sw"];
	startingLocation.y = [args integerForKey:@"sl"];
	
	dim = dimensions.dimensions;
	
	if(dim.x < 5 || dim.y < 5) {
		FSLog2(FSLogLevelError, @"Given board %@ is too small, try something a bit bigger.",dim);
		[startingLocation release];
		[dimensions release];
		return -1;
	}
	
	// test for Schwenk's Theorem on the board dimensions
	// http://en.wikipedia.org/wiki/Knight's_tour#Schwenk.27s_Theorem
	// (1) m and n are both odd
	// (2) m = 1, 2, or 4; m and n are not both 1
	// (3) m = 3 and n = 4, 6, or 8.
	
	BOOL problemFlag = NO;
	if(dim.x % 2 != 0 && dim.y % 2 != 0) {
		FSLog2(FSLogLevelError, @"Given board %@ violates Schwenk's Theorem rule 1:",dim);
		FSLog2(FSLogLevelError, @"  For a board of size m x n, m and n cannot both be odd.");
		problemFlag = YES;
	}
	if(dim.x == 1 || dim.x == 2 || dim.x == 4 || (dim.x == 1 && dim.y == 1)) {
		FSLog2(FSLogLevelError, @"Given board %@ violates Schwenk's Theorem rule 2:",dim);
		FSLog2(FSLogLevelError, @"  For a board of size m x n, m cannot equal 1, 2, or 4");
		FSLog2(FSLogLevelError, @"  m and n cannot both be one");
		problemFlag = YES;
	}
	if(dim.x == 3 && (dim.y == 4 || dim.y == 6 || dim.y == 8)) {
		FSLog2(FSLogLevelError, @"Given board %@ violates Schwenk's Theorem rule 3:",dim);
		FSLog2(FSLogLevelError, @"  For a board of size m x n, if m is 3 then");
		FSLog2(FSLogLevelError, @"  n cannot equal 4, 6, or 8.");
		problemFlag = YES;
	}
	
	if(problemFlag==YES){
		FSLog2(FSLogLevelError, @"Encountered problems, now terminating.");
		[startingLocation release];
		[dimensions release];
		return -1;
	}
	
	if(![dimensions hasFSPoint:startingLocation]) {
		FSLog2(FSLogLevelError,
			   @"Given starting location %@ is not on the given board %@.",
			   startingLocation,
			   dimensions.dimensions);
		[startingLocation release];
		[dimensions release];
		return -1;
	}
	
	FSLog2(FSLogLevelInfo, @"Everything checks out, will now proceed");
	FSLog2(FSLogLevelInfo, @"solving for board %@ from",dimensions);
	FSLog2(FSLogLevelInfo, @"starting position %@",startingLocation);
	
	
	//! TODO: solve stuff

	[startingLocation release];
	[dimensions release];
	
    [pool drain];
    return 0;
}
