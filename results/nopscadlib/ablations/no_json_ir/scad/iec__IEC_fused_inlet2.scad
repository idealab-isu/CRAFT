$fn = 72;

// IEC fused inlet (old style) - improved solid model
// Faceplate size: 36.0mm x 27.0mm
// One connected solid: faceplate + rear body + fuse drawer housing + switch/retainer boss + rear terminals
// Front opening: recognizable IEC C14-ish profile (rounded rectangle with top/bottom key notches + pin holes)

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module rounded_box(w, h, d, r) {
    linear_extrude(height=d, center=true)
        rounded_rect_2d(w, h, r);
}

// 2D IEC C14-ish opening profile (for subtraction)
module iec_c14_opening_2d(w=27.0, h=19.0, r=2.0, notch_w=10.0, notch_h=3.2) {
    // Base rounded rectangle minus top/bottom center notches (keying)
    difference() {
        rounded_rect_2d(w, h, r);

        // Top notch
        translate([0,  h/2 - notch_h/2])
            rounded_rect_2d(notch_w, notch_h, min(1.0, notch_h/2));

        // Bottom notch
        translate([0, -h/2 + notch_h/2])
            rounded_rect_2d(notch_w, notch_h, min(1.0, notch_h/2));
    }
}

module iec_fused_inlet_old(face_w=36, face_h=27) {

    // Faceplate
    face_t = 2.4;
    face_r = 1.2;

    // Rear body (behind panel)
    body_w = face_w - 6;     // 30
    body_h = face_h - 5;     // 22
    body_d = 24;
    body_r = 1.5;

    // Front bezel recess (shallow pocket around opening)
    bezel_w = face_w - 8;    // 28
    bezel_h = face_h - 9;    // 18
    bezel_d = 1.2;
    bezel_r = 1.2;

    // IEC opening (subtractive)
    open_w = face_w - 9;     // 27
    open_h = face_h - 8;     // 19
    open_r = 2.0;
    open_d = face_t + 1.0;   // cut through faceplate with margin

    // Fuse drawer housing (front protrusion, typical fused inlet)
    fuse_w = 14.5;
    fuse_h = 8.5;
    fuse_d = 5.2;
    fuse_r = 1.0;

    // Fuse drawer "lip" / pull tab (small protrusion on fuse housing)
    lip_w = 10.0;
    lip_h = 2.6;
    lip_d = 1.6;
    lip_r = 0.8;

    // Switch/retainer boss (front protrusion)
    sw_w = 12.0;
    sw_h = 8.0;
    sw_d = 4.2;
    sw_r = 1.0;

    // Rear terminals (3 blades)
    term_w = 2.2;
    term_h = 6.0;
    term_d = 8.0;
    term_spacing = 6.3;

    // Z placement (computed)
    z_face = 0;
    z_front_surface = z_face + face_t/2;

    // Rear body overlaps into faceplate
    overlap_fb = 0.8;
    z_body = z_face - (face_t/2 + body_d/2 - overlap_fb);

    // Terminals overlap into rear body
    overlap_bt = 0.9;
    z_term = z_body - (body_d/2 + term_d/2 - overlap_bt);

    // Front protrusions overlap into faceplate
    overlap_front = 0.8;
    z_fuse = z_front_surface + fuse_d/2 - overlap_front;
    z_sw   = z_front_surface + sw_d/2   - overlap_front;

    // Fuse lip sits on fuse housing front face with overlap
    overlap_lip = 0.6;
    z_lip = (z_fuse + fuse_d/2) + lip_d/2 - overlap_lip;

    // Bezel recess is subtractive into faceplate
    z_bezel = z_front_surface - bezel_d/2 + 0.15;

    // Opening subtraction centered in faceplate
    z_open = z_face; // extrude centered, depth handles cut

    // Positions on face (fuse top, switch bottom)
    margin_y = 2.0;
    y_fuse =  (face_h/2 - fuse_h/2 - margin_y);
    y_sw   = -(face_h/2 - sw_h/2   - margin_y);

    // Fuse drawer cavity (subtractive) inside fuse housing
    fuse_cav_w = fuse_w - 2.2;
    fuse_cav_h = fuse_h - 2.0;
    fuse_cav_d = fuse_d - 1.6;
    fuse_cav_r = 0.8;
    z_fuse_cav = z_fuse + 0.4; // keep some front wall thickness

    // Switch recess (subtractive) inside switch boss
    sw_cav_w = sw_w - 2.0;
    sw_cav_h = sw_h - 2.0;
    sw_cav_d = sw_d - 1.6;
    sw_cav_r = 0.8;
    z_sw_cav = z_sw + 0.3;

    // Pin holes (subtractive) inside IEC opening (visual)
    pin_r = 1.25;
    pin_y = 3.6;
    pin_x = 0;
    pin_dx = 7.0;
    pin_d = face_t + 2.0;
    z_pin = z_face;

    difference() {
        union() {
            // Faceplate (exact requested size)
            translate([0, 0, z_face])
                rounded_box(face_w, face_h, face_t, face_r);

            // Rear body
            translate([0, 0, z_body])
                rounded_box(body_w, body_h, body_d, body_r);

            // Fuse drawer housing (front)
            translate([0, y_fuse, z_fuse])
                rounded_box(fuse_w, fuse_h, fuse_d, fuse_r);

            // Fuse pull lip (front-most)
            translate([0, y_fuse + fuse_h/2 - lip_h/2 - 0.6, z_lip])
                rounded_box(lip_w, lip_h, lip_d, lip_r);

            // Switch/retainer boss (front)
            translate([0, y_sw, z_sw])
                rounded_box(sw_w, sw_h, sw_d, sw_r);

            // Rear terminals (3 blades), connected to rear body
            for (i = [-1, 0, 1]) {
                translate([i*term_spacing, 0, z_term])
                    rounded_box(term_w, term_h, term_d, 0.6);
            }
        }

        // Bezel recess pocket
        translate([0, 0, z_bezel])
            rounded_box(bezel_w, bezel_h, bezel_d + 0.3, bezel_r);

        // IEC C14-ish opening through faceplate
        translate([0, 0, z_open])
            linear_extrude(height=open_d, center=true)
                iec_c14_opening_2d(open_w, open_h, open_r, notch_w=10.5, notch_h=3.4);

        // Pin holes (L/N and Earth) as visual detail
        // Earth (top center)
        translate([pin_x, pin_y, z_pin])
            cylinder(h=pin_d, r=pin_r, center=true);

        // L/N (bottom left/right)
        translate([-pin_dx/2, -pin_y, z_pin])
            cylinder(h=pin_d, r=pin_r, center=true);
        translate([ pin_dx/2, -pin_y, z_pin])
            cylinder(h=pin_d, r=pin_r, center=true);

        // Fuse drawer cavity (subtractive)
        translate([0, y_fuse, z_fuse_cav])
            rounded_box(fuse_cav_w, fuse_cav_h, fuse_cav_d, fuse_cav_r);

        // Small fuse latch notch (subtractive) on fuse cavity front edge
        latch_w = 4.0;
        latch_h = 1.6;
        latch_d = 1.2;
        z_latch = (z_fuse + fuse_d/2) - latch_d/2 + 0.2;
        translate([0, y_fuse + fuse_h/2 - latch_h/2 - 1.0, z_latch])
            rounded_box(latch_w, latch_h, latch_d, 0.5);

        // Switch recess (subtractive)
        translate([0, y_sw, z_sw_cav])
            rounded_box(sw_cav_w, sw_cav_h, sw_cav_d, sw_cav_r);

        // Small retainer slot (subtractive) on switch boss
        slot_w = 6.0;
        slot_h = 1.6;
        slot_d = 1.4;
        z_slot = (z_sw + sw_d/2) - slot_d/2 + 0.2;
        translate([0, y_sw - sw_h/2 + slot_h/2 + 1.0, z_slot])
            rounded_box(slot_w, slot_h, slot_d, 0.5);
    }
}

iec_fused_inlet_old(36.0, 27.0);