$fn = 128;

// Target dimensions (mm)
bore_diameter          = 3.0;   // ID
outer_diameter         = 8.0;   // OD (main body)
width                  = 3.0;   // overall width INCLUDING flange
flange_outer_diameter  = 9.5;   // flange OD
flange_thickness       = 0.5;   // flange axial thickness (part of overall width)

// Visual bearing details (kept within the above critical dimensions)
race_wall              = 0.70;  // radial thickness of outer race wall
inner_race_wall        = 0.55;  // radial thickness of inner race wall
radial_clearance       = 0.15;  // clearance between races and balls (visual)
ball_diameter          = 0.90;  // visual ball size
num_balls              = 9;     // visual count

module flanged_ball_bearing() {
    eps = 0.02;

    // Radii
    r_bore   = bore_diameter/2;
    r_outer  = outer_diameter/2;
    r_flange = flange_outer_diameter/2;

    // Axial layout: center overall width at Z=0, flange on +Z side
    body_h = width - flange_thickness;
    z_body_center   = -flange_thickness/2;
    z_flange_center =  width/2 - flange_thickness/2;

    // Race radii
    r_inner_race_od = r_bore + inner_race_wall;
    r_outer_race_id = r_outer - race_wall;

    // Ball path between races
    r_ball_path = (r_inner_race_od + r_outer_race_id)/2;

    // Groove size (visual), limited so it doesn't break through walls
    groove_r = ball_diameter * 0.35;
    groove_r_limited = min(
        groove_r,
        (r_outer - r_outer_race_id) * 0.85,
        (r_inner_race_od - r_bore) * 0.85
    );

    // Keep balls inside body (not in flange)
    z_ball = z_body_center;

    // One connected solid: outer ring + flange + inner ring + balls, then subtract bore/cavity/grooves
    difference() {
        union() {
            // Outer ring (main body OD=8)
            translate([0,0,z_body_center])
                cylinder(d=outer_diameter, h=body_h, center=true);

            // Flange (OD=9.5) connected to body with slight overlap
            translate([0,0,z_flange_center])
                cylinder(d=flange_outer_diameter, h=flange_thickness + 2*eps, center=true);

            // Inner ring (inner race OD)
            translate([0,0,z_body_center])
                cylinder(r=r_inner_race_od, h=body_h, center=true);

            // Balls (slight oversize for guaranteed contact)
            for (i = [0:num_balls-1]) {
                rotate([0,0,i*360/num_balls])
                    translate([r_ball_path, 0, z_ball])
                        sphere(d=ball_diameter + 2*eps);
            }
        }

        // Bore through entire bearing
        cylinder(d=bore_diameter, h=width + 2, center=true);

        // Annular cavity between races (only in body region, not flange)
        translate([0,0,z_body_center])
            difference() {
                cylinder(r=r_outer_race_id, h=body_h + 2*eps, center=true);
                cylinder(r=r_inner_race_od + radial_clearance, h=body_h + 2*eps + 0.1, center=true);
            }

        // Ball grooves: subtract only within body height (mask with intersection)
        translate([0,0,z_body_center])
            intersection() {
                // Body-height slab to prevent cutting the flange
                cylinder(r=r_flange + 2, h=body_h + 2*eps, center=true);

                union() {
                    // Outer race groove
                    rotate_extrude(angle=360)
                        translate([r_outer_race_id, 0, 0])
                            circle(r=groove_r_limited);

                    // Inner race groove
                    rotate_extrude(angle=360)
                        translate([r_inner_race_od, 0, 0])
                            circle(r=groove_r_limited);
                }
            }
    }
}

flanged_ball_bearing();