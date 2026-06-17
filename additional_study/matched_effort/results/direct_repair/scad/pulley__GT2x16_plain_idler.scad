$fn = 160;

// Parametric pulley
// Units: mm
bore_d      = 5;
hub_d       = 18;
hub_len     = 14;

pulley_od   = 40;
pulley_w    = 16;

flange_od   = 44;
flange_t    = 2.2;

groove_depth = 3.2;   // radial depth from pulley OD
groove_width = 10;    // axial width of groove
groove_round = 1.2;   // rounding radius for groove edges

set_screw_d = 3;      // optional set screw hole
set_screw_z = 0;      // centered on hub
set_screw_on = true;

keyway_on   = false;
key_w       = 2;
key_h       = 1;
key_len     = hub_len;

module pulley() {
    difference() {
        union() {
            // Main body (between flanges)
            cylinder(d=pulley_od, h=pulley_w, center=true);

            // Flanges
            translate([0,0, (pulley_w/2 + flange_t/2)])
                cylinder(d=flange_od, h=flange_t, center=true);
            translate([0,0, -(pulley_w/2 + flange_t/2)])
                cylinder(d=flange_od, h=flange_t, center=true);

            // Hub
            cylinder(d=hub_d, h=hub_len, center=true);
        }

        // Bore
        cylinder(d=bore_d, h=max(pulley_w + 2*flange_t, hub_len) + 2, center=true);

        // Groove (belt channel) carved from the main body
        groove();

        // Optional set screw (radial)
        if (set_screw_on)
            translate([0,0,set_screw_z])
                rotate([0,90,0])
                    cylinder(d=set_screw_d, h=hub_d/2 + 6, center=true);

        // Optional keyway (simple rectangular slot)
        if (keyway_on)
            translate([bore_d/2, -key_w/2, -key_len/2])
                cube([key_h, key_w, key_len], center=false);
    }
}

module groove() {
    // Create a smooth U-shaped groove by subtracting a rotated 2D profile
    // around Z (rotate_extrude). The profile is positioned at radius pulley_od/2.
    r_outer = pulley_od/2;
    r_inner = r_outer - groove_depth;

    // Ensure groove fits within pulley width
    gw = min(groove_width, pulley_w - 1);

    translate([0,0,0])
        rotate_extrude(angle=360, convexity=10)
            translate([r_inner, 0, 0])
                offset(r=groove_round)
                    square([groove_depth, gw], center=true);
}

pulley();