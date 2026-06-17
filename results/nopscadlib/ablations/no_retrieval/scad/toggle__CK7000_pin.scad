$fn = 96;

// Toggle switch target envelope:
// - Body diameter: 0.76 mm (main cylindrical body OD)
// - Overall height: 4.7 mm (from bottom of terminals to top of lever)

// -------------------- Parameters --------------------
body_diameter   = 0.76;   // main body OD (verified by geometry)
overall_height  = 4.7;    // total Z height (verified by geometry)

lever_tilt_deg  = 15;
overlap         = 0.05;   // small overlap to guarantee manifold union

// Toggle switch details (micro proportions)
flange_diameter   = 1.20;
flange_thickness  = 0.30;

bushing_diameter  = 0.70;  // "threaded" bushing OD (simplified)
bushing_height    = 0.55;

nut_diameter      = 1.10;  // hex nut across flats (simplified)
nut_thickness     = 0.25;

knurl_diameter    = 0.86;
knurl_height      = 0.35;
knurl_tooth_count = 12;
knurl_tooth_depth = 0.06;

lever_diameter    = 0.25;

pin_diameter      = 0.18;
pin_spacing       = 0.35;
pin_length        = 0.90;

// Marking notch
marking_notch_width  = 0.18;
marking_notch_depth  = 0.06;
marking_notch_height = 0.25;

// -------------------- Derived dimensions (enforce overall_height) --------------------
// Choose lever height; solve body height so total equals overall_height.
lever_height = 1.10;

// Total height = pin_length + flange_thickness + body_height + bushing_height + nut_thickness + lever_height
body_height = overall_height
              - (pin_length + flange_thickness + bushing_height + nut_thickness + lever_height);

// Safety clamp
body_height_safe = max(0.20, body_height);

// Z stack (bottom to top), all formulas (no arbitrary translations)
z_pins_bot    = 0;
z_pins_top    = z_pins_bot + pin_length;

z_flange_bot  = z_pins_top - overlap;
z_flange_top  = z_flange_bot + flange_thickness;

z_body_bot    = z_flange_top - overlap;
z_body_top    = z_body_bot + body_height_safe;

z_knurl_bot   = z_body_top - knurl_height + overlap;  // sits on top region of body
z_knurl_top   = z_knurl_bot + knurl_height;

z_bush_bot    = z_body_top - overlap;
z_bush_top    = z_bush_bot + bushing_height;

z_nut_bot     = z_bush_top - overlap;
z_nut_top     = z_nut_bot + nut_thickness;

z_lever_pivot = z_nut_top - overlap;                  // lever pivots from top of nut
z_lever_top   = z_lever_pivot + lever_height;

// -------------------- Modules --------------------
module switch_body() {
    cylinder(r=body_diameter/2, h=body_height_safe, center=false);
}

module base_flange() {
    translate([0, 0, z_flange_bot])
        cylinder(r=flange_diameter/2, h=flange_thickness, center=false);
}

module mounting_bushing() {
    translate([0, 0, z_bush_bot])
        cylinder(r=bushing_diameter/2, h=bushing_height, center=false);
}

module hex_nut() {
    // Hex prism (across flats = nut_diameter)
    // For a regular hex, across flats = 2*apothem = 2*(R*cos(30)) => R = AF/(2*cos30)
    R = nut_diameter/(2*cos(30));
    translate([0, 0, z_nut_bot])
        cylinder(r=R, h=nut_thickness, $fn=6, center=false);
}

module knurl_ring() {
    translate([0, 0, z_knurl_bot])
        cylinder(r=knurl_diameter/2, h=knurl_height, center=false);
}

module knurl_tooth_proto() {
    tooth_len = knurl_tooth_depth + overlap;     // protrudes outward, overlaps into ring
    tooth_w   = knurl_tooth_depth * 1.2;

    // Place tooth centered in Z over knurl ring, radially at ring edge
    translate([knurl_diameter/2 + tooth_len/2 - overlap, 0, z_knurl_bot + knurl_height/2])
        cube([tooth_len, tooth_w, knurl_height], center=true);
}

module knurling() {
    union() {
        knurl_ring();
        for (i = [0:knurl_tooth_count-1])
            rotate([0, 0, i*360/knurl_tooth_count])
                knurl_tooth_proto();
    }
}

module toggle_lever_tilted() {
    // Rotate about pivot at z_lever_pivot
    translate([0, 0, z_lever_pivot])
        rotate([0, lever_tilt_deg, 0])
            translate([0, 0, lever_height/2])
                cylinder(r=lever_diameter/2, h=lever_height + 2*overlap, center=true);
}

module terminal_pin_at(x) {
    translate([x, 0, z_pins_bot])
        cylinder(r=pin_diameter/2, h=pin_length + overlap, center=false);
}

module terminal_pins() {
    union() {
        terminal_pin_at(0);
        terminal_pin_at(-pin_spacing/2);
        terminal_pin_at( pin_spacing/2);
    }
}

module marking_notch_cutter() {
    // Cut into side of main body near the top
    // Body is located from z_body_bot..z_body_top
    translate([body_diameter/2 - marking_notch_depth, 0, z_body_top - marking_notch_height/2])
        cube([marking_notch_depth*2, marking_notch_width, marking_notch_height], center=true);
}

module switch_core_union() {
    union() {
        // Pins -> flange -> body -> knurl -> bushing -> nut -> lever
        terminal_pins();
        base_flange();
        translate([0, 0, z_body_bot]) switch_body();
        knurling();
        mounting_bushing();
        hex_nut();
        toggle_lever_tilted();
    }
}

// -------------------- Final solid --------------------
difference() {
    switch_core_union();
    marking_notch_cutter();
}