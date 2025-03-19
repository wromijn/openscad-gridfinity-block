use <../gridfinity_block.scad>;

$fn=128;

gridfinity_block([4,1,4], center=true) {

    // holes for storing 2 packs of ink cartridges
    gb_square_hole([ -$inner_width / 4, $inner_length / 2 - 6 ], [50,10], depth = $inner_height, center = true);
    gb_square_hole([ $inner_width / 4, $inner_length / 2 - 6 ], [50,10], depth = $inner_height, center = true);

    // hole for the pen, slightly recessed because we can
    gb_square_hole([ -$inner_width / 2, -$inner_length / 2 ], [ $inner_width, $inner_length - 13 ], depth = 5);
    translate([ -74, -6, -5 ]) {
        pen_hole();
    }
    // recess for easier grabbing
    translate([ 0, -6, -3 ]) {
        scale([ 2, 1.25, 0.9 ]) {
            sphere(d = 20);
        }
    }
}

module pen_hole() {
    sphere(d = 14);
    rotate([ 0, 90, 0 ]) {
        cylinder(h = 60, d = 14);
    }
    translate([ 60, 0, 0 ]) {
        sphere(d = 14);
        rotate([ 0, 90, 0 ]) {
            cylinder(h = 90, d = 12);
        }
    }
    translate([ 150, 0, 0 ]) {
        sphere(d = 12);
    }
}