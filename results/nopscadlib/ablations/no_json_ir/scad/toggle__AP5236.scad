module toggle_switch() {
    $fn = 120;

    // Requested overall body: 7.0mm diameter, 13.6mm tall (body only)
    body_d = 7.0;
    body_h = 13.6;

    // Mounting collar/bushing (visual detail)
    collar_d = 10.0;
    collar_h = 1.6;

    // Lever/actuator (tilted) + small ball tip
    lever_d = 2.2;
    lever_h = 8.0;
    tip_d   = 3.2;

    // Small overlap to guarantee a single connected solid
    overlap = 0.25;

    union() {
        // Main cylindrical body centered on Z
        cylinder(d=body_d, h=body_h, center=true);

        // Collar near the top of the body, overlapping into it
        translate([0, 0, body_h/2 - collar_h/2])
            cylinder(d=collar_d, h=collar_h + overlap, center=true);

        // Lever: tilted cylinder that starts at the top of the body and overlaps
        // Place lever base at the body's top surface (z = body_h/2), then tilt about X.
        translate([0, 0, body_h/2 - overlap])
            rotate([25, 0, 0])
                translate([0, 0, lever_h/2])
                    cylinder(d=lever_d, h=lever_h + overlap, center=true);

        // Ball tip at end of lever, connected by overlap
        translate([0, 0, body_h/2 - overlap])
            rotate([25, 0, 0])
                translate([0, 0, lever_h - tip_d/2 + overlap])
                    sphere(d=tip_d);
    }
}

toggle_switch();