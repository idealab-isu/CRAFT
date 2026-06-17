$fn = 64;

// Board parameters (mm)
length = 68.58;
width  = 53.34;
thickness = 1.6;
corner_radius = 3.0;

// Small overlap to guarantee watertight unions
ov = 0.2;

// ---------- Helpers ----------
module rounded_rect_2d(l, w, r) {
    // 2D rounded rectangle centered at origin
    r2 = min(r, min(l, w)/2);
    hull() {
        translate([ l/2 - r2,  w/2 - r2]) circle(r=r2);
        translate([-l/2 + r2,  w/2 - r2]) circle(r=r2);
        translate([ l/2 - r2, -w/2 + r2]) circle(r=r2);
        translate([-l/2 + r2, -w/2 + r2]) circle(r=r2);
    }
}

module rounded_box(l, w, h, r) {
    linear_extrude(height=h, center=false)
        rounded_rect_2d(l, w, r);
}

module chip_body(l, w, h, r=0.6) {
    // Simple IC package with slightly rounded corners
    translate([0,0,0])
        rounded_box(l, w, h, r);
}

module header_block(pin_cols, pin_rows, pitch, pin_d, pin_h, body_h, body_margin=1.0) {
    // Plastic body
    body_l = (pin_cols-1)*pitch + 2*body_margin;
    body_w = (pin_rows-1)*pitch + 2*body_margin;
    union() {
        // Body sits on PCB
        translate([0,0,0])
            rounded_box(body_l, body_w, body_h, r=0.6);

        // Pins protrude down into PCB slightly and up above body
        for (c = [0:pin_cols-1])
            for (r = [0:pin_rows-1]) {
                x = (c - (pin_cols-1)/2) * pitch;
                y = (r - (pin_rows-1)/2) * pitch;
                translate([x, y, -ov])
                    cylinder(h=pin_h + ov, d=pin_d, center=false);
            }
    }
}

module usb_micro_port(port_w, port_d, port_h, shell_t=0.6) {
    // Simplified micro-USB: a solid shell block (no hollow) to keep one connected solid
    // Oriented so depth extends outward from board edge (+Y direction when placed at top edge)
    union() {
        // Outer shell
        rounded_box(port_w, port_d, port_h, r=0.8);

        // Small "tongue" bump on top for recognizability
        tongue_w = port_w * 0.55;
        tongue_d = port_d * 0.55;
        tongue_h = port_h * 0.25;
        translate([0, -port_d*0.10, port_h - tongue_h - ov])
            rounded_box(tongue_w, tongue_d, tongue_h + ov, r=0.5);
    }
}

module mounting_post(d, h) {
    // Solid post (not a hole) to keep single connected solid
    cylinder(h=h, d=d, center=false);
}

// ---------- Main model ----------
module dev_board() {
    // Coordinate system:
    // Board centered at origin in X/Y, bottom at Z=0, top at Z=thickness
    union() {
        // PCB
        rounded_box(length, width, thickness, corner_radius);

        // Mounting posts at 4 corners (visual feature; solid to keep one connected solid)
        post_d = 4.8;
        post_h = 1.2;
        edge_inset = 5.0;
        for (sx = [-1, 1])
            for (sy = [-1, 1]) {
                translate([ sx*(length/2 - edge_inset),
                            sy*(width/2  - edge_inset),
                            thickness - ov ])
                    mounting_post(post_d, post_h + ov);
            }

        // Main MCU package (center-ish)
        mcu_l = 14.0;
        mcu_w = 14.0;
        mcu_h = 1.6;
        translate([0, 0, thickness - ov])
            chip_body(mcu_l, mcu_w, mcu_h + ov, r=0.8);

        // USB micro port on top edge (positive Y), centered in X
        usb_w = 8.0;
        usb_d = 7.0;   // extends outward from board edge
        usb_h = 3.0;
        translate([0,
                   width/2 + usb_d/2 - 1.0,          // overlap into board by 1mm
                   thickness - ov])
            usb_micro_port(usb_w, usb_d, usb_h);

        // Two long header rows along left/right edges (like many dev boards)
        // Each header is a 1xN pin strip with pins + plastic body
        pins_n = 20;
        pitch = 2.54;
        pin_d = 1.0;
        pin_h = 6.0;
        hdr_body_h = 2.5;

        // Compute header length and place so it fits within board length with margins
        hdr_len = (pins_n-1)*pitch + 2*1.0;
        hdr_margin_x = 6.0;
        hdr_x_span = length - 2*hdr_margin_x;
        // If computed header length is longer than available span, reduce pin count visually by scaling pitch
        pitch_eff = (hdr_len <= hdr_x_span) ? pitch : (hdr_x_span - 2*1.0)/(pins_n-1);

        // Left header (negative X edge)
        hdr_offset_x = length/2 - 3.5; // distance from center to header centerline
        translate([-hdr_offset_x, 0, thickness - ov])
            rotate([0,0,90])
                header_block(pin_cols=pins_n, pin_rows=1, pitch=pitch_eff,
                             pin_d=pin_d, pin_h=pin_h, body_h=hdr_body_h);

        // Right header (positive X edge)
        translate([ hdr_offset_x, 0, thickness - ov])
            rotate([0,0,90])
                header_block(pin_cols=pins_n, pin_rows=1, pitch=pitch_eff,
                             pin_d=pin_d, pin_h=pin_h, body_h=hdr_body_h);

        // Power/regulator block near USB
        reg_l = 8.0;
        reg_w = 6.0;
        reg_h = 1.8;
        translate([0,
                   width/2 - 10.0,
                   thickness - ov])
            chip_body(reg_l, reg_w, reg_h + ov, r=0.6);

        // A few small passive components (caps/resistors) as raised blocks
        pass_l = 3.2;
        pass_w = 1.6;
        pass_h = 1.0;

        // Place a small cluster near regulator
        for (i = [0:2]) {
            translate([ (i-1)*4.0,
                        width/2 - 16.0,
                        thickness - ov ])
                rounded_box(pass_l, pass_w, pass_h + ov, r=0.4);
        }

        // Reset button (small square) near top-right quadrant
        btn_l = 6.0;
        btn_w = 6.0;
        btn_h = 2.0;
        translate([ length*0.20,
                    width*0.18,
                    thickness - ov ])
            rounded_box(btn_l, btn_w, btn_h + ov, r=1.0);

        // Status LED bump near top-left quadrant
        led_d = 2.0;
        led_h = 1.2;
        translate([ -length*0.22,
                     width*0.18,
                     thickness - ov ])
            cylinder(h=led_h + ov, d=led_d, center=false);
    }
}

dev_board();