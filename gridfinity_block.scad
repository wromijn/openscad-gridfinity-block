$fn=128;

gf_wall_thickness = 1.3;
gf_almost_zero = 0.001;

// TODO: cleanup, separate examples from lib, get rid of global vars

//gridfinity_block([ 3, 2, 6 ], stacking_lip = true, center = true) {
//    gb_cube_hole([ -$inner_width/2, -$inner_length/2 ],[ $inner_width, $inner_length/2 ], $inner_height);
//    gb_cylinder_hole([ 0, $inner_length/4 ], 38, $inner_height);
//}
//translate([100, 0, 0]) {
//    gridfinity_block([ 3, 2, 6 ], stacking_lip = true, center = false) {
//        gb_cube_hole([ 0, 0 ],[ $inner_width, $inner_length/2 ], $inner_height);
//        gb_cylinder_hole([ 21 + $inner_width / 3, 21 + $inner_length / 2 ], 38, $inner_height);
//    }
//}


if($preview) {
    translate([-100,0,-42]) {
        scooped_bin(42,42,42,10);
    }
}

gridfinity_block([ 1, 1, 6 ], stacking_lip = true, center = false) {
    translate([0,0,-$inner_height]) {
        intersection() {
            scooped_bin($inner_width, $inner_length, $inner_height+gf_almost_zero, 10);
            gb_mask(size=[$inner_width,$inner_length,$inner_height+gf_almost_zero], center=false);
        }
    }
}

module scooped_bin(width, length, height, scoop_radius) {
    difference() {
        union() {
            translate([0, 0, scoop_radius]) {
                cube([width, length, height-scoop_radius]);
            }
            translate([0, scoop_radius, 0]) {
                cube([width, length-scoop_radius, height]);
            }
            translate([0,scoop_radius,scoop_radius]) {
                rotate([0,90,0]) {
                    cylinder(r=scoop_radius, h=width);
                }
            }
        }
        translate([-gf_almost_zero, length-10, height-1]) {
            cube([width+2*gf_almost_zero, 10+gf_almost_zero, 1+gf_almost_zero]);
        }
    }
}

module gb_mask(size, center=false, radius=0.8) {
    size_vector = is_list(size) ? size : [size, size, size];
    offset_xy = center ? 0 : radius;
    offset_z = center ? -size[2]/2 : 0;
    translate([ offset_xy, offset_xy, offset_z ]) {
        linear_extrude(h = size_vector[2]) {
            offset(r = radius) {
                square([ size_vector[0]-radius*2, size_vector[1]-radius*2 ], center=center);
            }
        }
    }
}

module gb_cube_hole(pos, size, depth, radius=0.8, label=false) {
    translate([ pos[0], pos[1], -depth ]) {
        gb_mask([size[0], size[1], depth+gf_almost_zero], radius=radius, label=label);
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
                rounded_cube(size, 3.75, true);
                if (stacking_lip) {
                   translate([ 0, 0, size[2] ]) {
                       stacking_lip([ size[0], size[1] ], true);
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
        // [width, length, height, radius]
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
                    foot(foot_layers) {
                        magnet_holes();
                    }
                }
            }
        }
        
        let($feet_height = foot_layers[len(foot_layers)-1][2]) {
            children();
        }
            
        module foot(layers) {           
            difference() {
                rounded_hull(layers);
                children();
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
        // [width, length, height, radius]
        lip_layers = [
            [ size[0] - 2.6, size[1] - 2.6, -gf_almost_zero, 0.8 ], [ size[0] - 1.9, size[1] - 1.9, 0.7, 1.6 ],
            [ size[0] - 1.9, size[1] - 1.9, 0.7, 1.6 ], [ size[0] - 1.9, size[1] - 1.9, 2.5, 1.6 ],
            [ size[0] - 1.9, size[1] - 1.9, 2.5, 1.6 ], [ size[0], size[1], 4.4, 3.75 ]
        ]; 
        
        difference() {
            rounded_cube([ size[0], size[1], 4.4 ], 3.75, center);
            rounded_hull(lip_layers);
        }
    }

    module rounded_cube(size, radius, center = false) {
        linear_extrude(h = size[2]) {
            rounded_square(size, radius, center);
        }
    }

    module rounded_square(size, radius, center = false) {
        offset = center ? 0 : radius;
        corrected_size = [ size[0] - (2 * radius),  size[1] - (2 * radius) ];
        translate([ offset, offset, 0 ]) {
            offset(r = radius) {
                square(corrected_size, center = center);
            }
        }
    }
    
    // [ [width, length, height, radius], ... ]
    module rounded_hull(layers) {
        for(layerIx = [0:2:len(layers)-1]) {
            layer = layers[layerIx];
            nextLayer = layers[layerIx+1];
            translate([ 0, 0, layer[2] ]) {
                if (have_same_dimensions(layer, nextLayer)) {              
                    rounded_cube([ layer[0], layer[1], nextLayer[2] ], layer[3], center = true);
                } else {
                    hull() {
                        rounded_cube([ layer[0], layer[1], gf_almost_zero ], layer[3], center = true);
                        translate([ 0, 0, nextLayer[2]-layer[2] ]) {
                            rounded_cube([ nextLayer[0], nextLayer[1], gf_almost_zero ], nextLayer[3], center = true);
                        }
                    }   
                }            
            }
        }
        function have_same_dimensions(layer1, layer2) =
            layer1[0] == layer2[0] && layer1[1] == layer2[1] && layer1[3] == layer2[3];
    }
}
