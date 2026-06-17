// Toggle switch model (connected solid)
// Required: 1.0mm body diameter, 4.7mm body height

$fn = 64;

// Parameters (mm)
body_d = 1.0;
body_h = 4.7;

lever_d = 0.5;
lever_h = 2.0;

tip_d = 0.3;
tip_h = 1.0;

// Small overlap to guarantee manifold connectivity
overlap = 0.05;

module toggle_switch() {
    union() {
        // Body centered at origin
        cylinder(d = body_d, h = body_h, center = true);

        // Lever sits on top of body (with slight overlap)
        translate([0, 0, body_h/2 - overlap])
            cylinder(d = lever_d, h = lever_h + overlap, center = false);

        // Tip sits on top of lever (with slight overlap)
        translate([0, 0, body_h/2 + lever_h - overlap])
            cylinder(d = tip_d, h = tip_h + overlap, center = false);
    }
}

toggle_switch();