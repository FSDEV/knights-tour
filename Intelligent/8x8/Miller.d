module knightstour.Miller;

import tango.io.Stdout;
import tango.io.Console;

import tango.stdc.stdlib;

import Integer = tango.text.convert.Integer;

int[8][8] board;

struct loc {
	int x;
	int y;
	int get_access_for() {
		return access[x][y];
	}
	int opCmp(loc l) {
		return get_access_for() - l.get_access_for();
	}
}

/// how many other tiles each tile may be accessed from
const int[8][8] access=[
	[2, 4, 6, 6, 6, 6, 4, 2],
	[4, 6, 8, 8, 8, 8, 6, 4],
	[6, 6, 8, 8, 8, 8, 6, 6],
	[6, 6, 8, 8, 8, 8, 6, 6],
	[6, 6, 8, 8, 8, 8, 6, 6],
	[6, 6, 8, 8, 8, 8, 6, 6],
	[4, 6, 8, 8, 8, 8, 6, 4],
	[2, 4, 6, 6, 6, 6, 4, 2]
];

// vectors[x=0/y=1][move#]
const int vectors[2][8]=[
	[1, 1,-1,-1, 2, 2,-2,-2],
	[2,-2, 2,-2, 1,-1, 1,-1]
];

loc[] get_legal_moves(loc position) {
	loc[] legal_moves;
	loc new_loc;
	for(int i=0; i!=8; i++) {
		new_loc.x=position.x+vectors[0][i];
		new_loc.y=position.y+vectors[1][i];
		if(isLegalLocation(new_loc)&&board[new_loc.x][new_loc.y]<0)
			legal_moves~=new_loc;
	}
	return legal_moves.sort;
}

bool isLegalLocation(loc l) {
	return
		(l.x<8&&l.x>-1)
			&&
		(l.y<8&&l.y>-1)
	;
}

void clear_board() {
	for(int i=0; i!=8; i++)
		for(int j=0; j!=8; j++)
			board[i][j]=-1;
}

int move(loc myloc) {
	board[myloc.x][myloc.y]=moves_left++;
	steps++;
	if(moves_left==64) {
		return 0;
	}
	loc[] moves=get_legal_moves(myloc);
	foreach( loc l; moves ) {
		if(move(l)==0)
			return 0;
	}
	board[myloc.x][myloc.y]=-1;
	moves_left--;
	return -1;
}

void print_board() {
	foreach(int[8] i; board) {
		Stdout.format("||{}||{}||{}||{}||{}||{}||{}||{}||\n",
			i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7]);
	}
	Cout.newline;
}

int moves_left=0;
ulong steps=0;
char[] blah;

void main(char[][] args) {
	loc moveloc;
	for(int start_loc_x=0; start_loc_x!=8; start_loc_x++)
		for(int start_loc_y=0; start_loc_y!=8; start_loc_y++) {
			clear_board(); moves_left=0;
			steps=0;
			moveloc.x=start_loc_x;
			moveloc.y=start_loc_y;
			move(moveloc);
			Stdout.format("found solution {} {} in {} steps\n", start_loc_x, start_loc_y, steps);
			print_board();
			blah=Cin.get;
			if(blah=="exit") {
				Cout("Exiting").newline;
				exit(0);
			}
		}
}

