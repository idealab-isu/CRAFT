$fn = 96;

// Toggle switch: main body must be 6.86mm diameter and 12.7mm tall
body_diameter = 6.86;   // mm
body_height   = 12.7;   // mm

// General
overlap = 0.6;          // mm (intentional interpenetration to ensure one connected solid)

// Lever / actuator (more toggle-like)
lever_diameter = 2.2;   // mm
lever_height   = 9.0;   // mm (above bushing)
lever_tip_d    = 3.2;   // mm
lever_tip_h    = 2.2;   // mm
lever_tilt_deg = 25;    // degrees

// Mounting bushing (threaded look)
bushing_diameter = 6.2; // mm
bushing_height   = 4.5; // mm above body

// Hex nut + washer
washer_outer_d = 9.0;   // mm
washer_thk     = 0.8;   // mm
nut_flat_d     = 10.0;  // mm across flats (approx)
nut_thk        = 2.5;   // mm

// Bottom base + terminals
base_flange_d = 9.5;    // mm
base_flange_t = 1.2;    // mm

pin_count    = 3;
pin_diameter = 1.0;     // mm
pin_length   = 4.0;     // mm
pin_spacing  = 2.54;    // mm

// Anti-rotation tab on bushing
tab_w = 1.2;
tab_t = 0.6;
tab_h = 1.2;

// Helpers
module hex_prism(af, h, center=true) {
    r = af / (2*cos(30)); // across flats -> circumradius
    cylinder(r=r, h=h, $fn=6, center=center);
}

module toggle_lever(shaft_d, shaft_h, tip_d, tip_h, tilt_deg) {
    // Build lever along +Z, then tilt about X at its base plane (z=0)
    rotate([tilt_deg, 0, 0])
        union() {
            // Shaft
            translate([0,0, shaft_h/2])
                cylinder(d=shaft_d, h=shaft_h, center=true);

            // Tip/knob
            translate([0,0, shaft_h + tip_h/2 - overlap])
                cylinder(d1=tip_d, d2=tip_d*0.9, h=tip_h, center=true);

            // Small collar at base to read more like a toggle actuator
            collar_d = shaft_d * 1.6;
            collar_h = 1.2;
            translate([0,0, collar_h/2 - overlap])
                cylinder(d=collar_d, h=collar_h, center=true);
        }
}

module toggle_switch() {
    // Z reference: body centered at Z=0
    body_top =  body_height/2;
    body_bot = -body_height/2;

    // Stack above body (all computed from dimensions)
    bushing_z   = body_top + bushing_height/2 - overlap;
    bushing_top = body_top + bushing_height - overlap;

    washer_z   = bushing_top + washer_thk/2 - overlap;
    washer_top = bushing_top + washer_thk - overlap;

    nut_z   = washer_top + nut_thk/2 - overlap;
    nut_top = washer_top + nut_thk - overlap;

    // Lever base sits on top of bushing (with overlap)
    lever_base_z = bushing_top - overlap;

    // Stack below body
    flange_z   = body_bot - base_flange_t/2 + overlap;
    flange_bot = body_bot - base_flange_t + overlap;

    pin_z = flange_bot - pin_length/2 + overlap;

    union() {
        // Main body (required dimensions)
        cylinder(d=body_diameter, h=body_height, center=true);

        // Bottom flange (fused)
        translate([0,0,flange_z])
            cylinder(d=base_flange_d, h=base_flange_t, center=true);

        // Mounting bushing (fused)
        translate([0,0,bushing_z])
            cylinder(d=bushing_diameter, h=bushing_height, center=true);

        // Washer (solid)
        translate([0,0,washer_z])
            cylinder(d=washer_outer_d, h=washer_thk, center=true);

        // Hex nut (solid)
        translate([0,0,nut_z])
            hex_prism(nut_flat_d, nut_thk, center=true);

        // Anti-rotation tab on bushing (fused)
        translate([bushing_diameter/2 - tab_t/2, 0, body_top + tab_h/2])
            cube([tab_t, tab_w, tab_h], center=true);

        // Toggle lever (tilted, connected at bushing top)
        translate([0,0,lever_base_z])
            toggle_lever(lever_diameter, lever_height, lever_tip_d, lever_tip_h, lever_tilt_deg);

        // Terminal pins (fused to flange)
        for (i = [0:pin_count-1]) {
            x = (i - (pin_count-1)/2) * pin_spacing;
            translate([x, 0, pin_z])
                cylinder(d=pin_diameter, h=pin_length, center=true);
        }
    }
}

toggle_switch();