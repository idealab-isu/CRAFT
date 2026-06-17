$fn = 128;

// Battery cell overall dimensions
height   = 50.5;   // mm (overall, including terminals)
diameter = 14.5;   // mm

// Simple battery features (kept subtle, all connected)
r = diameter/2;

bevel_h = 0.6;     // small edge bevel height
bevel_in = 0.35;   // small edge bevel inset (radial)

button_d = 5.5;    // positive terminal button diameter
button_h = 1.2;    // positive terminal button height

cap_step_h = 0.6;  // slight raised ring under button
cap_step_in = 0.25;

eps = 0.02;        // tiny overlap to ensure watertight union

// Derived heights so total equals 'height'
body_h = height - (button_h + cap_step_h);
body_h = (body_h > 0) ? body_h : height;

union() {
    // Main can with slight bevels on both ends
    translate([0, 0, body_h/2])
    union() {
        // bottom bevel
        cylinder(h=bevel_h, r1=r - bevel_in, r2=r, center=false);

        // straight wall
        translate([0, 0, bevel_h - eps])
            cylinder(h=body_h - 2*bevel_h + 2*eps, r=r, center=false);

        // top bevel
        translate([0, 0, body_h - bevel_h])
            cylinder(h=bevel_h, r1=r, r2=r - bevel_in, center=false);
    }

    // Slight raised top cap ring (connected)
    translate([0, 0, body_h - eps])
        cylinder(h=cap_step_h + eps, r=r - cap_step_in, center=false);

    // Positive terminal button (connected)
    translate([0, 0, body_h + cap_step_h - eps])
        cylinder(h=button_h + eps, d=button_d, center=false);
}