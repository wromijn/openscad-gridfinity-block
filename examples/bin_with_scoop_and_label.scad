use <../gridfinity_block.scad>

$fn = 128;

width = 1;
length = 1;
height = 6;
label_size = 10;
label_angle = 30;
label_front_thickness = 1;
stacking_lip = true;
scoop_radius = 15;

gridfinity_block([ width, length, height ], stacking_lip = stacking_lip, center = false) {
    gb_square_hole( [0, 0], [$inner_width, $inner_length], $inner_height) {
        scoop($inner_width, scoop_radius);
        label($inner_width, $inner_length, $inner_height);
    }
}

module label(width, length, height) {
    front_thickness = label_front_thickness;
    back_thickness = front_thickness + label_size * tan(label_angle);
    hull() {
        translate([0, length-label_size, height-front_thickness])
            cube([width, label_size, front_thickness]);
        translate([0, length-1, height-back_thickness])
            cube([width, 1, back_thickness]);
    }
}

module scoop(width, scoop_radius) {
    difference() {
        cube([width, scoop_radius, scoop_radius]);
        translate([0,scoop_radius,scoop_radius])
            rotate([0,90,0])
                cylinder(h=width, r=scoop_radius);
    }
}
