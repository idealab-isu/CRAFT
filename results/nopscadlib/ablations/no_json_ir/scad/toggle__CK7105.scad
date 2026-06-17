$fn = 96;

// Requested dimensions (overall envelope)
switch_body_diameter = 6.86;
switch_body_height   = 12.7;

// Small overlap to guarantee a single connected solid
overlap = 0.2;

module toggle_switch() {
    body_d = switch_body_diameter;
    body_r = body_d/2;
    total_h = switch_body_height;

    // Proportions for a recognizable toggle silhouette while keeping overall size exact
    base_h   = total_h * 0.62;                 // main cylindrical body
    collar_h = total_h * 0.10;                 // small collar/shoulder
    lever_h  = total_h - base_h - collar_h;    // remaining height for lever

    collar_d = body_d * 0.70;
    lever_d  = body_d * 0.22;

    // Lever tilt and length compensation so Z-height stays lever_h
    lever_tilt = 18; // degrees
    lever_len  = lever_h / cos(lever_tilt); // ensures vertical projection equals lever_h

    union() {
        // Main body (exact diameter)
        cylinder(d=body_d, h=base_h, center=false);

        // Collar on top of body (connected with overlap)
        translate([0, 0, base_h - overlap])
            cylinder(d=collar_d, h=collar_h + overlap, center=false);

        // Lever: tilted cylinder starting at top of collar (connected with overlap)
        translate([0, 0, base_h + collar_h - overlap])
            rotate([0, lever_tilt, 0])
                cylinder(d=lever_d, h=lever_len + overlap, center=false);

        // Small rounded tip on lever end (kept within overall height by construction)
        translate([0, 0, base_h + collar_h - overlap])
            rotate([0, lever_tilt, 0])
                translate([0, 0, lever_len - lever_d/2])
                    sphere(d=lever_d);
    }
}

toggle_switch();