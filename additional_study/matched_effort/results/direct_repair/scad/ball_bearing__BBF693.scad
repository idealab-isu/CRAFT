$fn = 128;

bore_d = 3.0;
od_d = 8.0;
width = 3.0;

flange_d = 9.5;
flange_th = 0.6;

ring_wall = 0.9;          // radial thickness of inner ring
shield_recess = 0.25;     // depth of shield recess on each side
shield_lip = 0.25;        // radial lip width for recess

module flanged_bearing() {
    difference() {
        union() {
            // Main outer ring body
            cylinder(d=od_d, h=width);

            // Flange on one side (bottom)
            cylinder(d=flange_d, h=flange_th);
        }

        // Bore
        translate([0,0,-0.5])
            cylinder(d=bore_d, h=width + flange_th + 1.0);

        // Inner ring clearance (creates separation between inner and outer rings)
        translate([0,0,-0.5])
            cylinder(d=bore_d + 2*ring_wall, h=width + flange_th + 1.0);

        // Shield recess (top side)
        translate([0,0,width - shield_recess])
            cylinder(d=od_d - 2*shield_lip, h=shield_recess + 0.01);

        // Shield recess (bottom side, above flange)
        translate([0,0,flange_th])
            cylinder(d=od_d - 2*shield_lip, h=shield_recess + 0.01);
    }

    // Inner ring (separate solid)
    difference() {
        translate([0,0,0])
            cylinder(d=bore_d + 2*ring_wall, h=width);
        translate([0,0,-0.5])
            cylinder(d=bore_d, h=width + 1.0);
    }

    // Simple ball representation (torus-like ring)
    ball_path_d = (bore_d + 2*ring_wall + od_d) / 2;
    ball_r = 0.35;
    translate([0,0,width/2])
        rotate_extrude()
            translate([ball_path_d/2, 0, 0])
                circle(r=ball_r);
}

flanged_bearing();