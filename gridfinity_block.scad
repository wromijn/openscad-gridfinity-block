$fn=128;

// TODO: check dimensions against https://www.printables.com/model/417152-gridfinity-specification
// TODO: provide option for normal and refined feet - how about GF lite?
// TODO: there should be a mask like gb_cube_hole that you can apply to a custom shape so it doesn't protrude the rounded corner and to clean up any parts that stick out. Much easier to make custom shapes that way. After that, gb_cube_hole can be refactored to use the mask?

gf_ridge_height = 1;
gf_floor_thickness = 1;
gf_wall_thickness = 1;
gf_almost_zero = 0.001;
gf_tolerance = 0.25;

gridfinity_block([ 3, 2, 6 ], ridge = true, center = false) {
    gb_cube_hole([ 0, 0 ],[ $inner_width, $inner_length/2 ], $inner_height);
    gb_cylinder_hole([ 20.5, 61.5 ], 38, $inner_height);
}

module gb_cube_hole(pos, size, depth, radius=3.1) {
    translate([ pos[0] + radius, pos[1] + radius, -depth ]) {
        linear_extrude(h = depth + gf_almost_zero) {
            offset(r = radius) {
                square([ size[0]-2*radius, size[1]-2*radius ]);
            }
        }
    }
}

module gb_cylinder_hole(pos, d, depth) {
    translate([ pos[0], pos[1], -depth ]) {
        cylinder(h=depth + gf_almost_zero, d=d);
    }
}

module gridfinity_block(size, ridge=false, center=false) {

    block_dimensions = [
        42 * size[0] - gf_tolerance,
        42 * size[1] - gf_tolerance,
        7 * size[2] - (ridge ? gf_ridge_height : 0)
    ];

    block_position = [
        center ? 0 : block_dimensions[0] / 2 - gf_wall_thickness,
        center ? 0 : block_dimensions[1] / 2 - gf_wall_thickness,
        -block_dimensions[2]
    ];

    translate(block_position) {
        feet(size[0], size[1]);
    }

    difference() {
        offset = center ? 0 : -gf_wall_thickness;
        translate([ offset, offset, -block_dimensions[2] ]) {
            union() {
                gf_rounded_cube(block_dimensions, 3.75, center);
                if (ridge) {
                   translate([ 0, 0, block_dimensions[2] ]) {
                       ridge([ block_dimensions[0], block_dimensions[1] ], center);
                   }
                }
            }
        }

        let(
            $outer_width = block_dimensions[0],
            $outer_length = block_dimensions[1],
            $center = center,
            $inner_width = $outer_width - 2 * gf_wall_thickness,
            $inner_length = $outer_length - 2 * gf_wall_thickness,
            $inner_height = block_dimensions[2] - gf_floor_thickness - gf_ridge_height,
            $outer_height = block_dimensions[2]
        ) children();
    }
    
    module feet(number_x, number_y) {
        for(grid_x = [0:number_x-1]) {
            for(grid_y = [0:number_y-1]) {
                foot_xpos = 42 * grid_x - 21 * number_x + 21;
                foot_ypos = 42 * grid_y - 21 * number_y + 21;
                translate([ foot_xpos, foot_ypos, 0 ]) {
                    foot() {
                        magnet_holes();
                    }
                }
            }
        }
            
        module foot() {
            //            [width, height, radius]
            foot_layer1 = [35.6, 0.8, 0.8];
            foot_layer2 = [37.2, 2.6, 1.6];
            foot_layer3 = [41.5, 2.15, 3.75];
            foot_height = foot_layer1[1] + foot_layer2[1] + foot_layer3[1];
            
            difference() {
                union() {
                    hull() {
                        gf_rounded_cube([ foot_layer3[0], foot_layer3[0], gf_almost_zero ], foot_layer3[2], true);
                        translate([ 0, 0, -foot_layer3[1] ]) {
                            gf_rounded_cube([ foot_layer2[0], foot_layer2[0], gf_almost_zero ], foot_layer2[2], true);
                        }
                    }
                    
                    hull() {
                        translate([ 0, 0, -foot_layer3[1] - foot_layer2[1] ]) {
                            gf_rounded_cube([foot_layer2[0], foot_layer2[0], foot_layer2[1]], foot_layer2[2], true);
                        }
                        translate([ 0, 0, -foot_layer3[1] - foot_layer2[1] - foot_layer1[1] ]) {
                            gf_rounded_cube([ foot_layer1[0], foot_layer1[0], gf_almost_zero ], foot_layer1[2], true);
                        }
                    }
                }
                translate([ 0, 0, -foot_height ]) { children(); }
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

    module ridge(size, center) {
        difference() {
            linear_extrude(h = gf_ridge_height) {
                difference() {
                    gf_rounded_square(size, radius = 3.75, center = center);
                    offset = center ? 0 : gf_wall_thickness;
                    translate([offset, offset, 0]) {
                        gf_rounded_square(
                            [ size[0] - 2 * gf_wall_thickness, size[1] - 2 * gf_wall_thickness ],
                            radius = 3.1,
                            center = center);
                    }
                }
            }
            hull() {
                offset = center ? 0 : gf_wall_thickness;
                translate([offset, offset, gf_ridge_height/2]) {
                    gf_rounded_cube(
                        [ size[0] - 2 * gf_wall_thickness, size[1] - 2 * gf_wall_thickness, 1 ],
                        radius = 3.1,
                        center = center);
                }
                translate([offset/2, offset/2, gf_ridge_height]) {
                    gf_rounded_cube(
                        [ size[0] - gf_wall_thickness, size[1] - gf_wall_thickness, 1 ],
                        radius = 3.4,
                        center = center);
                }
            }
        }
    }

    module gf_rounded_cube(size, radius, center = false) {
        linear_extrude(h = size[2]) {
            gf_rounded_square(size, radius, center);
        }
    }

    module gf_rounded_square(size, radius, center = false) {
        offset = center ? 0 : radius;
        corrected_size = [ size[0] - (2 * radius),  size[1] - (2 * radius) ];
        translate([ offset, offset, 0 ]) {
            offset(r = radius) {
                square(corrected_size, center=center);
            }
        }
    }
}
