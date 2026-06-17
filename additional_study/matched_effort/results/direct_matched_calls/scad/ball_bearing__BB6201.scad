$fn = 180;

bore_d = 12.0;
od_d   = 32.0;
width  = 10.0;

// Simple visual ball bearing model (rings + balls + cage)
clearance_radial = 0.25;   // small clearance between rings
race_depth       = 1.6;    // groove depth (visual)
race_width       = 3.2;    // groove width (visual)

inner_ring_thk = 3.2;      // radial thickness of inner ring
outer_ring_thk = 3.2;      // radial thickness of outer ring

ball_count = 8;
ball_d     = 4.2;

cage_thk_z = 1.2;
cage_rad_thk = 1.2;

module ring(r_in, r_out, h) {
    difference() {
        cylinder(h=h, r=r_out, center=true);
        cylinder(h=h+0.2, r=r_in, center=true);
    }
}

module race_groove(r_center, groove_r, h, z0=0) {
    // Subtract a torus-like groove by revolving a circle (approximated via rotate_extrude)
    translate([0,0,z0])
    rotate_extrude(convexity=10)
        translate([r_center,0,0])
            circle(r=groove_r);
}

module bearing() {
    r_bore = bore_d/2;
    r_od   = od_d/2;

    // Define ring radii
    r_inner_in  = r_bore;
    r_inner_out = r_bore + inner_ring_thk;

    r_outer_out = r_od;
    r_outer_in  = r_od - outer_ring_thk;

    // Ball pitch radius (between rings)
    r_pitch = (r_inner_out + r_outer_in)/2;

    // Groove circle radius (visual)
    groove_r = race_depth;

    // Rings with grooves
    color([0.75,0.75,0.78])
    difference() {
        union() {
            ring(r_inner_in, r_inner_out, width);
            ring(r_outer_in, r_outer_out, width);
        }

        // Inner ring groove
        race_groove(r_pitch - clearance_radial, groove_r, width);

        // Outer ring groove
        race_groove(r_pitch + clearance_radial, groove_r, width);
    }

    // Balls
    color([0.85,0.85,0.88])
    for (i = [0:ball_count-1]) {
        ang = 360*i/ball_count;
        rotate([0,0,ang])
            translate([r_pitch,0,0])
                sphere(d=ball_d);
    }

    // Simple cage (two thin rings with pockets implied by gaps)
    color([0.55,0.55,0.58])
    difference() {
        union() {
            translate([0,0, width/2 - cage_thk_z/2])
                ring(r_pitch - ball_d/2 - cage_rad_thk, r_pitch + ball_d/2 + cage_rad_thk, cage_thk_z);
            translate([0,0,-width/2 + cage_thk_z/2])
                ring(r_pitch - ball_d/2 - cage_rad_thk, r_pitch + ball_d/2 + cage_rad_thk, cage_thk_z);
        }

        // Cut ball pockets through both cage rings
        for (i = [0:ball_count-1]) {
            ang = 360*i/ball_count;
            rotate([0,0,ang])
                translate([r_pitch,0,0])
                    cylinder(h=width+2, r=ball_d*0.55, center=true);
        }
    }
}

bearing();