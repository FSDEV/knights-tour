//
//  KTBoard.h
//  Knights Tour
//
//  Created by Chris Miller on 10/27/09.
//  Copyright 2009 FSDEV. All rights reserved.
//

#import <FSLibrary/FSLog.h>
#import <FSLibrary/FSGeometry.h>

@interface KTBoard : NSObject {
	NSMutableArray * _tiles;
	NSMutableArray * _graph;
	FSRect * _size;
}

+ (NSMutableArray *)getBranchesForBoard:(KTBoard *)board
							  lastPoint:(FSPoint *)p;
+ (NSMutableArray *)getLegalMoves;

@property(readwrite, retain) NSMutableArray * tiles;
@property(readwrite, retain) NSMutableArray * graph;
@property(readwrite, retain) FSRect * size;

- (id)init;
- (id)initWithFSSize:(FSPoint *)size;
- (id)initWithBoard:(KTBoard *)board;

- (NSMutableArray *)getSortedBranchesForPoint:(FSPoint *)p;
- (NSMutableArray *)getBranchesForPoint:(FSPoint *)p;

- (void)showDescr;
- (void)showDescrInternal;

- (NSInteger)tileAt:(FSPoint *)p;
- (NSInteger)tileAtX:(NSInteger)xx
				   y:(NSInteger)yy;
- (void)setTileAt:(FSPoint *)p
		  toValue:(NSInteger)i;
- (void)setTileAtX:(NSInteger)xx
				 y:(NSInteger)yy
		   toValue:(NSInteger)i;
- (NSString *)generateSvg:(BOOL)animated;

@end
