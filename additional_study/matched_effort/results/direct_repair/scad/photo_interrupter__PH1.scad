$fn=64;

// Photo interrupter (slot opto) - parametric approximation
// Units: mm

// ---------- Parameters ----------
body_w = 12.0;      // overall width (X)
body_d = 6.0;       // overall depth (Y)
body_h = 10.0;      // overall height (Z)

slot_w = 3.2;       // slot opening width (X)
slot_depth = 4.2;   // slot depth into body (Y)
slot_height = 7.0;  // slot height (Z)
slot_floor = 1.5;   // thickness below slot (Z)

arm_th = 2.0;       // thickness of each arm (X)
gap_w = slot_w;     // gap between arms (X)

top_bridge_h = 2.0; // thickness of top bridge above slot (Z)

lead_d = 0.6;       // lead diameter
lead_len = 12.0;    // lead length below body
lead_pitch = 2.54;  // lead spacing
lead_count = 4;

fillet_r = 0.8;     // corner rounding (approx)

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1.0) {
    // Minkowski rounded box (kept modest for renderability)
    r2 = min(r, min(size[0], min(size[1], size[2]))/2 - 0.01);
    minkowski() {
        cube([size[0]-2*r2, size[1]-2*r2, size[2]-2*r2], center=true);
        sphere(r=r2);
    }
}

module lead_pin(x, y, z0, len, d) {
    translate([x,y,z0 - len/2])
        cylinder(h=len, d=d, center=true);
}

// ---------- Model ----------
module photo_interrupter() {
    difference() {
        // Main body
        translate([0,0,body_h/2])
            rounded_box([body_w, body_d, body_h], r=fillet_r);

        // Slot cutout (from front face, along +Y into body)
        // Place slot centered in X, starting near front (-Y side)
        slot_y0 = -body_d/2 - 0.1;
        translate([0, slot_y0 + slot_depth/2, slot_floor + slot_height/2])
            cube([gap_w, slot_depth + 0.2, slot_height], center=true);

        // Open the slot fully through the front face (ensure clean opening)
        translate([0, -body_d/2 - 0.2, slot_floor + slot_height/2])
            cube([gap_w, 0.6, slot_height], center=true);

        // Small chamfer-like relief at slot entrance (approx)
        translate([0, -body_d/2 + 0.2, slot_floor + slot_height - 0.2])
            rotate([0,90,0])
                cylinder(h=gap_w+0.2, r=0.6, center=true);
    }

    // Add subtle top bridge detail (raised ridge)
    translate([0, 0, slot_floor + slot_height + top_bridge_h/2])
        cube([body_w*0.9, body_d*0.85, top_bridge_h], center=true);

    // Leads (4 pins) exiting bottom
    // Arrange along X, centered, near back half in Y
    pins_span = (lead_count-1)*lead_pitch;
    y_pin = body_d*0.15;
    z_bottom = 0;

    for (i=[0:lead_count-1]) {
        x_pin = -pins_span/2 + i*lead_pitch;
        lead_pin(x_pin, y_pin, z_bottom, lead_len, lead_d);
    }

    // Slight lead bend stubs (optional small horizontal offsets)
    // Create tiny shoulders at body exit
    for (i=[0:lead_count-1]) {
        x_pin = -pins_span/2 + i*lead_pitch;
        translate([x_pin, y_pin, 0.6])
            cylinder(h=1.2, d=lead_d*1.4, center=true);
    }
}

photo_interrupter();