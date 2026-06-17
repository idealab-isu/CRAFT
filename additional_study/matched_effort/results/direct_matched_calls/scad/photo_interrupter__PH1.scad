$fn=64;

// Photo interrupter (slot opto) - parametric approximation
// Units: mm

// -------- Parameters --------
body_w = 12.0;      // overall width (X)
body_d = 6.0;       // overall depth (Y)
body_h = 10.0;      // overall height (Z)

slot_w = 3.2;       // slot opening width (X)
slot_d = body_d + 0.6; // slot depth (Y) (cut through)
slot_h = 6.5;       // slot height (Z)
slot_z0 = 2.0;      // slot bottom height from base

arm_th = 2.2;       // thickness of each arm (X direction thickness)
bridge_h = 2.2;     // top bridge thickness (Z)

lead_d = 0.6;       // lead diameter
lead_len = 12.0;    // lead length below body
lead_pitch = 2.54;  // spacing between leads
lead_rows = 2;      // number of lead columns per side
lead_cols = 2;      // number of lead rows (front/back)
lead_y_offset = 1.6; // offset from center in Y for front/back leads
lead_x_inset = 2.0; // inset from outer edge to lead center

fillet_r = 0.8;     // corner rounding for body

// -------- Helpers --------
module rounded_box(size=[10,10,10], r=1.0) {
    // Minkowski rounded rectangular prism
    sx = max(size[0]-2*r, 0.01);
    sy = max(size[1]-2*r, 0.01);
    sz = max(size[2]-2*r, 0.01);
    minkowski() {
        cube([sx, sy, sz], center=true);
        sphere(r=r);
    }
}

module lead_pin(h=10, d=0.6) {
    cylinder(h=h, d=d, center=false);
}

// -------- Model --------
module photo_interrupter() {
    // Body centered at origin in X/Y, base at Z=0
    translate([0,0,body_h/2])
    difference() {
        // Outer body
        rounded_box([body_w, body_d, body_h], r=fillet_r);

        // Slot cutout (U-shape opening)
        // Cut a rectangular slot through Y, leaving two arms and a top bridge.
        translate([0,0, (slot_z0 + slot_h/2) - body_h/2])
            cube([slot_w, slot_d, slot_h], center=true);

        // Create the U opening by also removing the lower middle region up to slot_z0
        // (so the slot is open from the bottom up to slot_z0+slot_h)
        translate([0,0, (slot_z0/2) - body_h/2])
            cube([slot_w, slot_d, slot_z0], center=true);

        // Slight chamfer at slot entrance (top inner edges) via subtracting wedges
        // (simple approximation)
        for (sx = [-1,1]) {
            translate([sx*(slot_w/2), 0, (slot_z0+slot_h) - body_h/2])
                rotate([0,45,0])
                    cube([1.2, slot_d+1, 1.2], center=true);
        }
    }

    // Leads: 4 pins (2x2) exiting bottom
    // Place pins near one side of the body (typical opto has 4 pins in a row; we approximate 2x2)
    // We'll place them along X near the back half, symmetric in Y.
    pin_z0 = -lead_len;
    pin_z1 = 0;

    // Pin positions
    // Two columns in X: near left and right but inset
    x_positions = [
        -body_w/2 + lead_x_inset,
         body_w/2 - lead_x_inset
    ];

    // Two rows in Y: front/back
    y_positions = [
        -lead_y_offset,
         lead_y_offset
    ];

    for (ix = [0:len(x_positions)-1])
    for (iy = [0:len(y_positions)-1]) {
        translate([x_positions[ix], y_positions[iy], pin_z0])
            lead_pin(h=lead_len, d=lead_d);
    }

    // Small base standoffs around pins (plastic feet)
    foot_d = 1.6;
    foot_h = 0.6;
    for (ix = [0:len(x_positions)-1])
    for (iy = [0:len(y_positions)-1]) {
        translate([x_positions[ix], y_positions[iy], 0])
            cylinder(h=foot_h, d=foot_d, center=false);
    }

    // Side notch / marking (polarity indicator) on one face
    notch_w = 2.0;
    notch_d = 0.8;
    notch_h = 1.2;
    translate([body_w/2 - notch_d/2, 0, body_h - notch_h/2])
        rotate([0,90,0])
            cube([notch_h, notch_w, notch_d], center=true);
}

photo_interrupter();