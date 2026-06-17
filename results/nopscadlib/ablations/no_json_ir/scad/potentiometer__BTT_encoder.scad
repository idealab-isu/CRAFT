// Potentiometer with guaranteed connectivity (no floating tabs)
// type = [body_h, body_d, bushing_h, shaft_h]
module potentiometer(type) {
    union() {
        potentiometer_body(type);
        wafer_section(type);
        boss(type);
        threaded_bushing(type);
        shaft(type);
        face_plate(type);
        spigot(type);
        mounting_tabs(type);   // fixed: tabs now overlap body by 1-2mm
    }
}

// Main cylindrical body
module potentiometer_body(type) {
    cylinder(h = type[0], d = type[1], $fn=64);
}

// Threaded bushing on top of body (overlap into body)
module threaded_bushing(type) {
    overlap = 1.5;
    translate([0, 0, type[0] - overlap])
        cylinder(h = type[2] + overlap, d = type[1] * 0.8, $fn=64);
}

// Shaft on top of bushing (overlap into bushing)
module shaft(type) {
    overlap = 1.0;
    translate([0, 0, type[0] + type[2] - overlap])
        cylinder(h = type[3] + overlap, d = type[1] * 0.5, $fn=48);
}

// Boss around mid-body (already intersects body)
module boss(type) {
    translate([0, 0, type[0] / 2])
        cylinder(h = type[0] * 0.2, d = type[1] * 0.6, $fn=64);
}

// Face plate above shaft (overlap into shaft)
module face_plate(type) {
    overlap = 1.0;
    plate_h = max(type[3] * 0.5, 0.6);
    translate([0, 0, type[0] + type[2] + type[3] - overlap])
        cylinder(h = plate_h + overlap, d = type[1], $fn=64);
}

// Wafer section (already intersects body)
module wafer_section(type) {
    translate([0, 0, type[0] * 0.3])
        cylinder(h = type[0] * 0.4, d = type[1] * 0.9, $fn=64);
}

// Mounting tabs/pins around body (FIXED: attached with radial overlap + centered Z)
module mounting_tabs(type) {
    // Tabs should be attached to the side of the main body with a guaranteed overlap.
    overlap = 1.5;                 // 1-2mm overlap into body
    tab_len = type[1] * 0.2;        // radial length outward
    tab_w   = type[1] * 0.1;        // tangential width
    tab_h   = type[0] * 0.1;        // vertical height

    body_r = type[1] / 2;

    // Place tabs centered vertically on the body so they intersect it.
    zc = type[0] / 2;

    // Radial placement: inner edge goes inside body by 'overlap'
    // Using center=true cube so we can compute center radius precisely.
    r_center = body_r + tab_len/2 - overlap;

    for (a = [0, 120, 240]) {
        rotate([0, 0, a])
            translate([r_center, 0, zc])
                cube([tab_len, tab_w, tab_h], center=true);
    }
}

// Spigot above face plate (overlap into face plate)
module spigot(type) {
    overlap = 0.8;
    plate_h = max(type[3] * 0.5, 0.6);
    sp_h = max(type[3] * 0.3, 0.4);

    translate([0, 0, type[0] + type[2] + type[3] + plate_h - overlap])
        cylinder(h = sp_h + overlap, d = type[1] * 0.4, $fn=48);
}

// Main call
potentiometer([12, 11, 6, 0.5]);