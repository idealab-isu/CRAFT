$fn = 160;

// Parametric pulley
// Units: mm
bore_d      = 5;
hub_d       = 18;
hub_len     = 10;

pulley_od   = 40;
pulley_w    = 16;

rim_flange_d = 44;
flange_th    = 1.6;

groove_depth = 3.0;   // radial depth from pulley_od/2
groove_width = 10.0;  // axial width of groove
groove_round = 1.2;   // rounding radius for groove edges

set_screw_hole_d = 3.0;
set_screw_z      = 0;     // centered on hub
set_screw_from_center = hub_d/2 - 2.0; // radial position (approx)

// Helpers
module rounded_groove_cutter(od, w, depth, round_r){
    // Creates a belt groove by subtracting a "capsule" profile revolved around Z.
    // Profile is in X-Y plane, revolved around Z via rotate_extrude.
    // Groove centered at Z=0, width w.
    r_outer = od/2;
    r_inner = r_outer - depth;

    // 2D profile: a rounded rectangle (capsule) in (radius, z)
    // We'll build it as hull of two circles separated in z.
    rotate_extrude(convexity=10)
        translate([r_inner + round_r, 0, 0])
            hull() {
                translate([0, -w/2 + round_r]) circle(r=round_r);
                translate([0,  w/2 - round_r]) circle(r=round_r);
            }
    ;
}

module pulley(){
    difference(){
        union(){
            // Main body
            cylinder(d=pulley_od, h=pulley_w, center=true);

            // Flanges
            translate([0,0, pulley_w/2 - flange_th/2])
                cylinder(d=rim_flange_d, h=flange_th, center=true);
            translate([0,0,-pulley_w/2 + flange_th/2])
                cylinder(d=rim_flange_d, h=flange_th, center=true);

            // Hub (centered)
            cylinder(d=hub_d, h=hub_len, center=true);
        }

        // Bore
        cylinder(d=bore_d, h=max(pulley_w, hub_len) + 2, center=true);

        // Groove (centered)
        rounded_groove_cutter(pulley_od, groove_width, groove_depth, groove_round);

        // Set screw hole (radial through hub)
        // Drill along X axis at hub mid-plane
        translate([0,0,set_screw_z])
            rotate([0,90,0])
                cylinder(d=set_screw_hole_d, h=hub_d + 10, center=true);
    }
}

pulley();