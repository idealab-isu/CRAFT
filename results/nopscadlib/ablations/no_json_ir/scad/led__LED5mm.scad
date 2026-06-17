$fn = 120;

// 5.0mm THT LED, 5.9mm body height (cyl + dome), connected solid
led_d = 5.0;
body_h = 5.9;

flange_d = 5.9;
flange_h = 0.6;

dome_h = 2.2;                 // part of body_h
cyl_h  = body_h - dome_h;     // remaining height for cylindrical section

lead_d = 0.5;
lead_pitch = 2.54;
lead_len = 12;

overlap = 0.2;

module led_body() {
    // Cylindrical base + domed lens (hemisphere-like via scaled sphere)
    union() {
        // cylindrical section
        cylinder(h = cyl_h, d = led_d);

        // dome: scaled sphere to match diameter and dome height
        translate([0, 0, cyl_h - overlap])
            scale([led_d/2, led_d/2, dome_h])
                sphere(r = 1);
    }
}

module rim_flange() {
    // Flange sits at the bottom of the body and overlaps slightly into it
    translate([0, 0, -flange_h + overlap])
        cylinder(h = flange_h, d = flange_d);
}

module leads() {
    // Leads start slightly inside the flange to ensure connectivity
    for (x = [-lead_pitch/2, lead_pitch/2]) {
        translate([x, 0, -flange_h - lead_len + overlap])
            cylinder(h = lead_len + flange_h, d = lead_d);
    }
}

module led() {
    union() {
        rim_flange();
        led_body();
        leads();
    }
}

led();