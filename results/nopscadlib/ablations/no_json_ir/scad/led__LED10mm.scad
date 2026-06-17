$fn = 96;

// Target: 10.0mm through-hole LED, 11.0mm body height (base to dome tip)
led_diameter = 10.0;
led_height   = 11.0;

// Typical 10mm LED proportions (kept parametric)
base_cyl_h        = 7.0;   // straight cylindrical section height
dome_h            = led_height - base_cyl_h;  // ensures total height = 11.0
rim_flange_h      = 1.0;
rim_flange_d      = 12.0;

pin_diameter      = 0.8;
pin_length        = 15.0;
pin_spacing       = 2.54;

overlap = 0.2; // small overlap to guarantee one connected solid

module led_body() {
    // Base cylinder + domed top (sphere clipped to upper half)
    union() {
        // Cylindrical body from z=0..base_cyl_h
        cylinder(h = base_cyl_h, d = led_diameter, center = false);

        // Dome from z=base_cyl_h..led_height
        // Use a sphere of radius = dome_h, centered at z=base_cyl_h, clipped to z>=base_cyl_h
        intersection() {
            translate([0, 0, base_cyl_h])
                sphere(r = dome_h);
            translate([0, 0, base_cyl_h])
                cylinder(h = dome_h + overlap, d = led_diameter, center = false);
        }
    }
}

module led_rim_flange() {
    // Flange at base, connected with slight overlap into body
    translate([0, 0, -rim_flange_h + overlap])
        cylinder(h = rim_flange_h, d = rim_flange_d, center = false);
}

module leads_pins() {
    // Leads start slightly inside the body to ensure connectivity
    lead_start_z = overlap;                 // inside body
    lead_h       = pin_length + lead_start_z;

    for (sx = [-1, 1]) {
        translate([sx * pin_spacing/2, 0, -pin_length])
            cylinder(h = lead_h, d = pin_diameter, center = false);
    }
}

module led() {
    union() {
        led_rim_flange();
        led_body();
        leads_pins();
    }
}

led();