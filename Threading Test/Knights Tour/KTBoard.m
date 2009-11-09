//
//  KTBoard.m
//  Knights Tour
//
//  Created by Chris Miller on 10/27/09.
//  Copyright 2009 FSDEV. All rights reserved.
//

#import <math.h>
#import <Block.h>

#import "KTBoard.h"

static NSInteger KTBoardPadding = 20;
static NSInteger KTBoardScale   = 40;
static NSMutableArray * KTBoardLegalMoves = nil;

@implementation KTBoard

+ (NSMutableArray *)getBranchesForBoard:(KTBoard *)board
							  lastPoint:(FSPoint *)p {
	NSMutableArray * branches = [[NSMutableArray alloc] initWithCapacity:7];
	FSPoint * pm; NSAutoreleasePool * pool0 = [[NSAutoreleasePool alloc] init];
	
	for(FSPoint * m in [KTBoard getLegalMoves]) {
		pm = [[FSPoint alloc] initWithX:p.x+m.x y:p.y+m.y];
		if(![board.size hasFSPoint:pm]) {
			[pm release];
			continue;
		} else if([board tileAt:pm]!=-1) {
			[pm release];
			continue;
		} else {
			[branches addObject:pm];
			[pm release];
		}
	}
	
	[pool0 release];
	return [branches autorelease];
}

+ (NSMutableArray *)getLegalMoves {
	if(KTBoardLegalMoves==nil) {
		KTBoardLegalMoves = [[NSMutableArray alloc] initWithCapacity:8];
		[KTBoardLegalMoves addObject:[[[FSPoint alloc] initWithX: 1 y: 2] autorelease]];
		[KTBoardLegalMoves addObject:[[[FSPoint alloc] initWithX:-1 y: 2] autorelease]];
		[KTBoardLegalMoves addObject:[[[FSPoint alloc] initWithX: 1 y:-2] autorelease]];
		[KTBoardLegalMoves addObject:[[[FSPoint alloc] initWithX:-1 y:-2] autorelease]];
		[KTBoardLegalMoves addObject:[[[FSPoint alloc] initWithX: 2 y: 1] autorelease]];
		[KTBoardLegalMoves addObject:[[[FSPoint alloc] initWithX:-2 y: 1] autorelease]];
		[KTBoardLegalMoves addObject:[[[FSPoint alloc] initWithX: 2 y:-1] autorelease]];
		[KTBoardLegalMoves addObject:[[[FSPoint alloc] initWithX:-2 y:-1] autorelease]];
	}
	return KTBoardLegalMoves;
}

@synthesize tiles = _tiles;
@synthesize graph = _graph;
@synthesize size = _size;

- (id)init {
	// just pass through to create an 8 x 8 chessboard
	return [self initWithFSSize:[[[FSPoint alloc] initWithX:8
														  y:8]
							   autorelease]
			];
}
- (id)initWithFSSize:(FSPoint *)size {
	if(self=[super init]) {
		_size = [[FSRect alloc] initWithOrigin:[[[FSPoint alloc] initWithX:0 y:0] autorelease]
									dimensions:size];
		_tiles = [[NSMutableArray alloc] initWithCapacity:(_size.dimensions.x+1) *
				  (_size.dimensions.y+1)];
		_graph = [[NSMutableArray alloc] initWithCapacity:(_size.dimensions.x+1) *
				  (_size.dimensions.y+1)];
		for(size_t i=0; i < _size.dimensions.x * _size.dimensions.y; ++i) {
			[_tiles addObject:[NSNumber numberWithInteger:-1]];
		}
		FSPoint * p;
		for(size_t x=0; x < _size.dimensions.x; ++x) {
			for(size_t y=0; y < _size.dimensions.y; ++y) {
				p = [[FSPoint alloc] initWithX:x y:y];
				[_graph addObject:[NSNumber numberWithInteger:[[self getBranchesForPoint:p]
															   count]]];
				[p release];
			}
		}
	}
	return self;
}
- (id)initWithBoard:(KTBoard *)board {
	if(self=[super init]) {
		_tiles = [[NSMutableArray arrayWithArray:board.tiles] retain];
		_graph = [[NSMutableArray arrayWithArray:board.graph] retain];
		_size = [board.size retain];
	}
	return self;
}

- (void)dealloc {
	[_tiles release];
	[_graph release];
	[_size release];
	
	[super dealloc];
}

- (NSMutableArray *)getSortedBranchesForPoint:(FSPoint *)p {
	NSComparator finderSort = ^(id point0, id point1) {
		return [[_graph objectAtIndex:[point1 vectorizeWithGrid:_size.dimensions]]
				compare:[_graph objectAtIndex:[point0 vectorizeWithGrid:_size.dimensions]]];
	};
	
	// 
	
	return [NSMutableArray arrayWithArray:[[self getBranchesForPoint:p]
										   sortedArrayUsingComparator:finderSort]];
}

- (NSMutableArray *)getBranchesForPoint:(FSPoint *)p {
	NSMutableArray * branches = [[NSMutableArray alloc] initWithCapacity:7];
	FSPoint * pm; NSAutoreleasePool * pool0 = [[NSAutoreleasePool alloc] init];
	
	for(FSPoint * m in [KTBoard getLegalMoves]) {
		pm = [[FSPoint alloc] initWithX:p.x+m.x y:p.y+m.y];
		if(![self.size hasFSPoint:pm]) {
			[pm release];
			continue;
		} else if([self tileAt:pm]!=-1) {
			[pm release];
			continue;
		} else {
			[branches addObject:pm];
			[pm release];
		}
	}
	
	[pool0 release];
	return [branches autorelease];
}

- (NSInteger)tileAt:(FSPoint *)p {
	return [[_tiles objectAtIndex:[p vectorizeWithGrid:_size.dimensions]] integerValue];
}

- (NSInteger)tileAtX:(NSInteger)xx
				   y:(NSInteger)yy {
	return [[_tiles objectAtIndex:xx + yy * _size.dimensions.y] integerValue];
}

- (void)setTileAt:(FSPoint *)p
		  toValue:(NSInteger)i {
	if(![self.size hasFSPoint:p]) {
		FSLog2(FSLogLevelError, @"Request to set tile for %@ on board of size %@ failed!",
			   p, 
			   _size.dimensions);
		return;
	}
	[_tiles replaceObjectAtIndex:[p vectorizeWithGrid:_size.dimensions]
					  withObject:[NSNumber numberWithInteger:i]];
}

- (void)setTileAtX:(NSInteger)xx
				 y:(NSInteger)yy
		   toValue:(NSInteger)i {
	FSPoint * p = [[FSPoint alloc] initWithX:xx
										   y:yy];
	if(![self.size hasFSPoint:p]) {
		FSLog2(FSLogLevelError, @"Request to set tile for %@ on board of size %@ failed!",
			   p,
			   _size.dimensions);
		[p release];
		return;
	}
	[_tiles replaceObjectAtIndex:[p vectorizeWithGrid:_size.dimensions]
					  withObject:[NSNumber numberWithInteger:i]];
	[p release];
}

- (NSString *)description {
	NSMutableString * descr = [[NSMutableString alloc] init];
	
	for(size_t y=0; y<_size.dimensions.y; ++y) {
		for(size_t x=0; x<_size.dimensions.x; ++x) {
			[descr appendFormat:@"%2d ",[[_tiles objectAtIndex:y*_size.dimensions.y+x] integerValue]];
		}
		[descr appendString:@" | "];
		for(size_t x=0; x<_size.dimensions.x; ++x) {
			[descr appendFormat:@"%2d ",[[_graph objectAtIndex:y*_size.dimensions.y+x] integerValue]];
		}
		[descr appendString:@"\n"];
	}
	
	return [NSString stringWithString:[descr autorelease]];
}

- (void)showDescr {
	[self performSelectorOnMainThread:@selector(showDescrInternal) withObject:nil waitUntilDone:NO];
	[self performSelector:@selector(showDescr) withObject:nil afterDelay:1.0f];
}

- (void)showDescrInternal {
	FSLog2(FSLogLevelInfo,@"the board looks like:\n%@",self);
}

- (NSString *)generateSvg:(BOOL)animated {
	NSMutableString * svg = [[NSMutableString alloc] init];
	
	// create an array of points in order
	
	NSMutableArray * orderedPoints = [[NSMutableArray alloc] init];
	
	NSInteger cursor = 0; NSInteger bsize = _size.dimensions.x * _size.dimensions.y;
	BOOL cont=NO; NSAutoreleasePool * pool0 = [[NSAutoreleasePool alloc] init];
	while(cursor < bsize) {
		cont=NO;
		for(size_t x=0; x < _size.dimensions.x; ++x) {
			for(size_t y=0; y < _size.dimensions.y; ++y)
				if([self tileAtX:x
							   y:y]==cursor) {
					[orderedPoints addObject:[[[FSPoint alloc] initWithX:x
																	   y:y]
											  autorelease]
					 ];
					cont=YES;
					continue;
				}
			if(cont)
				continue;
		}
		++cursor;
		if(!cont)
			FSLog2(FSLogLevelWarning, @"Missed point %d in generating board.", cursor);
	}
	[pool0 release];
	
	[svg appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"];
	[svg appendString:@"<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.o"
					  @"rg/Graphics/SVG/1.1/DTD/svg11.dtd\">\n\n"];
	[svg appendFormat:@"<svg width=\"%d\" height=\"%d\" version=\"1.1\" viewBox=\"0 0 %d %"
					  @"d\" xmlns=\"http://www.w3.org/2000/svg\" onload=\"initGraphic()\">\n",
	 (KTBoardPadding * 2)+(_size.dimensions.x * KTBoardScale),
	 (KTBoardPadding * 2)+(_size.dimensions.y * KTBoardScale),
	 (KTBoardPadding * 2)+(_size.dimensions.x * KTBoardScale),
	 (KTBoardPadding * 2)+(_size.dimensions.y * KTBoardScale)
	 ];
	[svg appendFormat:@"    <g transform=\"translate(%d, %d) scale(%d)\">\n",
	 KTBoardPadding,
	 KTBoardPadding,
	 KTBoardScale
	 ];
	[svg appendString:@"        <g fill=\"white\" stroke=\"gray\" stroke-width=\"0.025\">\n"];
	
	for(size_t i=0; i<=_size.dimensions.y; ++i)
		[svg appendFormat:@"            <line x1=\"0\" x2=\"%d\" y1=\"%d\" y2=\"%d\" />\n",
		 _size.dimensions.x,
		 i,
		 i
		 ];
	for(size_t i=0; i<=_size.dimensions.x; ++i)
		[svg appendFormat:@"            <line x1=\"%d\" x2=\"%d\" y1=\"0\" y2=\"%d\" />\n",
		 i,
		 i,
		 _size.dimensions.y
		 ];
	
	[svg appendString:@"            <g transform=\"translate(0.5,0.5)\">\n"];
	[svg appendFormat:@"                <circle cx=\"%d\" cy=\"%d\" r=\"0.1\" stroke=\""
					  @"none\" fill=\"black\" />\n",
	 [[orderedPoints objectAtIndex:0] x],
	 [[orderedPoints objectAtIndex:0] y]
	 ];
	NSMutableString * pathstring = [[NSMutableString alloc] init];
	NSMutableString * animString = [[NSMutableString alloc] initWithString:@"M "];
	for(FSPoint * p in orderedPoints) {
		[pathstring appendFormat:@"%d,%d ",
		 p.x,
		 p.y
		 ];
		[animString appendFormat:@"%d %d L",
		 p.x,
		 p.y
		 ];
	}
	
	[svg appendFormat:@"                <polyline id=\"tourpath\" points=\"%@\" stroke=\""
					  @"black\" stroke-width=\"0.05\" fill=\"none\" />\n",
	 [pathstring autorelease]
	 ];
	CGFloat y1, y2, x1, x2;
	y1 = (CGFloat)[[orderedPoints objectAtIndex:[orderedPoints count] - 1] y];
	y2 = (CGFloat)[[orderedPoints objectAtIndex:[orderedPoints count] - 2] y];
	x1 = (CGFloat)[[orderedPoints objectAtIndex:[orderedPoints count] - 1] x];
	x2 = (CGFloat)[[orderedPoints objectAtIndex:[orderedPoints count] - 2] x];
	
	CGFloat arrowAngle = (CGFloat)atan2(x1 - x2,
										y1 - y2) * 57.2957795f / atan2(1.0f, 1.0f);
	
	[svg appendFormat:@"                <g transform=\"translate%@ scale(0.025) rotate(%"
					  @"f)\">\n",[orderedPoints lastObject],arrowAngle];
	[svg appendString:@"                    <path d=\"M5,0 L-10,5 A3,5 0 0,0 -10,-5\" st"
					  @"roke=\"none\" fill=\"black\" />\n"];
	[svg appendString:@"                </g>\n"];
	if(animated) {
		[svg appendString:@"                <g transform=\"translate(-0.375,0.225)\">\n"];
		[svg appendString:@"                    <g>\n"];
		[svg appendString:@"                        <g transform=\"scale(0.75)\">\n"];
		[svg appendString:@"                            <text fill=\"red\" font-size=\""
						  @"1\">♞</text>\n"];
		[svg appendString:@"                        </g>\n"];
		[svg appendFormat:@"                        <animateMotion path=\"%@\" dur=\"%ds"
						  @"\" fill=\"freeze\" repeatCount=\"indefinite\" />\n",
		 [animString substringToIndex:[animString length] -2],
		 [orderedPoints count] + 1
		 ];
		[svg appendString:@"                    </g>\n"];
		[svg appendString:@"                </g>\n"];
	}
	[animString release];
	[svg appendString:@"            </g>\n"];
	[svg appendString:@"        </g>\n"];
	[svg appendString:@"    </g>\n"];
	[svg appendString:@"</svg>\n"];
	
	[orderedPoints release];
	
	return [NSString stringWithString:[svg autorelease]];
}

@end
