$fn = 96;

// Toggle switch target: body Ø1.0mm, total height 4.7mm (bottom of pins to top of lever)
body_diameter = 1.0;     // mm (main cylindrical body)
total_height  = 4.7;     // mm

// Pins
pin_diameter = 0.12;     // mm
pin_length   = 0.70;     // mm
pin_spacing  = 0.28;     // mm (center-to-center)

// Body + top bushing
bushing_diameter = 0.55; // mm (small collar on top of body)
bushing_height   = 0.35; // mm

// Toggle lever (visible actuator)
lever_diameter = 0.22;   // mm (rod thickness)
lever_height   = 1.25;   // mm (vertical rise above bushing)
lever_tilt_deg = 18;     // degrees tilt for "toggle" look

// Small knob at lever tip
knob_diameter = 0.32;    // mm
knob_height   = 0.22;    // mm

// Small anti-rotation flat/tab on body side (subtle feature)
tab_thickness = 0.18;    // mm (radial protrusion)
tab_width     = 0.40;    // mm (tangential width)
tab_height    = 0.55;    // mm (vertical height)

// Connectivity overlap
overlap = 0.05;          // mm

// Derived: ensure exact total height
// total_height = pin_length + body_height + bushing_height + lever_height + knob_height
body_height = total_height - pin_length - bushing_height - lever_height - knob_height;
body_height = (body_height < 0.6) ? 0.6 : body_height; // safety clamp

// Z references (Z=0 at bottom of pins)
z0 = 0;
z_pins_top     = z0 + pin_length;

z_body_bottom  = z_pins_top - overlap;
z_body_top     = z_body_bottom + body_height;

z_bush_bottom  = z_body_top - overlap;
z_bush_top     = z_bush_bottom + bushing_height;

z_lever_bottom = z_bush_top - overlap;
z_lever_top    = z_lever_bottom + lever_height;

z_knob_bottom  = z_lever_top - overlap;
z_knob_top     = z_knob_bottom + knob_height;

// Helpers
module cyl_z(zc, h, d) {
    translate([0,0,zc]) cylinder(h=h, r=d/2, center=true);
}

module pin_at(x) {
    translate([x, 0, z0 + pin_length/2])
        cylinder(h=pin_length, r=pin_diameter/2, center=true);
}

module lever() {
    // Build lever as a tilted rod starting at the bushing top center.
    // Use a small overlap into bushing to guarantee connectivity.
    translate([0,0,z_lever_bottom + overlap])
        rotate([0, lever_tilt_deg, 0])
            translate([0,0,lever_height/2])
                cylinder(h=lever_height, r=lever_diameter/2, center=true);
}

module knob() {
    // Place knob at the lever tip, aligned with lever tilt.
    translate([0,0,z_lever_bottom + overlap])
        rotate([0, lever_tilt_deg, 0])
            translate([0,0,lever_height + knob_height/2 - overlap])
                cylinder(h=knob_height, r=knob_diameter/2, center=true);
}

module side_tab() {
    // Small rectangular tab on the side of the body to break perfect circular silhouette.
    // Connected by overlapping slightly into the body radius.
    tab_center_r = body_diameter/2 + tab_thickness/2 - overlap;
    tab_zc = (z_body_bottom + z_body_top)/2;
    translate([tab_center_r, 0, tab_zc])
        cube([tab_thickness, tab_width, tab_height], center=true);
}

module switch_complete() {
    union() {
        // Main cylindrical body (Ø1.0mm)
        translate([0,0,(z_body_bottom+z_body_top)/2])
            cylinder(h=body_height, r=body_diameter/2, center=true);

        // Side tab feature (connected)
        side_tab();

        // Top bushing/collar (connected)
        translate([0,0,(z_bush_bottom+z_bush_top)/2])
            cylinder(h=bushing_height, r=bushing_diameter/2, center=true);

        // Toggle lever + knob (connected)
        lever();
        knob();

        // Three terminal pins (connected into body with overlap)
        pin_at(-pin_spacing/2);
        pin_at(0);
        pin_at(pin_spacing/2);
    }
}

switch_complete();