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
	FSRect * _size;
}

@property(readwrite, retain) NSMutableArray * tiles;
@property(readwrite, retain) FSRect * size;

- (id)init;
- (id)initWithFSSize:(FSPoint *)size;
- (id)initWithBoard:(KTBoard *)board;

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
