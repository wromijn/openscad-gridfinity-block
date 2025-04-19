// Copyright (c) 2025 The Gridfinity Block Contributors
// Licensed under the Apache License, Version 2.0 (see LICENSE file)
// https://github.com/wromijn/openscad-gridfinity-block

assert(version_num() >= 20211200, "This library requires OpenSCAD 2021.12 or newer - sorry :(");

// Show test object
gf_run_test = "None"; // [None, Features, Coordinates]

/* [Hidden] */
gf_wall_thickness = 1.3;
gf_almost_zero = 0.01;
$fn=128;

module gb_square_hole(pos, size, depth, radius = 0.8, center = false) {
    difference() {
        translate([ pos[0], pos[1], -depth ]) {
            _gb_rounded_cube([ size[0], size[1], depth + gf_almost_zero ], radius = radius, center = center);
        }
        offset_x = center ? pos[0] - size[0] / 2 : pos[0];
        offset_y = center ? pos[1] - size[1] / 2 : pos[1];
        
        translate([ offset_x-gf_almost_zero, offset_y-gf_almost_zero, -depth]) {
            let(
                $inner_width = size[0] + 2 * gf_almost_zero,
                $inner_length = size[1] + 2 * gf_almost_zero,
                $inner_height = depth
            ) {
                children();
            }
        }
    }
}

module gb_round_hole(pos, diameter, depth) {
    difference() {
        translate([ pos[0], pos[1], -depth ]) {
            cylinder(h=depth + gf_almost_zero, d=diameter);
        }
        translate([ pos[0], pos[1], -depth ]) {
            let(
                $inner_width = diameter,
                $inner_length = diameter,
                $inner_height = depth
            ) {
                children();
            }
        }
    }
}

module gridfinity_block(size, stacking_lip = false, center = false) {

    tolerance = 0.5;

    bin_dimensions = [
        42 * size[0] - tolerance,
        42 * size[1] - tolerance,
        7 * size[2]
    ];

    feet_position = [
        center ? 0 : bin_dimensions[0] / 2 - gf_wall_thickness,
        center ? 0 : bin_dimensions[1] / 2 - gf_wall_thickness,
        -bin_dimensions[2]
    ];

    translate(feet_position) {
        feet(size[0], size[1]) {
            block_dimensions = [
                bin_dimensions[0],
                bin_dimensions[1],
                bin_dimensions[2] - $feet_height
            ];

            block_position = [
                0,
                0,
                $feet_height
            ];

            translate(block_position) {
                block(block_dimensions, center) {
                    children();
                }
            }
        }
    }

    module block(size, center) {
        difference() {
            union() {
                _gb_rounded_cube(size, 3.75, true);
                if (stacking_lip) {
                   translate([ 0, 0, size[2] ]) {
                       stacking_lip([ size[0], size[1] ], true);
                   }
                }
            }

            floor_thickness = 1;

            let(
                $inner_width = size[0] - 2 * gf_wall_thickness,
                $inner_length = size[1] - 2 * gf_wall_thickness,
                $inner_height = size[2] - floor_thickness
            ) {
                children_x_offset = center ? 0 : -$inner_width / 2;
                children_y_offset = center ? 0 : -$inner_length / 2;
                translate([ children_x_offset, children_y_offset, $inner_height + floor_thickness ]) {
                    children();
                }
            }
        }
    }

    module feet(number_x, number_y) {
        // [ [width, length, height, radius], ... ]
        foot_layers = [
            [35.6, 35.6, 0, 0.8], [37.2, 37.2, 0.8, 1.6],
            [37.2, 37.2, 0.8, 1.6], [37.2, 37.2, 2.6, 1.6],
            [37.2, 37.2, 2.6, 1.6], [41.5, 41.5, 4.75, 3.75]
        ];

        for(grid_x = [0:number_x-1]) {
            for(grid_y = [0:number_y-1]) {
                foot_xpos = 42 * grid_x - 21 * number_x + 21;
                foot_ypos = 42 * grid_y - 21 * number_y + 21;
                translate([ foot_xpos, foot_ypos, 0 ]) {
                    foot(foot_layers);
                }
            }
        }

        let($feet_height = foot_layers[len(foot_layers)-1][2]) {
            children();
        }

        module foot(layers) {
            difference() {
                rounded_hull(layers);
                magnet_holes();
            }
        }

        module magnet_holes() {
            translate([ 13, 13, 1 ]) { magnet_hole(); }
            translate([ 13, -13, 1 ]) { magnet_hole(); }
            translate([ -13, 13, 1 ]) { magnet_hole(); }
            translate([ -13, -13, 1 ]) { magnet_hole(); }

            module magnet_hole() {
                cylinder(d = 6, h = 2 + gf_almost_zero, center = true);
            }
        }
    }

    module stacking_lip(size, center) {
        // [ [width, length, height, radius], ... ]
        lip_layers = [
            [ size[0] - 2.6, size[1] - 2.6, -gf_almost_zero, 0.8 ], [ size[0] - 1.9, size[1] - 1.9, 0.7, 1.6 ],
            [ size[0] - 1.9, size[1] - 1.9, 0.7, 1.6 ], [ size[0] - 1.9, size[1] - 1.9, 2.5, 1.6 ],
            [ size[0] - 1.9, size[1] - 1.9, 2.5, 1.6 ], [ size[0], size[1], 4.4, 3.75 ]
        ];

        difference() {
            _gb_rounded_cube([ size[0], size[1], 4.4 ], 3.75, center);
            rounded_hull(lip_layers);
        }
    }

    // [ [width, length, height, radius], ... ]
    module rounded_hull(layers) {
        for(layerIx = [0:2:len(layers) - 1]) {
            layer = layers[layerIx];
            nextLayer = layers[layerIx + 1];
            translate([ 0, 0, layer[2] ]) {
                if (have_same_dimensions(layer, nextLayer)) {
                    _gb_rounded_cube([ layer[0], layer[1], nextLayer[2] ], layer[3], center = true);
                } else {
                    hull() {
                        _gb_rounded_cube([ layer[0], layer[1], gf_almost_zero ], layer[3], center = true);
                        translate([ 0, 0, nextLayer[2] - layer[2] ]) {
                            _gb_rounded_cube([ nextLayer[0], nextLayer[1], gf_almost_zero ], nextLayer[3], center = true);
                        }
                    }
                }
            }
        }
        function have_same_dimensions(layer1, layer2) =
            layer1[0] == layer2[0] && layer1[1] == layer2[1] && layer1[3] == layer2[3];
    }
}

module _gb_rounded_cube(size, radius, center = false) {
    linear_extrude(h = size[2]) {
        _gb_rounded_square(size, radius, center);
    }
}

module _gb_rounded_square(size, radius, center = false) {
    offset = center ? 0 : radius;
    corrected_size = [ size[0] - (2 * radius),  size[1] - (2 * radius) ];
    translate([ offset, offset, 0 ]) {
        offset(r = radius) {
            square(corrected_size, center = center);
        }
    }
}

// A test block that uses almost all features - if it looks different, something is wrong 
if (gf_run_test == "Features") {        
    gridfinity_block([ 3, 2, 6 ], center = false, stacking_lip = true) {
        // square holes of different depth
        gb_square_hole([ 0, 0 ], [ 30, 20 ], 10);
        gb_square_hole([ 31, 0 ], [ 30, 20 ], 20);
        
        gb_square_hole([ 0, 21 ], [ 61, $inner_length-21 ], $inner_height) {
            // coordinates inside a square hole range from [0,0,0] to [$inner_width, $inner_length, $inner_height]
            translate([ $inner_width / 2, $inner_length / 2 ]) {
                cylinder(h = 10, d = 20);
                cylinder(h = $inner_height, d = 10);
            }
            // scoop to check z-fighting mitigation
            translate([ 0, $inner_length - 20, 0 ])
            difference() {
                cube([ $inner_width, 20, 20 ]);
                translate([ 0, 0, 20 ])
                    rotate([ 0, 90, 0 ])
                        cylinder(h = $inner_width, r = 20);
            }
        }
        
        // centering a square hole doesn't affect the coordinates inside it
        gb_square_hole([ 62 + ($inner_width - 62) / 2, 16 ], [ 32, 32 ], 10, center = true) {
            // $inner_height is adjusted for the shallow square hole: both cylinders should have the same height
            translate([ 12, 12 ]) {
                cylinder(h = 7.5, d = 14);
            }
            translate([ $inner_width - 12, $inner_length - 12 ]) {
                cylinder( h = $inner_height - 2.5, d = 14);
            }
        }

        for(x = [0:2]) {
            gb_round_hole([ 20 * x + 72, 70 ], 10 + x * 2.5, 10) {
                // inside a round hole, the [0,0,0] point is the center of the floor
                cylinder(h = 10 - x * 5, d = 5);
            }
        }
        
        for(x = [0:2]) {
            gb_round_hole([ 20 * x + 72, 50], 10 + x * 2.5, 20) {
                // $inner_height is adjusted in round holes as well
                cylinder(h = $inner_height - x * 10, d = 5);
            }
        }
    }
}

// Blocks to test the coordinate systems ([0,0] at bottom left or center of top surface). Both blocks should look the same
if (gf_run_test == "Coordinates") {
    gridfinity_block([ 3, 2, 6 ], stacking_lip = true, center = true) {
        gb_square_hole([ -$inner_width/2, -$inner_length/2 ],[ $inner_width, $inner_length/2 ], $inner_height);
        gb_round_hole([ 0, $inner_length/4 ], 38, $inner_height);
    }
    translate([70, gf_wall_thickness-41.5, 0]) {
        gridfinity_block([ 3, 2, 6 ], stacking_lip = true, center = false) {
            gb_square_hole([ 0, 0 ],[ $inner_width, $inner_length/2 ], $inner_height);
            gb_round_hole([ 21 + $inner_width / 3, 21 + $inner_length / 2 ], 38, $inner_height);
        }
    }
}
