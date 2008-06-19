module knightstour.svgAnimation;

/*
 *      SVGMaker_animator.d
 *      SVG Image Maker derived from Chris Millers adaptation of Ilmari Karonen's Perl script
 *      I moved the logic to a class, and added ECMA Script for animation
 *      used D's tokenStrings for better readability
 *      written in and for D2.012
 *
 *      Copyright 2008 Tobias Kieslich [tobias evilroot net]
 *
 *      MIT LICENSE
 */

import std.stdio;    // writefln
import std.string;   // split, strip
import std.stream;   // bufferdFile
import std.conv;     // toInt
import std.math;     // atan2


class Tour {
	public static ubyte board_x;
	public static ubyte board_y;

	// SVG manipulators
	invariant ubyte padding=10;
	invariant ubyte scale=40;

	// the path [[x0,y0], [x1,y1], ...]
	public ubyte [2][] path;

	/// create from an array of read lines from the wiki-syntax
	this(string [] tour)
	{
		this.board_y = tour.length - 1;
		this.board_x = split(tour[1], "||").length-2;
		// create flat array with the whole tour length
		this.path.length = board_x*board_y;
		foreach(uint n, string row; tour)
		{
			if(n==0) continue; // this is the headline
			foreach(uint m, string s; split(row, "||"))
			{
				if (m!=0 && m!=this.board_x+1)
					// write location to proper position in array -> no sort required
					this.path[ toUbyte(strip(s)) ] = [n-1,m-1];
			}
		}
	}

	/// returns the path initially displayed in the array
	string getPathString()
	{
		string points = "";
		for(ubyte i=0;i<this.path.length; i++)
			points ~= format("%d,%d ",this.path[i][0], this.path[i][1]);
		return points;
	}

	/// get all the rects
	string getRects()
	{
		string rects = "";
		string fills = "white";
		for(ubyte y=0; y<this.board_y; y++)
			for(ubyte x=0; x<this.board_x; x++)
				rects~=format(q{			<rect id="%d_%d" x="%d" y="%d" width="1" height="1" />
	}, x,y,x,y);
		return rects;
	}

	void writeToFile()
	{
		File file = new File;
		file.create(
			std.conv.toString(this.path[0][0])~"_"~std.conv.toString(this.path[0][1])~"tour.svg",
			FileMode.Out
		);

		file.writeString(this.make_svg());
		file.close();
		return 0 ;
	}

	/// the main svg creator that mainly returns the static body
	/// dynamic parts get injected
	string make_svg()
	{
		invariant int img_x=(this.padding * 2)+(this.board_x * this.scale);
		invariant int img_y=(this.padding * 2)+(this.board_y * this.scale);
		return format(q{<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
	"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg width="%d" height="%d" version="1.1" viewBox="0 0 %d %d"
	xmlns="http://www.w3.org/2000/svg" onload="initGraphic()">
	<script>
	<![CDATA[
	var x=%s; var y=%s;
	var svgRoot = null;
	var tp = null;
	var pts = [];
	// Copyright 2008 Tobias Kieslich [tobias justdreams net]
	// the basic version displays the svg -> nice for simple viewer
	// we initiate here for ECMA-script capable viewers (Moz, Opera, Safari)
	function initGraphic()
	{
		tp = document.getElementById("tourpath");
		svgRoot = tp.ownerDocument.documentElement;
		var points = tp.getAttribute("points");
		var spoints = points.split(" ");
		for(var i=0; i<spoints.length; i++)
			pts.push( spoints[i].split(",") );
		tp.setAttribute("points", "");
		extendLine(0);
	}
	function extendLine (n)
	{
		var field = document.getElementById(pts[n][0]+"_"+pts[n][1]);
		field.setAttribute("fill","red");
		var point = svgRoot.createSVGPoint();
		point.x = parseInt(pts[n][0], 10);
		point.y = parseInt(pts[n][1], 10);
		tp.points.appendItem(point);
		if (n<pts.length-1)
			window.setTimeout("extendLine(" +(n+1)+ ")", 100);
	}
	//]]>
	</script>

	<g transform="translate(%d, %d) scale(%d)">
		<g fill="white" stroke="gray" stroke-width="0.025">
%s
			<g transform="translate(0.5,0.5)">
				<circle cx="%d" cy="%d" r="0.1" stroke="none" fill="black" />
				<polyline id="tourpath" points="%s" stroke="black" stroke-width="0.05" fill="none" />
			</g>
		</g>
	</g>
</svg>
}, img_x, img_y, img_x, img_y,
		this.board_x, this.board_y,
		this.padding, this.padding, this.scale,
		getRects(),
		this.path[0][0], this.path[0][1], getPathString());
	}

}

void main(string args[]) {
	// reading a file we chop of every time we hit an empty Line
	string [] tour;

	BufferedFile tours = new BufferedFile;
	tours.open(args[1], FileMode.In);
	while(!tours.eof)
	{
		string chunk = cast(string) tours.readLine();
		if (chunk != "")
		{
			tour ~= chunk;
		}
		else
		{
			Tour t = new Tour(tour);
			//writefln(t.make_svg());
			t.writeToFile();
			tour=null;
		}
	}
}
