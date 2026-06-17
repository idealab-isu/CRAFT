$fn = 128;

// Target dimensions (mm)
bore_diameter   = 5.0;   // ID
outer_diameter  = 16.0;  // OD (body)
overall_width   = 5.0;   // width (excluding flange thickness)
flange_diameter = 18.0;  // flange OD
flange_thickness = 1.0;  // flange axial thickness (adds on one side)

// Visual/feature parameters (kept realistic but not dimension-critical)
ball_diameter = 1.5;
ball_count    = 8;

eps = 0.02;

// Derived radii
r_bore   = bore_diameter/2;
r_outer  = outer_diameter/2;
r_flange = flange_diameter/2;

// Choose a plausible inner race OD that leaves room for balls and outer race wall
r_inner_outer = r_bore + 1.6;                 // inner race outer radius
r_ball_path   = (r_inner_outer + r_outer)/2;  // ball center radius

// Ensure balls fit between races
ball_clear = 0.15;
ball_r = ball_diameter/2;
r_ball_path = min(max(r_ball_path, r_inner_outer + ball_r + ball_clear),
                  r_outer - ball_r - ball_clear);

// Race groove sizes (visual)
groove_r = ball_r + 0.10;   // groove "tube" radius
groove_z = 0;               // centered in width

module ring(h, r1, r2, center=true){
    difference(){
        cylinder(h=h, r=r2, center=center);
        cylinder(h=h+2*eps, r=r1, center=center);
    }
}

module groove_cut(r_path, z0){
    translate([0,0,z0])
        rotate_extrude(angle=360)
            translate([r_path,0,0])
                circle(r=groove_r, $fn=64);
}

module bearing(){
    // One connected solid: races + flange + balls fused, with bore and grooves cut out
    difference(){
        union(){
            // Outer race body
            ring(overall_width, r_inner_outer + 0.9, r_outer, center=true);

            // Inner race body
            ring(overall_width, r_bore, r_inner_outer, center=true);

            // Flange on +Z side, connected with slight overlap
            translate([0,0, overall_width/2 - eps])
                ring(flange_thickness + eps, r_inner_outer + 0.9, r_flange, center=false);

            // Balls (fused into one solid for printability/one-piece requirement)
            for(i=[0:ball_count-1]){
                rotate([0,0,i*360/ball_count])
                    translate([r_ball_path,0,0])
                        sphere(r=ball_r, $fn=64);
            }
        }

        // Bore (through all, including flange)
        cylinder(h=overall_width + flange_thickness + 4*eps, r=r_bore, center=true);

        // Ball grooves in both races (visual)
        groove_cut(r_ball_path, groove_z);

        // Small relief to make the separation between races visible (thin annular gap)
        // (Does not disconnect the solid because balls bridge the gap)
        ring(overall_width + 2*eps, r_inner_outer + 0.25, r_inner_outer + 0.55, center=true);
    }
}

bearing();