$fn = 64;

// Microcontroller development board overall size (mm)
board_x  = 68.58;
board_y  = 53.34;
board_th = 1.6;

// Small overlap to guarantee a single connected solid
eps = 0.25;

// ---------- Helper: rounded rectangle prism (centered in XY, bottom at z=0) ----------
module rounded_rect_prism(x, y, z, r) {
    r2 = min(r, min(x, y)/2);
    linear_extrude(height=z, center=false)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

// ---------- Board + features (single connected solid) ----------
module dev_board() {

    // PCB outline
    corner_r = 2.0;

    // Mounting hole "boss rings" (visual only; still one solid)
    hole_d = 3.2;
    hole_r = hole_d/2;
    hole_inset = 4.0;
    boss_od = hole_d + 2.2;
    boss_h  = 0.9;

    // Component heights
    ic_h        = 2.4;
    usb_h       = 3.6;
    header_h    = 7.0;
    small_h     = 1.2;
    btn_h       = 2.0;

    // Header geometry (two long headers along X edges)
    header_w   = 3.0;                 // across pins
    header_len = board_y - 2*6.0;     // leave margin from corners

    // USB connector geometry (on +X edge)
    usb_len_x = 9.0;   // protrusion outward from board edge
    usb_w_y   = 12.0;
    usb_z     = usb_h;

    // Power jack / connector (on -X edge)
    pwr_len_x = 7.5;
    pwr_w_y   = 10.0;
    pwr_h     = 4.0;

    // Main IC package
    ic_x = 14.0;
    ic_y = 14.0;

    // Additional recognizable features
    // Small "pin block" near top edge (e.g., SWD/ICSP)
    aux_hdr_x = 10.0;
    aux_hdr_y = 4.0;
    aux_hdr_h = 5.0;

    // Crystal-like can
    xtal_x = 8.0;
    xtal_y = 4.0;
    xtal_h = 2.0;

    // Regulator-like block
    reg_x = 9.0;
    reg_y = 7.0;
    reg_h = 2.2;

    union() {
        // PCB (centered at origin, bottom at z=0)
        rounded_rect_prism(board_x, board_y, board_th, corner_r);

        // Mounting hole boss rings (sit on top surface, overlap into PCB)
        for (sx = [-1, 1], sy = [-1, 1]) {
            xh = sx*(board_x/2 - hole_inset);
            yh = sy*(board_y/2 - hole_inset);
            translate([xh, yh, board_th - boss_h + eps])
                difference() {
                    cylinder(h=boss_h, r=boss_od/2, center=false);
                    translate([0,0,-eps]) cylinder(h=boss_h + 2*eps, r=hole_r, center=false);
                }
        }

        // Dual pin headers along long edges (connected; bottom slightly into PCB)
        // Left header (-X edge)
        translate([-(board_x/2 - header_w/2), 0, board_th + header_h/2 - eps])
            cube([header_w, header_len, header_h], center=true);

        // Right header (+X edge)
        translate([(board_x/2 - header_w/2), 0, board_th + header_h/2 - eps])
            cube([header_w, header_len, header_h], center=true);

        // USB connector on +X edge, centered in Y (connected by overlap)
        translate([board_x/2 + usb_len_x/2 - eps, 0, board_th + usb_z/2 - eps])
            cube([usb_len_x, usb_w_y, usb_z], center=true);

        // Power connector on -X edge (connected by overlap)
        translate([-(board_x/2 + pwr_len_x/2 - eps), 0, board_th + pwr_h/2 - eps])
            cube([pwr_len_x, pwr_w_y, pwr_h], center=true);

        // Main microcontroller IC near center
        translate([0, 0, board_th + ic_h/2 - eps])
            cube([ic_x, ic_y, ic_h], center=true);

        // Regulator-like block near +Y, -X quadrant
        translate([-(board_x*0.22), (board_y*0.22), board_th + reg_h/2 - eps])
            cube([reg_x, reg_y, reg_h], center=true);

        // Crystal-like can near IC
        translate([(board_x*0.18), (board_y*0.05), board_th + xtal_h/2 - eps])
            cube([xtal_x, xtal_y, xtal_h], center=true);

        // Aux header near +Y edge (connected)
        aux_y_pos = (board_y/2 - 6.0 - aux_hdr_y/2);
        translate([0, aux_y_pos, board_th + aux_hdr_h/2 - eps])
            cube([aux_hdr_x, aux_hdr_y, aux_hdr_h], center=true);

        // A few small passives (connected)
        translate([-(ic_x*0.95),  (ic_y*0.65), board_th + small_h/2 - eps])
            cube([6.0, 3.0, small_h], center=true);

        translate([(ic_x*0.95), -(ic_y*0.65), board_th + small_h/2 - eps])
            cube([6.0, 3.0, small_h], center=true);

        translate([-(board_x*0.10), -(board_y*0.22), board_th + small_h/2 - eps])
            cube([7.0, 4.0, small_h], center=true);

        // Reset button (small square) near +Y
        translate([0, board_y*0.28, board_th + btn_h/2 - eps])
            cube([6.0, 6.0, btn_h], center=true);
    }
}

dev_board();