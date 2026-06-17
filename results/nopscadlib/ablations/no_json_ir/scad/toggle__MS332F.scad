$fn = 96;

// Parameters (mm)
outer_diameter = 12.6;   // body diameter
body_height    = 13.1;   // body height

toggle_diameter = 4;     // lever diameter
toggle_height   = 10;    // lever height above body

// Small overlap to guarantee a single connected solid
overlap = 0.4;

module toggle_switch() {
    union() {
        // Main cylindrical body (centered at origin)
        cylinder(h = body_height, d = outer_diameter, center = true);

        // Toggle lever: centered cylinder, positioned so it overlaps into the body
        translate([0, 0, body_height/2 + toggle_height/2 - overlap])
            cylinder(h = toggle_height, d = toggle_diameter, center = true);
    }
}

toggle_switch();