$fn = 64;

// Target PCB size
board_length = 203.2;
board_width  = 49.53;
board_thick  = 1.6;

// Small overlap to guarantee watertight unions
overlap = 0.2;

// ---------- Helper ----------
module rounded_rect_2d(L, W, r){
    // 2D rounded rectangle centered at origin
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r), sy*(W/2 - r)]) circle(r=r);
    }
}

module pcb_with_features(){
    // Board corner radius (typical PCB)
    corner_r = 2.5;

    // Mounting holes (typical M3 clearance)
    hole_d = 3.2;
    hole_r = hole_d/2;

    // Keep holes inside board with a margin
    hole_edge_margin = 5.0;
    hole_x = board_length/2 - hole_edge_margin;
    hole_y = board_width/2  - hole_edge_margin;

    // Top-side component heights
    usb_h   = 7.5;
    usb_len = 14.0;
    usb_w   = 12.0;

    term_h   = 10.0;
    term_len = 18.0;
    term_w   = 10.0;

    header_h   = 8.0;
    header_len = 40.0;
    header_w   = 8.0;

    mcu_h   = 3.0;
    mcu_len = 20.0;
    mcu_w   = 20.0;

    // Component placement margins
    edge_clear = 2.0;

    // Derived Z positions (components sit on top of PCB with slight overlap)
    pcb_top_z = board_thick;
    comp_z = pcb_top_z - overlap;

    difference() {
        union() {
            // PCB body (rounded rectangle extruded)
            color([0.05, 0.45, 0.12])
            linear_extrude(height=board_thick)
                rounded_rect_2d(board_length, board_width, corner_r);

            // --- Top-side features (all connected to PCB via overlap) ---

            // USB connector on left edge
            translate([
                -board_length/2 + usb_len/2 + edge_clear,
                0,
                comp_z
            ])
                cube([usb_len, usb_w, usb_h], center=false);

            // Screw terminal block on right edge
            translate([
                board_length/2 - term_len - edge_clear,
                0 - term_w/2,
                comp_z
            ])
                cube([term_len, term_w, term_h], center=false);

            // Pin header along top edge
            translate([
                0 - header_len/2,
                board_width/2 - header_w - edge_clear,
                comp_z
            ])
                cube([header_len, header_w, header_h], center=false);

            // MCU package near center
            translate([
                0 - mcu_len/2,
                0 - mcu_w/2,
                comp_z
            ])
                cube([mcu_len, mcu_w, mcu_h], center=false);

            // A few small capacitors (cylinders) near MCU
            cap_r = 2.0;
            cap_h = 4.0;
            for (dx = [-12, 12], dy = [-10, 10]) {
                translate([dx, dy, comp_z])
                    cylinder(r=cap_r, h=cap_h, center=false);
            }
        }

        // --- Mounting holes (cut through PCB only) ---
        // Cut slightly beyond thickness to ensure clean subtraction
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hole_x, sy*hole_y, -overlap])
                cylinder(r=hole_r, h=board_thick + 2*overlap, center=false);
        }
    }
}

// Center the whole model for easier viewing, while preserving exact dimensions
translate([0, 0, 0])
pcb_with_features();