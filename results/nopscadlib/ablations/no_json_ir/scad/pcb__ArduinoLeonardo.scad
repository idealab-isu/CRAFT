$fn = 64;

// -------------------- Target board dimensions --------------------
pcb_length    = 68.58;
pcb_width     = 53.34;
pcb_thickness = 1.6;

// Board features
corner_radius = 3.0;

hole_diameter = 3.2;
hole_offset_x = 5.0;
hole_offset_y = 5.0;

// Small overlap to guarantee one connected solid
overlap = 0.25;

// -------------------- Helpers --------------------
module rounded_pcb(L, W, H, R) {
    // Centered rounded rectangle prism using linear_extrude of 2D rounded rect
    translate([0, 0, -H/2])
        linear_extrude(height=H)
            offset(r=R)
                square([L - 2*R, W - 2*R], center=true);
}

module mounting_holes(L, W, H, offx, offy, d) {
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*(L/2 - offx), sy*(W/2 - offy), 0])
                cylinder(h=H + 2, d=d, center=true);
}

module raised_rect(x, y, z0, sx, sy, sz) {
    // z0 is the top surface of PCB (pcb_thickness/2)
    translate([x, y, z0 + sz/2 - overlap])
        cube([sx, sy, sz], center=true);
}

module raised_cyl(x, y, z0, d, h) {
    translate([x, y, z0 + h/2 - overlap])
        cylinder(d=d, h=h, center=true);
}

// -------------------- Main PCB --------------------
module pcb_body() {
    difference() {
        rounded_pcb(pcb_length, pcb_width, pcb_thickness, corner_radius);
        mounting_holes(pcb_length, pcb_width, pcb_thickness, hole_offset_x, hole_offset_y, hole_diameter);
    }
}

// -------------------- Components (recognizable, connected) --------------------
module usb_connector() {
    // USB connector on +X edge, protruding outward
    usb_w = 12.0;   // along X
    usb_d = 9.0;    // along Y
    usb_h = 4.2;    // along Z

    x = pcb_length/2 + usb_w/2 - overlap; // connected to board edge
    y = 0;
    z0 = pcb_thickness/2;

    raised_rect(x, y, z0, usb_w, usb_d, usb_h);

    // Small "tongue" bump to hint connector opening
    tongue_w = usb_w * 0.55;
    tongue_d = usb_d * 0.35;
    tongue_h = usb_h * 0.35;
    raised_rect(x - usb_w*0.10, y, z0 + usb_h*0.15, tongue_w, tongue_d, tongue_h);
}

module pin_header_row(x, y, pins, pitch, body_w, body_h) {
    // A single long header body (simplified) + small pin bumps
    len = pins * pitch; // overall length
    z0 = pcb_thickness/2;

    raised_rect(x, y, z0, len, body_w, body_h);

    // Pin bumps (very low) to suggest pins; connected via overlap
    pin_d = 1.2;
    pin_h = 1.0;
    for (i = [0:pins-1]) {
        xi = x - len/2 + pitch/2 + i*pitch;
        raised_cyl(xi, y, z0 + body_h*0.15, pin_d, pin_h);
    }
}

module headers() {
    // Two long headers along left and right edges (Arduino-like)
    pins = 16;
    pitch = 2.54;
    body_w = 3.2;
    body_h = 3.0;

    // Place headers near the long edges (±Y), spanning along X
    y_top =  pcb_width/2 - body_w/2;
    y_bot = -pcb_width/2 + body_w/2;

    // Keep clear of USB on +X by shortening/offsetting the top header
    len_full = pins * pitch;
    len_top  = len_full - 10; // shorter to suggest asymmetry and leave space near USB
    x_center_full = 0;
    x_center_top  = -5;

    pin_header_row(x_center_full, y_bot, pins, pitch, body_w, body_h);
    // For the shorter top header, reduce pins count accordingly (formula-based)
    pins_top = floor(len_top / pitch);
    pin_header_row(x_center_top,  y_top, pins_top, pitch, body_w, body_h);
}

module main_ic() {
    // Central MCU package
    ic_sx = 14;
    ic_sy = 14;
    ic_h  = 1.8;

    x = -5;
    y = 5;
    z0 = pcb_thickness/2;

    raised_rect(x, y, z0, ic_sx, ic_sy, ic_h);

    // Slightly raised "inner die" to add recognizability (still connected)
    die_sx = ic_sx * 0.55;
    die_sy = ic_sy * 0.55;
    die_h  = 0.6;
    raised_rect(x, y, z0 + ic_h*0.15, die_sx, die_sy, die_h);
}

module regulator() {
    // Small power/regulator block near USB
    sx = 8;
    sy = 6;
    h  = 2.2;

    x = pcb_length/2 - (12 + sx/2); // formula: keep near +X but inside board
    y = -pcb_width/2 + (12);
    z0 = pcb_thickness/2;

    raised_rect(x, y, z0, sx, sy, h);
}

module reset_button() {
    // Small tactile button near top edge
    sx = 6;
    sy = 6;
    h  = 3.0;

    x = -pcb_length/2 + 18;
    y =  pcb_width/2 - 10;
    z0 = pcb_thickness/2;

    raised_rect(x, y, z0, sx, sy, h);

    // Button cap
    raised_cyl(x, y, z0 + h*0.15, 3.5, 1.2);
}

module leds() {
    // Two indicator LEDs near bottom edge
    z0 = pcb_thickness/2;
    d = 3.0;
    h = 1.6;

    x1 = -pcb_length/2 + 22;
    x2 = -pcb_length/2 + 28;
    y  = -pcb_width/2 + 10;

    raised_cyl(x1, y, z0, d, h);
    raised_cyl(x2, y, z0, d, h);
}

module silkscreen_ridges() {
    // Very shallow raised "silkscreen" bars (kept as geometry, no text)
    z0 = pcb_thickness/2;
    h = 0.25;

    raised_rect(0, pcb_width/2 - 6, z0, 18, 1.2, h);
    raised_rect(-pcb_length/2 + 14, 0, z0, 1.2, 18, h);
    raised_rect(pcb_length/2 - 26, 0, z0, 1.2, 18, h);
}

module bottom_features() {
    // Add underside parts so side views show non-zero component height.
    // These are kept connected by overlapping slightly into the PCB.
    z0b = -pcb_thickness/2; // bottom surface reference

    // A few "solder blob" pads under headers (simplified bars)
    pad_h = 0.6;
    pad_w = 2.0;
    pad_len = 40;

    // Under bottom header (near -Y)
    raised_rect(0, -pcb_width/2 + 3.0, z0b, pad_len, pad_w, pad_h);

    // Under top header (near +Y)
    raised_rect(-5, pcb_width/2 - 3.0, z0b, pad_len - 10, pad_w, pad_h);

    // Under MCU area
    raised_rect(-5, 5, z0b, 10, 10, 0.5);
}

// -------------------- Assembly --------------------
module dev_board() {
    union() {
        pcb_body();
        usb_connector();
        headers();
        main_ic();
        regulator();
        reset_button();
        leds();
        silkscreen_ridges();
        bottom_features();
    }
}

dev_board();