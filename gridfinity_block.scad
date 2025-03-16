// Copyright (c) 2025 The Gridfinity Block Contributors
// Licensed under the Apache License, Version 2.0 (see LICENSE file)
// https://github.com/wromijn/openscad-gridfinity-block

/* [Hidden] */
gf_wall_thickness = 1.3;
gf_almost_zero = 0.01;

module gb_square_hole(pos, size, depth, radius = 0.8, center = false) {
    difference() {
        translate([ pos[0], pos[1], -depth ]) {
            _gb_rounded_cube([ size[0], size[1], depth + gf_almost_zero ], radius = radius, center = center);
        }
        offset_x = center ? -size[0] / 2 : 0;
        offset_y = center ? -size[1] / 2 : 0;
        
        translate([ offset_x-gf_almost_zero, offset_y-gf_almost_zero, -depth]) {
            let(
                $inner_width = $inner_width + 2 * gf_almost_zero,
                $inner_length = $inner_length + 2 * gf_almost_zero
            ) {
                children();
            }
        }
    }
}

module gb_round_hole(pos, d, depth) {
    difference() {
        translate([ pos[0], pos[1], -depth ]) {
            cylinder(h=depth + gf_almost_zero, d=d);
        }
        translate([ pos[0], pos[1], -depth ]) {
            children();
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
                $center = center,
                $inner_width = size[0] - 2 * gf_wall_thickness,
                $inner_length = size[1] - 2 * gf_wall_thickness,
                $inner_height = size[2] - floor_thickness,
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
