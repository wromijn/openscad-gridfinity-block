$fn=128;

gf_ridge_height = 1;
gf_floor_thickness = 1;
gf_wall_thickness = 1;
gf_tolerance = 0.001;

gridfinity_block([3, 2, 6], ridge=true, center=false) {
    gb_cube_hole([0,0],[$inner_length, $inner_width/2], $inner_height);
    gb_cylinder_hole([20.5,61.5], 38, $inner_height);
}

module gb_cube_hole(pos, size, depth, radius=3.1) {
    translate([pos[0]+radius,pos[1]+radius,-depth]) {
        linear_extrude(h=depth+gf_tolerance) {
            offset(r = radius)
                square([size[0]-2*radius, size[1]-2*radius]);
        }
    }
}

module gb_cylinder_hole(pos, d, depth) {
    translate([pos[0],pos[1],-depth]) {
        cylinder(h=depth+gf_tolerance, d=d);
    }
}

module gridfinity_block(size, ridge=false, center=false) {

    //            [width, height, radius]
    foot_layer1 = [35.6, 0.8, 0.8];
    foot_layer2 = [37.2, 2.6, 1.6];
    foot_layer3 = [41.5, 2.15, 3.75];
    
    foot_height = foot_layer1[1] + foot_layer2[1] + foot_layer3[1];
    
    block_length = (42 * size[0] - 0.5);
    block_width = (42 * size[1] - 0.5);
    block_height = 7 * size[2] - (ridge ? gf_ridge_height : 0);

    offset_x = center ? 0 : block_length / 2 - gf_wall_thickness;
    offset_y = center ? 0 : block_width / 2 - gf_wall_thickness;
    offset_z = foot_height + block_height;

    translate([offset_x, offset_y, -offset_z]) {
        for(l = [0:size[0]-1]) {
            for(w = [0:size[1]-1]) {
                translate([l*42-21*(size[0]-1), w*42-21*(size[1]-1), 0]) {
                    difference() {
                        foot();
                        magnet_holes();
                    }
                }
            }
        }
    }
    
    difference() {
        d_x = center ? 0 : -gf_wall_thickness;
        d_y = center ? 0 : -gf_wall_thickness;
        translate([d_x,d_y,-block_height]) {
            union() {
                gf_rounded_cube([block_length, block_width, block_height], 3.75, center);
                if(ridge) {
                   translate([0,0,block_height]) ridge(block_length, block_width, center);
                }
            }
        }

        let(
            $outer_length = block_length,
            $outer_width = block_width,
            $center = center,
            $inner_length = $outer_length-2*gf_wall_thickness,
            $inner_width = $outer_width-2*gf_wall_thickness,
            $inner_height = block_height-gf_floor_thickness,
            $outer_height = block_height
        ) children();
    }
        
    module ridge(length, width, center) {
        difference() {
            linear_extrude(h=gf_ridge_height) {
                difference() {
                    gf_rounded_square([length, width], radius=3.75, center=center);
                    offset = center ? 0 : gf_wall_thickness;
                    translate([offset, offset, 0]) {
                        gf_rounded_square(
                            [length-2*gf_wall_thickness, width-2*gf_wall_thickness],
                            radius=3.1,
                            center=center);
                    }
                }
            }
            hull() {
                offset = center ? 0 : gf_wall_thickness;
                translate([offset, offset, gf_ridge_height/2]) {
                    gf_rounded_cube(
                        [length-2*gf_wall_thickness, width-2*gf_wall_thickness, 1],
                        radius=3.1,
                        center=center);
                }
                translate([offset/2, offset/2, gf_ridge_height])
                    gf_rounded_cube(
                        [length-gf_wall_thickness, width-gf_wall_thickness, 1],
                        radius=3.4,
                        center=center);
            }
        }
    }
        
    module foot() {
        hull() {
            gf_rounded_cube([foot_layer1[0], foot_layer1[0], 0.001], foot_layer1[2], true);    
            translate([0, 0, foot_layer1[1]])
                gf_rounded_cube([foot_layer2[0], foot_layer2[0], foot_layer2[1]], foot_layer2[2], true);
        }
        hull() {    
            translate([0, 0, foot_layer1[1] + foot_layer2[1]])
                gf_rounded_cube([foot_layer2[0], foot_layer2[0], 0.001], foot_layer2[2], true);
            translate([0, 0, foot_layer1[1] + foot_layer2[1] + foot_layer3[1]])
                gf_rounded_cube([foot_layer3[0], foot_layer3[0], 0.001], foot_layer3[2], true);
        }  
    }
        
    module magnet_holes() {
        translate([13, 13, 1]) magnet_hole();
        translate([13, -13, 1]) magnet_hole();
        translate([-13, 13, 1]) magnet_hole();
        translate([-13, -13, 1]) magnet_hole();
        
        module magnet_hole() {
            cylinder(d=6, h=2+gf_tolerance, center=true);
        }
    }
    
    module gf_rounded_cube(size, radius, center=false) {
        linear_extrude(h=size[2]) gf_rounded_square(size, radius, center);
    }
    
    module gf_rounded_square(size, radius, center=false) {
        offset = center ? 0 : radius;
        translate([offset,offset,0])
            offset(r = radius)
                square([size[0]-2*radius, size[1]-2*radius], center=center);
    }
}