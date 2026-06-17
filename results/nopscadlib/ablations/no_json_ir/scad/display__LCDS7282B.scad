$fn = 64;

// One-piece connected solid approximation of an LCD module (S-7282B style)
// Overall footprint: 73.6mm x 28.7mm

module lcd_module_s7282b(
    W = 73.6,          // overall width (X)
    H = 28.7,          // overall height (Y)
    T = 6.2,           // overall thickness (Z)
    overlap = 0.4      // intentional overlap to guarantee connectivity
) {
    // Front bezel/frame
    bezel_t = 2.0;
    bezel_margin_x = 3.2;
    bezel_margin_y = 2.6;

    // Screen window recess (cut into bezel)
    window_w = W - 2*bezel_margin_x;
    window_h = H - 2*bezel_margin_y;
    window_depth = 0.9;

    // Rear PCB slab
    pcb_t = 1.6;
    pcb_margin_x = 1.0;
    pcb_margin_y = 1.0;
    pcb_w = W - 2*pcb_margin_x;
    pcb_h = H - 2*pcb_margin_y;

    // Back components (as bumps on PCB)
    blob_h = 1.6;
    blob1 = [18, 10, blob_h];
    blob2 = [14, 8,  blob_h];
    blob3 = [10, 6,  blob_h];

    // Pin header block (integrated)
    header_pins = 16;
    pin_pitch = 2.54;
    header_w = header_pins * pin_pitch; // along X
    header_d = 4.0;                     // along Y
    header_h = 3.0;                     // along Z

    // Place header near bottom edge on back side
    header_y_from_bottom = 3.2;
    header_yc = -H/2 + header_y_from_bottom + header_d/2;

    // Mounting holes (represented as shallow front counterbores + through holes)
    hole_r = 1.25;
    hole_inset_x = 3.0;
    hole_inset_y = 3.0;
    hole_x = W/2 - hole_inset_x;
    hole_y = H/2 - hole_inset_y;

    // Z layout (centered overall)
    // Total thickness T = bezel_t + (core_t) + pcb_t
    core_t = max(0.1, T - bezel_t - pcb_t);

    z_front = +T/2;
    z_bezel_c = z_front - bezel_t/2;
    z_core_c  = z_front - bezel_t - core_t/2;
    z_pcb_c   = -T/2 + pcb_t/2;

    difference() {
        union() {
            // Bezel/frame (front)
            translate([0, 0, z_bezel_c])
                cube([W, H, bezel_t], center=true);

            // Core body (middle)
            translate([0, 0, z_core_c])
                cube([W - 0.8, H - 0.8, core_t + overlap], center=true);

            // PCB (back)
            translate([0, 0, z_pcb_c])
                cube([pcb_w, pcb_h, pcb_t + overlap], center=true);

            // Back components (bumps) on PCB
            translate([-W*0.18,  H*0.12, z_pcb_c + pcb_t/2 + blob1[2]/2 - overlap/2])
                cube(blob1, center=true);
            translate([ W*0.22,  H*0.10, z_pcb_c + pcb_t/2 + blob2[2]/2 - overlap/2])
                cube(blob2, center=true);
            translate([ W*0.05, -H*0.18, z_pcb_c + pcb_t/2 + blob3[2]/2 - overlap/2])
                cube(blob3, center=true);

            // Pin header block (back, near bottom edge)
            translate([0, header_yc, z_pcb_c + pcb_t/2 + header_h/2 - overlap/2])
                cube([header_w, header_d, header_h], center=true);

            // Small strain-relief/connector base behind header (keeps it looking like a module)
            translate([0, header_yc + header_d/2 + 1.2, z_pcb_c + pcb_t/2 + (header_h-0.6)/2 - overlap/2])
                cube([header_w*0.75, 2.4, header_h-0.6], center=true);
        }

        // Screen window recess in bezel (front cut)
        translate([0, 0, z_front - window_depth/2 + overlap/2])
            cube([window_w, window_h, window_depth + overlap], center=true);

        // Mounting through-holes (4 corners)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hole_x, sy*hole_y, 0])
                cylinder(h = T + 2*overlap, r = hole_r, center=true);
        }

        // Shallow front counterbore rings (visual detail)
        cb_r = hole_r + 0.9;
        cb_d = 0.8;
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hole_x, sy*hole_y, z_front - cb_d/2 + overlap/2])
                cylinder(h = cb_d + overlap, r = cb_r, center=true);
        }
    }
}

// Render
lcd_module_s7282b();