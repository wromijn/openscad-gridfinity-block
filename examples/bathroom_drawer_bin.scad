use <../gridfinity_block.scad>

$fn=128;

gridfinity_block([ 2, 2, 6 ]) {
    gb_round_hole([ 28, 28 ], 50, $inner_height);
    gb_round_hole([ 60, 60 ], 35, $inner_height);
    gb_round_hole([ 68, 21 ], 18.5, 22);
}