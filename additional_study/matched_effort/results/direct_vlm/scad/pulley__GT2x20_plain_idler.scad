$fn = 160;

// Parametric pulley
// Units: mm
bore_d      = 5;
hub_d       = 18;
hub_len     = 10;

pulley_od   = 40;
pulley_w    = 16;

flange_od   = 44;
flange_th   = 2;

groove_depth = 3.0;   // radial depth of V-groove from pulley OD
groove_angle = 40;    // included angle of V-groove (degrees)

set_screw_d  = 3;
set_screw_z  = 0;     // centered on hub
set_screw_r  = hub_d/2 - 1.2;

keyway_w     = 0;     // set to >0 to enable
keyway_h     = 0;
keyway_len   = hub_len;

module v_groove_cut(od, width, depth, angle_deg){
    // Creates a V-groove by subtracting two cones meeting at center plane.
    // Outer radius at faces: od/2
    // Inner radius at center: od/2 - depth
    R = od/2;
    r = max(0.01, R - depth);
    halfw = width/2;
    // Determine axial half-length of each cone so that side angle matches.
    // For a cone, tan(theta) = (R - r) / h, where theta is half included angle.
    theta = angle_deg/2;
    h = (R - r) / max(1e-6, tan(theta));
    // Ensure cones extend beyond half width to fully cut.
    h2 = max(h, halfw + 0.5);

    union(){
        translate([0,0,0])
            cylinder(h=h2, r1=r, r2=R, center=false);
        translate([0,0,-h2])
            cylinder(h=h2, r1=R, r2=r, center=false);
    }
}

module pulley(){
    difference(){
        union(){
            // Main pulley body
            cylinder(d=pulley_od, h=pulley_w, center=true);

            // Flanges
            translate([0,0, pulley_w/2 - flange_th/2])
                cylinder(d=flange_od, h=flange_th, center=true);
            translate([0,0,-pulley_w/2 + flange_th/2])
                cylinder(d=flange_od, h=flange_th, center=true);

            // Hub
            cylinder(d=hub_d, h=hub_len, center=true);
        }

        // Bore
        cylinder(d=bore_d, h=max(pulley_w, hub_len) + 2, center=true);

        // V-groove cut (centered)
        // Place groove so its apex is at center plane.
        // Use two cones meeting at z=0; extend beyond width.
        translate([0,0,0])
            v_groove_cut(pulley_od, pulley_w, groove_depth, groove_angle);

        // Optional keyway (rectangular)
        if (keyway_w > 0 && keyway_h > 0){
            translate([bore_d/2 - 0.01, 0, 0])
                cube([keyway_h, keyway_w, keyway_len + 2], center=true);
        }

        // Set screw hole (radial through hub)
        rotate([0,90,0])
            translate([0,0,set_screw_r])
                cylinder(d=set_screw_d, h=hub_d + 6, center=true);
    }
}

pulley();