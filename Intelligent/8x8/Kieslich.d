/*
 *      tkieslich.d
 *      a solver for the knights tour, this file should come with a README file
 *      check the README for details on the implementation
 *      Implemented in Digital Mars D (www.digitalmars.com/d/)
 *      For the 8x8 field used in this code the structure is overkill, because I,
 *      wanna have it running on bigger boards later
 *
 *      Copyright 2008 Tobias Kieslich [tobias evilroot net]
 *
 *      MIT LICENSE
 */

module knightstour.Kieslich;
// phobos style, it's D2.012!
import std.stdio;                  // output and debug

/// Board dimesions
invariant WIDTH  = 8;  // use x as runner
invariant HEIGHT = 8;  // use y as runner

/// MAXPOS can never be reached, as it is bigger than any accesible field.
/// Because it is bigger it will be always in the last spot when sorting
/// arrays. It is used as a placeholder for fields that are outside the
/// board or aready have been visited
invariant MAXPOS = WIDTH*HEIGHT;

/// the board that holds the tour sequence, gets filled for every new starting point
int [MAXPOS] board;

/// the main table; determines the number of accessible fields for each move (Warnsdorf's Rule)
int [MAXPOS] accessible;
/// for every new tour we grab a copy of accesible and work on it so that the
/// number of possible moves after every move gets diminished
int [MAXPOS] workAccessible;

/// for every move we get 8 candidates that get ordered as an array and instead of
/// allocating it every time we just refill it
int [8] candidates = 0;

/// Arnd Roth' idea; determines the distance from the edge
/// this number is closely realted to the number of fields
/// a knight can jump too (accessible)
/// TODO: find an easy way to calculate this
invariant int [MAXPOS] roth = [
	2,  3,  4,  5,  5,  4,  3,  2,
	3,  6,  7,  8,  8,  7,  6,  3,
	4,  7,  9, 10, 10,  9,  7,  4,
	5,  8, 10, 11, 11, 10,  8,  5,
	5,  8, 10, 11, 11, 10,  8,  5,
	4,  7,  9, 10, 10,  9,  7,  4,
	3,  6,  7,  8,  8,  7,  6,  3,
	2,  3,  4,  5,  5,  4,  3,  2
];

/// instead of calculation for every tour where a knight can jump to, we create
/// a lookup table beforehand
int [8][MAXPOS] moves;


// _                _    _   _     _____     _     _
//| |    ___   ___ | | _| | | |_ _|_   _|_ _| |__ | | ___  ___
//| |   / _ \ / _ \| |/ / | | | '_ \| |/ _` | '_ \| |/ _ \/ __|
//| |__| (_) | (_) |   <| |_| | |_) | | (_| | |_) | |  __/\__ \
//|_____\___/ \___/|_|\_\\___/| .__/|_|\__,_|_.__/|_|\___||___/
//                            |_|

/// we can get 8 possible moves from every position; maximum 8, less possible!
void getPossibleMoves(int x, int y, int position)
{
	// hardcoded moves
	// this idea was taken from Chris' entry
	invariant int [8][2] allowed = [
		[1, 1,-1,-1, 2, 2,-2,-2],
		[2,-2, 2,-2, 1,-1, 1,-1]
	];
	int dest_x, dest_y;
	for(int i=0; i<8; i++) {
		dest_x = x + allowed[0][i];
		dest_y = y + allowed[1][i];
		if (dest_x>-1 && dest_x<WIDTH && dest_y>-1 && dest_y<HEIGHT)
			moves[position][i] = (dest_x*WIDTH) + dest_y;
		else
			// not on the board -> fill with "illegal marker"
			moves[position][i] = MAXPOS;
	}
}

/// create all the lookup tables for the possible move targets
void createLookupTables()
{
	int x;
	int y;
	int position;
	short run;
	for(x=0; x<WIDTH; x++)
	{
		for(y=0; y<HEIGHT; y++)
		{
			position = x*HEIGHT + y;
			getPossibleMoves(x,y, position);

			// fill the main field with number of possible moves per field
			accessible[position] = 0;
			for(run=0; run<8; run++)
			{
				if(moves[position][run] < MAXPOS)
					accessible[position]++;
			}
		}
	}
}

//                _   __  __             _
// ___  ___  _ __| |_|  \/  | __ _  __ _(_) ___
/// __|/ _ \| '__| __| |\/| |/ _` |/ _` | |/ __|
//\__ \ (_) | |  | |_| |  | | (_| | (_| | | (__
//|___/\___/|_|   \__|_|  |_|\__,_|\__, |_|\___|
//                                 |___/
void copyAccessible()
{
	foreach(int n, int x; accessible)
	{
		workAccessible[n] = x;
	}
}

/// determines the order between 2 possible moves
bool heurSort(int a, int b)
{
	if(a == MAXPOS)
		return true;
	if(b == MAXPOS)
		return false;
	if(workAccessible[a] != workAccessible[b])
		return workAccessible[a] > workAccessible[b];
	if(roth[a] != roth[b])
		return roth[a] > roth[b];
	return false;
}

/// sorts an array of possible moves, using the heurSort() logic
int getBestMove(int pos)
{
	foreach (int n, int i; moves[pos]) {
		// fill the candidtes for that move; every field that either has been
		// visited already() or is outside the board becomes MAXPOS, so that the
		// sorting puts it back
		if(i==MAXPOS || workAccessible[i] < MAXPOS)
			candidates[n] = i;
		else
			candidates[n] = MAXPOS;
	}
	int keep,j;
	// insertion sort styled
	for(int i=1; i<candidates.length; i++)
	{
		keep = candidates[i];
		j = i-1;
		while (j >= 0 && heurSort(candidates[j], keep))
		{
			candidates[j+1] = candidates[j];
			j = j-1;
		}
		candidates[j+1] = keep;
	}
	return candidates[0];
}

/// adjust workAccessible after every move that we committed to
void diminishAccessible(int position)
{
	// the field we moved to is not accessible for further moves
	workAccessible[position] = MAXPOS;
	// all field pointing to that field have one filed less to move to
	foreach(int x; moves[position])
	{
		if (x < MAXPOS && workAccessible[x] < MAXPOS)
			workAccessible[x]--;
	}
}

void resetBoard(int [MAXPOS] board)
{
	foreach(int n, int x; board)
	{
		board[n] = 0;
	}
}


void solveBoard(int left, int top)
{
	// get the working copy of the accessible fields
	copyAccessible();
	// prepare the board with the answer
	resetBoard(board);
	int ambigous [];
	// set initial position on the board
	int position = (left*WIDTH) + top;
	for(int i=0; i<MAXPOS; i++)
	{
		board[position] = i;
		diminishAccessible(position);
		position = getBestMove(position);
	};
	printTour(board, left, top);
}

//     _      _                  ___        _               _
//  __| | ___| |__  _   _  __ _ / _ \ _   _| |_ _ __  _   _| |_
// / _` |/ _ \ '_ \| | | |/ _` | | | | | | | __| '_ \| | | | __|
//| (_| |  __/ |_) | |_| | (_| | |_| | |_| | |_| |_) | |_| | |_
// \__,_|\___|_.__/ \__,_|\__, |\___/ \__,_|\__| .__/ \__,_|\__|
//                        |___/                |_|

// for now debug functions to give me the tables
// should eventually print the final boards
void printBoard(const int [WIDTH*HEIGHT] t, int replace, int highlight)
{
	for(int x=0; x<WIDTH; x++)
	{
		for(int y=0; y<HEIGHT; y++)
		{
			if( t[x*HEIGHT+y] == highlight)
				writef("%2d!", t[x*HEIGHT+y]);
			else if( t[x*HEIGHT+y] != replace)
				writef("%2d ", t[x*HEIGHT+y]);
			else
				write(" - ");
		}
		writeln();
	}
	writefln(" -- -- -- -- -- -- -- --");
}

void printBoard(const int [WIDTH*HEIGHT] t, int replace)
{
	for(int x=0; x<WIDTH; x++)
	{
		for(int y=0; y<HEIGHT; y++)
		{
			if( t[x*HEIGHT+y] != replace)
				writef("%2d ", t[x*HEIGHT+y]);
			else
				write(" - ");
		}
		writeln();
	}
	writefln(" -- -- -- -- -- -- -- --");
}

/// print tour according to reqirement on challenge's page
void printTour(const int [WIDTH*HEIGHT] t, int left, int top)
{
	writefln("found solution %d %d in 64 steps", left, top);
	for(int x=0; x<WIDTH; x++)
	{
		for(int y=0; y<HEIGHT; y++)
		{
			writef("||%2d", t[x*HEIGHT+y]);
		}
		writeln("||");
	}
	//writefln("++--++--++--++--++--++--++--++--++");
	writefln();
}

void printMoves(int field)
{
	for(int x=0; x<MAXPOS; x++)
	{
		if(moves[x][field] != MAXPOS)
			writef("%2d ", moves[x][field]);
		else
			write(" - ");
	}
	writefln("");
}

void printReferenceBoard()
{
	for(int x=0; x<WIDTH; x++)
	{
		writefln("%2d %2d %2d %2d %2d %2d %2d %2d",
			x*HEIGHT, x*HEIGHT+1, x*HEIGHT+2, x*HEIGHT+3,
			x*HEIGHT+4, x*HEIGHT+5, x*HEIGHT+6, x*HEIGHT+7);
	}
	writefln(" -- -- -- -- -- -- -- --");
}
void printReferenceTable()
{
	for(int x=0; x<WIDTH; x++)
	{
		writef("%2d %2d %2d %2d %2d %2d %2d %2d ",
			x*HEIGHT, x*HEIGHT+1, x*HEIGHT+2, x*HEIGHT+3,
			x*HEIGHT+4, x*HEIGHT+5, x*HEIGHT+6, x*HEIGHT+7);
	}
	writefln("");
}

void main(string [] args) {
	createLookupTables();
	//printBoard(accessible);
	//printReferenceBoard();
	//printReferenceTable();
	//printMoves(0);
	//printMoves(1);
	//printMoves(2);
	//printMoves(3);
	//printMoves(4);
	//printMoves(5);
	//printMoves(6);
	//printMoves(7);
	for(int i=0; i<8; i++)
		for(int k=0; k<8; k++)
		solveBoard(i,k);
}

