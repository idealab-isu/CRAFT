// PTFE heatshrink sleeving: simple hollow cylindrical tube (ONE connected solid)

// Parameters
tube_length     = 100;   //[50:200:1]
inner_diameter  = 6;     //[3:12:0.1]
wall_thickness  = 0.5;   //[0.25:1:0.05]
end_chamfer     = 0.5;   //[0:2:0.05]
overlap         = 0.2;   //[0.05:1:0.05]

// Derived
inner_r = inner_diameter/2;
outer_r = inner_r + wall_thickness;

// Quality
$fn = 128;

// Main tube (hollow)
module hollow_tube(h, r_out, r_in) {
    difference() {
        cylinder(h=h, r=r_out, center=true);
        cylinder(h=h + 2*overlap, r=r_in, center=true);
    }
}

// Optional subtle end chamfers (kept simple and robust)
module chamfered_hollow_tube(h, r_out, r_in, chamfer) {
    // If chamfer is zero or too large, fall back to plain tube
    safe_ch = min(chamfer, max(0, h/4));
    if (safe_ch <= 0) {
        hollow_tube(h, r_out, r_in);
    } else {
        difference() {
            // Outer with chamfered ends via hull of two slightly smaller cylinders
            hull() {
                translate([0,0,  h/2 - safe_ch/2]) cylinder(h=safe_ch, r=r_out - safe_ch, center=true);
                translate([0,0, -h/2 + safe_ch/2]) cylinder(h=safe_ch, r=r_out - safe_ch, center=true);
                cylinder(h=h - safe_ch, r=r_out, center=true);
            }
            // Inner bore straight through
            cylinder(h=h + 2*overlap, r=r_in, center=true);
        }
    }
}

// Final Output: ONE connected solid tube
chamfered_hollow_tube(tube_length, outer_r, inner_r, end_chamfer);