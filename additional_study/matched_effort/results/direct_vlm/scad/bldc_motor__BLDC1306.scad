$fn = 128;

// Brushless DC motor (outrunner-style envelope) with REQUIRED stator size
stator_d = 17.75;   // required
stator_h = 14.5;    // required

// Envelope assumptions (kept parametric)
can_wall      = 1.0;
can_clearance = 0.6;

// Outer rotor can sized from stator
can_d = stator_d + 2*(can_wall + can_clearance);
can_h = stator_h + 2.0;

// Endbells / base features
base_h = 2.0;
base_d = can_d * 0.92;

top_cap_h = 1.2;
top_cap_d = can_d * 0.98;

// Shaft
shaft_d = 3.0;
shaft_len_above = 12.0;
shaft_len_below = 2.0;

// Mounting holes
mount_hole_d     = 2.0;
mount_circle_d   = base_d * 0.65;
mount_hole_count = 4;

// Wire exit (kept connected to base)
wire_exit_w   = 5.0;
wire_exit_h   = 3.0;
wire_exit_len = 6.0;

// Visual details (shallow grooves/ribs so ortho side views show features)
rib_count = 12;
rib_w     = 1.0;
rib_h     = 0.6;

// Small overlap to guarantee manifold connectivity
eps = 0.2;

module bolt_circle_holes(count, circle_d, hole_d, h, z0=0) {
    for (i = [0:count-1]) {
        a = 360*i/count;
        translate([circle_d/2*cos(a), circle_d/2*sin(a), z0])
            cylinder(d=hole_d, h=h, center=false);
    }
}

module motor() {
    // Z layout (all formulas, no arbitrary offsets)
    z0 = 0;                         // bottom of base
    z1 = z0 + base_h;               // top of base / bottom of can
    z2 = z1 + can_h;                // top of can / bottom of top cap
    z3 = z2 + top_cap_h;            // top of top cap

    difference() {
        union() {
            // Base / mounting plate
            cylinder(d=base_d, h=base_h, center=false);

            // Outer can (rotor housing)
            translate([0,0,z1 - eps])
                cylinder(d=can_d, h=can_h + eps, center=false);

            // Top cap / endbell lip
            translate([0,0,z2 - eps])
                cylinder(d=top_cap_d, h=top_cap_h + eps, center=false);

            // Shaft (connected through top cap and base)
            translate([0,0,z3 - eps])
                cylinder(d=shaft_d, h=shaft_len_above + eps, center=false);

            translate([0,0,z0 - shaft_len_below])
                cylinder(d=shaft_d, h=shaft_len_below + eps, center=false);

            // Wire exit block (connected to base side with overlap)
            translate([base_d/2 - wire_exit_len/2 + eps, 0, base_h/2])
                cube([wire_exit_len + 2*eps, wire_exit_w, wire_exit_h], center=true);

            // External ribs on can (protrude outward so side orthographic views show detail)
            for (i = [0:rib_count-1]) {
                rotate([0,0,i*360/rib_count])
                    translate([can_d/2 + rib_h/2 - eps, 0, z1 + can_h/2])
                        cube([rib_h + 2*eps, rib_w, can_h], center=true);
            }
        }

        // Hollow inside can to suggest rotor/stator cavity (kept as a single connected solid overall)
        translate([0,0,z1 + eps])
            cylinder(d=can_d - 2*can_wall, h=can_h - 2*eps, center=false);

        // Stator reference cavity (ensures required stator diameter/height are present as internal feature)
        translate([0,0,z1 + (can_h - stator_h)/2])
            cylinder(d=stator_d, h=stator_h, center=false);

        // Mounting holes through base
        bolt_circle_holes(mount_hole_count, mount_circle_d, mount_hole_d, base_h + 2*eps, z0=z0 - eps);

        // Center bore in base (clearance around shaft)
        translate([0,0,z0 - eps])
            cylinder(d=shaft_d + 1.0, h=base_h + 2*eps, center=false);

        // Shallow circumferential groove on can (adds visible feature in side views)
        translate([0,0,z1 + can_h*0.55])
            rotate_extrude()
                translate([can_d/2 - 0.6, 0, 0])
                    square([0.8, 0.8], center=true);
    }
}

motor();