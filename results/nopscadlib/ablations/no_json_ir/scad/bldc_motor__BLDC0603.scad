$fn = 96;

// Brushless DC motor (tiny outrunner style)
// Requested: stator diameter = 9.0mm, overall height = 8.0mm

// ---------------- Targets ----------------
stator_d = 9.0;     // mm (requested)
motor_h  = 8.0;     // mm (requested overall height)

// ---------------- Tuning / overlaps ----------------
// Use a larger structural overlap to guarantee watertight unions (per requirements)
eps = 1.2;          // 1–2mm overlap for solid connections
clr = 0.25;         // visual clearance (airgap etc.)

// ---------------- Stator ----------------
stator_h = 5.6;                 // leaves room for base + top cap within 8mm
tooth_count = 9;
tooth_len = 0.85;
tooth_w   = 0.70;
tooth_h   = stator_h;

// ---------------- Rotor bell (outrunner can) ----------------
airgap     = 0.25;
rotor_wall = 0.60;
rotor_id   = stator_d + 2*airgap;
rotor_od   = rotor_id + 2*rotor_wall;

// Add external ribs/slots to avoid "buzzer can" look
rib_count = 9;
rib_w     = 0.70;
rib_depth = 0.55;

// ---------------- Base / endbells ----------------
base_h = 1.2;
top_cap_h = 0.5;
bell_h = motor_h - base_h;      // bell spans from base top to motor top

// ---------------- Shaft / hub ----------------
shaft_d = 1.5;
shaft_top = 1.6;
shaft_bottom = 0.8;

hub_d = 3.2;
hub_h = 0.9;

// ---------------- Mount pad (kept small, fused) ----------------
pad_h = 0.6;
pad_w = rotor_od * 0.92;
pad_l = rotor_od * 0.70;
hole_d = 1.0;
hole_spacing = pad_w * 0.55;

// ---------------- Internal bore (kept as a hole) ----------------
bore_d = 2.0;

// ---------------- Floating/green pads fix ----------------
// Create two small pads near the base and FORCE them to intersect the rotor bell
// (they were previously visually present but disconnected/floating).
green_pad_w = 1.6;
green_pad_l = 2.2;
green_pad_h = 0.9;

// Place them at the lower edge of the bell and overlap into the bell wall by eps.
green_pad_zc = base_h + green_pad_h/2 - eps; // intersects base and bell region
green_pad_r  = rotor_od/2 - green_pad_w/2 + eps; // pushes into bell wall

// ---------------- Modules ----------------
module stator_with_teeth() {
    union() {
        // Stator core
        cylinder(d=stator_d, h=stator_h, center=true);

        // Teeth protruding outward (radial array, connected via overlap)
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*360/tooth_count])
                translate([stator_d/2 + tooth_len/2 - eps, 0, 0])
                    cube([tooth_len, tooth_w, tooth_h], center=true);
        }

        // Small winding bulges between teeth (fused)
        for (i = [0:tooth_count-1]) {
            rotate([0,0,(i+0.5)*360/tooth_count])
                translate([stator_d/2 + tooth_len - 0.10, 0, 0])
                    scale([1.0, 0.75, 1.0])
                        cylinder(d=1.0, h=stator_h*0.70, center=true);
        }
    }
}

module rotor_bell_with_ribs() {
    // Bell is a hollow can with a top cap and hub; ribs are added outside.
    union() {
        // Hollow bell wall (connected to base by overlap)
        difference() {
            translate([0,0, base_h + bell_h/2 - eps])
                cylinder(d=rotor_od, h=bell_h + 2*eps, center=true);
            translate([0,0, base_h + bell_h/2 - eps])
                cylinder(d=rotor_id, h=bell_h + 2*eps + 0.6, center=true);
        }

        // External ribs (fused to bell)
        rib_h = bell_h - top_cap_h;
        for (i = [0:rib_count-1]) {
            rotate([0,0,i*360/rib_count])
                translate([rotor_od/2 + rib_depth/2 - eps, 0, base_h + rib_h/2 - eps])
                    cube([rib_depth, rib_w, rib_h + 2*eps], center=true);
        }

        // Top cap (thin)
        translate([0,0, base_h + bell_h - top_cap_h/2])
            cylinder(d=rotor_od, h=top_cap_h, center=true);

        // Top hub (fused into cap)
        translate([0,0, base_h + bell_h - top_cap_h - hub_h/2 + eps])
            cylinder(d=hub_d, h=hub_h + 2*eps, center=true);
    }
}

module base_and_mount() {
    union() {
        // Base disc (slightly smaller than rotor OD)
        translate([0,0, base_h/2])
            cylinder(d=rotor_od*0.98, h=base_h, center=true);

        // Mounting pad (rounded via hull), fused to base (overlap in Z)
        translate([0,0, pad_h/2 - eps])
            hull() {
                translate([ pad_w/2 - pad_h,  pad_l/2 - pad_h, 0]) cylinder(d=pad_h*2, h=pad_h + 2*eps, center=true);
                translate([-pad_w/2 + pad_h,  pad_l/2 - pad_h, 0]) cylinder(d=pad_h*2, h=pad_h + 2*eps, center=true);
                translate([ pad_w/2 - pad_h, -pad_l/2 + pad_h, 0]) cylinder(d=pad_h*2, h=pad_h + 2*eps, center=true);
                translate([-pad_w/2 + pad_h, -pad_l/2 + pad_h, 0]) cylinder(d=pad_h*2, h=pad_h + 2*eps, center=true);
            }

        // Two small "green" pads near the base (now physically attached)
        // Positioned at +/-Y near the lower edge; pushed radially into the bell wall.
        for (sy = [-1, 1]) {
            translate([0, sy*(rotor_od*0.33), green_pad_zc])
                rotate([0,0,0])
                    translate([green_pad_r, 0, 0])
                        cube([green_pad_w, green_pad_l, green_pad_h + 2*eps], center=true);
        }
    }
}

module shaft_solid() {
    // Shaft passes through motor and protrudes both sides; centered on motor body
    shaft_h = motor_h + shaft_top + shaft_bottom;
    // Place so that shaft protrudes shaft_top above z=motor_h and shaft_bottom below z=0
    translate([0,0, motor_h/2 + (shaft_top - shaft_bottom)/2])
        cylinder(d=shaft_d, h=shaft_h, center=true);
}

// ---------------- Assembly (ONE connected solid) ----------------
module bldc_motor_9x8() {
    difference() {
        union() {
            // Base + mount + attached small pads
            base_and_mount();

            // Stator sits on base (connected via overlap)
            translate([0,0, base_h + stator_h/2 - eps])
                stator_with_teeth();

            // Rotor bell covers stator and overlaps base slightly (connected)
            rotor_bell_with_ribs();

            // Shaft (connected through hub/base)
            shaft_solid();
        }

        // Center bore through base + stator (hole)
        translate([0,0, (base_h + stator_h)/2])
            cylinder(d=bore_d, h=base_h + stator_h + 3, center=true);

        // Mounting holes through pad/base (hole)
        for (sx = [-1, 1]) {
            translate([sx*hole_spacing/2, 0, (pad_h + base_h)/2])
                cylinder(d=hole_d, h=pad_h + base_h + 3, center=true);
        }
    }
}

bldc_motor_9x8();