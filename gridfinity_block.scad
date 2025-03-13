$fn=128;

// TODO: fix stacking lip dimensions: https://www.printables.com/model/417152-gridfinity-specification
// TODO: provide option for normal and refined feet - how about GF lite?
// TODO: there should be a mask like gb_cube_hole that you can apply to a custom shape so it doesn't protrude the rounded corner and to clean up any parts that stick out. Much easier to make custom shapes that way. After that, gb_cube_hole can be refactored to use the mask?

gf_wall_thickness = 1;
gf_almost_zero = 0.001;

gridfinity_block([ 3, 2, 6 ], stacking_lip = true, center = false) {
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
        echo(block_position)
            translate(block_position) {
                block(block_dimensions, true);
            }
        }
    }
    
    module block(size, center) {
        difference() {
            union() {
                gf_rounded_cube(size, 3.75, center);
                if (stacking_lip) {
                   translate([ 0, 0, size[2] ]) {
                       stacking_lip([ size[0], size[1] ], center);
                   }
                }
            }

            floor_thickness = 1;
            
            let(
                $outer_width = size[0],
                $outer_length = size[1],
                $center = center,
                $inner_width = $outer_width - 2 * gf_wall_thickness,
                $inner_length = $outer_length - 2 * gf_wall_thickness,
                $inner_height = size[2] - floor_thickness,
                $outer_height = size[2]
            ) children();
        }
    }
    
    module feet(number_x, number_y) {
        // [width, height, radius]
        foot_layers = [
            [35.6, 0.8, 0.8],
            [37.2, 1.8, 1.6],
            [41.5, 2.15, 3.75]
        ];
    
        for(grid_x = [0:number_x-1]) {
            for(grid_y = [0:number_y-1]) {
                foot_xpos = 42 * grid_x - 21 * number_x + 21;
                foot_ypos = 42 * grid_y - 21 * number_y + 21;
                translate([ foot_xpos, foot_ypos, 0 ]) {
                    foot(foot_layers) {
                        magnet_holes();
                    }
                }
            }
        }
        
        let($feet_height = foot_height(foot_layers)) {
            children();
        }
            
        module foot(layers) {            
            difference() {
                union() {
                    hull() {
                        gf_rounded_cube([ layers[0][0], layers[0][0], gf_almost_zero ], layers[0][2], true);
                        translate([ 0, 0, layers[0][1] ]) {
                            gf_rounded_cube([layers[1][0], layers[1][0], layers[1][1]], layers[1][2], true);
                        }
                    }
                    hull() {
                        translate([ 0, 0, layers[0][1] + layers[1][1] ]) {
                            gf_rounded_cube([ layers[1][0], layers[1][0], gf_almost_zero ], layers[1][2], true);
                        }
                        translate( [0, 0, layers[0][1] + layers[1][1] + layers[2][1] ]) {
                            gf_rounded_cube([ layers[2][0], layers[2][0], gf_almost_zero ], layers[2][2], true);
                        }
                    }
                }
                children();
            }
        }
        
        function foot_height(layers) =
            layers[0][1] + layers[1][1] + layers[2][1];
    
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
        gf_stacking_lip_height = 1;
        
        difference() {
            linear_extrude(h = gf_stacking_lip_height) {
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
                translate([offset, offset, gf_stacking_lip_height/2]) {
                    gf_rounded_cube(
                        [ size[0] - 2 * gf_wall_thickness, size[1] - 2 * gf_wall_thickness, 1 ],
                        radius = 3.1,
                        center = center);
                }
                translate([offset/2, offset/2, gf_stacking_lip_height]) {
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
