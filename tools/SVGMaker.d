module knightstour.SVGMaker;

/// SVG Image Maker derived from Ilmari Karonen's Perl script
/// http://en.wikipedia.org/wiki/User:Ilmari_Karonen/chesstour-svg.pl

import tango.core.Array;

import tango.io.Stdout;

import Integer = tango.text.convert.Integer;
import Float = tango.text.convert.Float;
import txtUtil=tango.text.util;

import tango.io.FileConduit;
import tango.util.Arguments;

import tango.util.ArgParser;

import tango.stdc.stdlib;

import tango.io.stream.LineStream;

import tango.math.Math;

char[] test_path="3,4 5,3 3,2 4,0 2,1 0,0 1,2 0,4 1,6 3,7 5,6 7,7 6,5 7,3 6,1"~
	" 4,2 5,0 3,1 1,0 0,2 1,4 0,6 2,7 4,6 6,7 7,5 5,4 3,5 2,3 4,4 2,5 3,3 4,5"
	~" 2,4 4,3 2,2 3,0 1,1 0,3 1,5 0,7 2,6 4,7 6,6 7,4 6,2 7,0 5,1 7,2 6,4 7,6 "
	~"5,7 3,6 1,7 0,5 1,3 0,1 2,0 4,1 6,0 5,2 7,1 6,3 5,5 3,4";

void main(char args[][]) {
	
	bool file_mode=false;
	bool force=false;
	char[] file;
	char[] output_file;
	char[] path;
	char[] url_path; // http://www.fsdev.net/attachments/wiki/knights-tour/User/*.svg
	// wiki output would look like
	// '''found solution for # # in # steps
	// [[Image(url_path~svgname.svg)]]
	// 
	int board_x;
	int board_y;

	char[] wiki_output="";
	
	ArgParser parser=new ArgParser();
	parser.bind("-", "board_x",(char[] value){
			board_x=Integer.parse(value);
	});
	parser.bindPosix("url_path", (char[] value){
			url_path=value;
	});
	parser.bind("-", "board_y",(char[] value){
			board_y=Integer.parse(value);
	});
	parser.bindDefault("",(char[] value, uint ordinal){
			Stdout.format("Unrecognized argument {} at {}", value, ordinal).newline;
			exit(0);
	});
	parser.bind("", "f", {
			file_mode=true;
	});
	parser.bind("", "F", {
			force=true;
	});
	parser.bindPosix("path", (char[] value){
			path=value;
	});
	parser.bindPosix("output-file", (char[] value){
			output_file=value;
	});
	parser.bindPosix("file", (char[] value){
			file=value;
	});
	
	parser.parse(args[1 .. $]);
	
	if(!file_mode&&file!=""){
		Stdout("Whoops... you specified a file, but the file mode"
			~" switch (f) isn't active!").newline;
		exit(0);
	}
	
	if(!file_mode&&output_file==""){
		Stdout("No output file specified.  Stop.").newline;
		/+exit(0);+/
	}
	
	// if the output file is existing, and force is false, stop.
	
	if(!path){
		path=test_path;
		board_x=8;
		board_y=8;
	}

	/*
	 * If in file mode open the file for reading.  Parse it in.
	 */
	 
	if(file_mode){
		solution_board boards[]; char temp[];
		solution_board current=solution_board(); location tloc;
		int curr=0;
		solution_board blank_board;
		int x; int y;
		
		boards~=solution_board();
		
		FileConduit fcond=new FileConduit(file);
		FileConduit fcond2;
		scope(exit)fcond.close();
		
		LineInput lines=new LineInput(fcond.input);
		
		foreach(char[] line; lines){
			if(line.length==0) {
				current.max_x=x; current.x=x; current.y=y;
				if(x!=0&&y!=0) {
					char[] filename="svg"~Integer.toString(curr)~".svg";
					fcond2=new FileConduit(filename, FileConduit.WriteCreate);
					if(url_path)
						wiki_output~="[[Image("~url_path~"/"~filename~")]]\n\n";
					fcond2.output.write(make_svg(current.get_path(), current.max_x, current.max_y, 10));
					fcond2.close();
					x=0; y=0;
					curr++;
					current.max_x=0; current.max_y=0;
					current.board=null;
					current.x=0; current.y=0;
					current.steps=0;
				}
			}
			else if( contains(line, "||") /+ line[0..1]=="||"+/){
				char[][] nums=txtUtil.split(line, "||");
				y=nums.length;
				
				foreach(int k, char num[]; nums){
					if(num==""){
						y--;
						continue;
					}
					tloc.x=x; tloc.y=k-1;
					tloc.order=Integer.parse(num);
					current.board~=tloc;
				}
				
				if(y>current.max_y)current.max_y=y;
				x++;
			}
			else if( contains(line, "found") /+line[0..4]=="found"+/){
				temp=""; int xnoty=0;
				if(url_path)
					wiki_output~="'''"~line~"'''\n\n";
				foreach(char c; line){
					if(c>'0'&&c<'9')
						temp~=c;
					else if(temp.length==0) { }
					else {
						if(xnoty==0)current.x=Integer.parse(temp);
						else if(xnoty==1)current.y=Integer.parse(temp);
						else if(xnoty==2)current.steps=Integer.parse(temp);
						xnoty++;
					}
				}
			}
		}
		fcond.close();
		Stdout(wiki_output);
	} else Stdout(make_svg(path, board_x, board_y, 10));
}

struct location {
	int x; int y;
	int order;
	int opCmp(location l) {
		return order-l.order;
	}
	char[] get_loc(){
		return Integer.toString(y)~","~Integer.toString(x);
	}
}

struct solution_board {
	int x; int y; int steps; int max_x; int max_y;
	location[] board;
	int opCmp(solution_board s){
		return steps-s.steps;
	}
	char[] get_path(){
		board.sort; char[] path;
		//Stdout.format("board size {} x {} y {} maxx {} maxy {}", board.length, x, y, max_x, max_y).newline;
		foreach(location l; board){
			path~=l.get_loc()~" ";
		}
		return path[0 .. $-1]; // gets rid of the trailing space
	}
}

const int scale=40;

char[] make_svg(
	char[] path,
	int board_x, int board_y,
	int padding=10
) {
	int img_x=(padding * 2)+(board_x * scale);
	int img_y=(padding * 2)+(board_y * scale);
	char[] svg="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n";
	svg~="<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n";
	svg~="  \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n\n";
	svg~="<svg width=\""~Integer.toString(img_x)~"\" height=\""~
		Integer.toString(img_y)~"\" version=\"1.1\" viewBox=\"0 0 "~
		Integer.toString(img_x)~" "~Integer.toString(img_y)~"\"\n";
	svg~="  xmlns=\"http://www.w3.org/2000/svg\">\n\n";
	svg~="  <g transform=\"translate("~Integer.toString(padding)~
		","~Integer.toString(padding)~") scale("~Integer.toString(scale)~
		")\">\n";
	svg~="    <g fill=\"white\" stroke=\"gray\" stroke-width=\"0.025\">\n";
	svg~="      <rect x=\"0\" x2=\"0\" width=\""~Integer.toString(board_x)~
		"\" height=\""~Integer.toString(board_y)~"\" />\n\n";
	for(int i=1; i!=board_y; i++)
		svg~="      <line x1=\"0\" x2=\""~Integer.toString(board_x)~
			"\" y1=\""~Integer.toString(i)~"\" y2=\""~Integer.toString(i)~
			"\" />\n";
	svg~="\n";
	for(int i=1; i!=board_x; i++)
		svg~="      <line y1=\"0\" y2=\""~Integer.toString(board_y)~
			"\" x1=\""~Integer.toString(i)~"\" x2=\""~Integer.toString(i)~
			"\" />\n";
	svg~="\n";
	svg~="      <g transform=\"translate(0.5,0.5)\">\n";
	char individuals[][]=txtUtil.split(path, " ");
	char circ[][]=txtUtil.split(individuals[0], ",");
	svg~="        <circle cx=\""~circ[0]~"\" cy=\""~
		circ[1]~"\" r=\"0.1\" stroke=\"none\" fill=\"black"~
		"\" />\n";
	svg~="        <polyline points=\""~path~"\" stroke=\"black\" "~
		"stroke-width=\"0.05\" fill=\"none\" />\n\n";
	char arr0[][]=txtUtil.split(individuals[$-1], ",");
	char arr1[][]=txtUtil.split(individuals[$-2], ",");
	real angle=atan2(Integer.parse(arr0[1])-Integer.parse(arr1[1]),
		Integer.parse(arr0[0])-Integer.parse(arr1[0]))*45/atan2(1,1);
	svg~="        <g transform=\"translate("~individuals[$-1]~") scale(0."~
		"025) rotate("~Float.toString(angle)~")\">\n";
	svg~="          <path d=\"M5,0 L-10,5 A3,5 0 0,0 -10,-5 C\" stroke=\"none\" fill=\"black\" />\n";
	svg~="        </g>\n\n";
	svg~="      </g>\n\n    </g>\n  </g>\n</svg>\n";
	
	return svg;
}

