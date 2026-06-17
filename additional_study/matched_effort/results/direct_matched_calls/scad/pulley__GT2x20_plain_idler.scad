$fn = 160;

// Pulley parameters (mm)
outer_d      = 40;
width        = 16;

bore_d       = 8;

hub_d        = 22;
hub_len      = 20;   // can be slightly longer than pulley width

flange_d     = 44;
flange_th    = 2.2;

groove_depth = 3.2;  // radial depth of belt groove
groove_width = 10;   // axial width of groove region
crown        = 0.8;  // slight crown on groove

// Set-screw (optional)
setscrew_enable = true;
setscrew_d      = 3.2;   // clearance for M3
setscrew_z      = 0;     // centered
setscrew_from_r = hub_d/2 + 0.5; // start just outside hub
setscrew_len    = 20;

// Keyway (optional)
keyway_enable = false;
key_w = 3;
key_h = 1.5;
key_len = width + 2;

// Helpers
module pulley_body() {
    // Base cylinder (outer)
    cylinder(d=outer_d, h=width, center=true);

    // Flanges
    translate([0,0, width/2 - flange_th/2])
        cylinder(d=flange_d, h=flange_th, center=true);
    translate([0,0,-width/2 + flange_th/2])
        cylinder(d=flange_d, h=flange_th, center=true);

    // Hub
    cylinder(d=hub_d, h=hub_len, center=true);
}

module groove_cut() {
    // Create a crowned V-ish groove by subtracting a rotated profile
    // Profile is in X-Z plane, rotated around Z.
    // We'll build a 2D polygon in (r,z) then rotate_extrude.
    // r is X, z is Y in rotate_extrude's 2D space.
    z0 = -groove_width/2;
    z1 =  groove_width/2;

    r_outer = outer_d/2 + 0.2; // slight overshoot
    r_inner = outer_d/2 - groove_depth;

    // Crown: make center slightly shallower (larger radius) than edges
    r_inner_center = r_inner + crown;

    rotate_extrude(convexity=10)
        polygon(points=[
            [r_outer, z0],
            [r_outer, z1],
            [r_inner, z1],
            [r_inner_center, 0],
            [r_inner, z0]
        ]);
}

module bore_cut() {
    cylinder(d=bore_d, h=max(width,hub_len)+4, center=true);
}

module setscrew_cut() {
    if (setscrew_enable) {
        // Radial hole through hub
        translate([0,0,setscrew_z])
            rotate([0,90,0])
                translate([0,0,0])
                    cylinder(d=setscrew_d, h=setscrew_len, center=true);
    }
}

module keyway_cut() {
    if (keyway_enable) {
        // Simple rectangular keyway along bore
        translate([bore_d/2 - key_h/2, 0, 0])
            cube([key_h, key_w, key_len], center=true);
    }
}

difference() {
    pulley_body();

    // Groove centered on pulley
    groove_cut();

    // Bore
    bore_cut();

    // Optional features
    setscrew_cut();
    keyway_cut();
}