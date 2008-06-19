#!/usr/bin/perl -w
use strict;

@ARGV > 1 or die "Not enough arguments!\nUsage: $0 <coord1> ... <coordN>\n";

my @coor;
foreach my $square (@ARGV) {
    my ($col, $row) = (lc($square) =~ /^([a-h])([1-8])$/)
        or die "Argument '$square' is not a valid square.\n";
    push @coor, [ord($col)-ord("a"), 8-$row];
}

my @path = map join(",", @$_), @coor;

my $angle = atan2($coor[-1][1] - $coor[-2][1], $coor[-1][0] - $coor[-2][0]) * 45 / atan2(1,1);

print <<"END";
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg width="340" height="340" version="1.1" viewBox="0 0 340 340"
  xmlns="http://www.w3.org/2000/svg">

  <g transform="translate(10,10) scale(40)">
    <g fill="white" stroke="gray" stroke-width="0.025">
      <rect x="0" y="0" width="8" height="8" />

      <line x1="0" x2="8" y1="1" y2="1" />
      <line x1="0" x2="8" y1="2" y2="2" />
      <line x1="0" x2="8" y1="3" y2="3" />
      <line x1="0" x2="8" y1="4" y2="4" />
      <line x1="0" x2="8" y1="5" y2="5" />
      <line x1="0" x2="8" y1="6" y2="6" />
      <line x1="0" x2="8" y1="7" y2="7" />

      <line y1="0" y2="8" x1="1" x2="1" />
      <line y1="0" y2="8" x1="2" x2="2" />
      <line y1="0" y2="8" x1="3" x2="3" />
      <line y1="0" y2="8" x1="4" x2="4" />
      <line y1="0" y2="8" x1="5" x2="5" />
      <line y1="0" y2="8" x1="6" x2="6" />
      <line y1="0" y2="8" x1="7" x2="7" />
    </g>

    <g transform="translate(0.5,0.5)">
      <circle cx="$coor[0][0]" cy="$coor[0][1]" r="0.1" stroke="none" fill="black" />

      <polyline points="@path" stroke="black" stroke-width="0.05" fill="none" />

      <g transform="translate($path[-1]) scale(0.025) rotate($angle)">
        <path d="M5,0 L-10,5 A3,5 0 0,0 -10,-5 C" stroke="none" fill="black" />
      </g>
    </g>
  </g>
</svg>
END

__END__
