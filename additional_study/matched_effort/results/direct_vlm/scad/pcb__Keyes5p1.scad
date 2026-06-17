$fn = 64;

// Board dimensions (mm)
board_len = 68.58;
board_wid = 53.34;
board_thk = 1.6;
corner_r  = 3;

// Feature parameters (generic dev-board look)
hole_d = 3.2;
hole_edge = 4.0;

soldermask_raise = 0.15;   // slight raised "silkscreen/mask" area (still solid)
mask_inset = 1.2;

mcu_size = [14, 14, 1.2];
mcu_offset = [0, 0];       // centered

usb_size = [12, 9, 4.0];   // protrudes from one edge
usb_overlap = 0.8;         // overlap into board to ensure connectivity

header_pitch = 2.54;
header_rows = 2;
header_cols = 15;
header_pin_d = 1.0;
header_pin_h = 6.0;
header_body_h = 2.5;
header_body_w = header_pitch * (header_rows-1) + 3.0;
header_body_l = header_pitch * (header_cols-1) + 3.0;

module rounded_rect_2d(l, w, r){
    r2 = min(r, min(l, w)/2);
    hull(){
        translate([ r2,      r2]) circle(r=r2);
        translate([ l-r2,    r2]) circle(r=r2);
        translate([ r2,   w-r2]) circle(r=r2);
        translate([ l-r2, w-r2]) circle(r=r2);
    }
}

module rounded_box(l,w,h,r){
    linear_extrude(height=h)
        rounded_rect_2d(l,w,r);
}

module board_base(){
    // Board with mounting holes (holes are cut out)
    difference(){
        rounded_box(board_len, board_wid, board_thk, corner_r);

        // 4 mounting holes near corners
        for (sx = [0,1], sy = [0,1]){
            translate([
                hole_edge + sx*(board_len - 2*hole_edge),
                hole_edge + sy*(board_wid - 2*hole_edge),
                -0.2
            ])
                cylinder(d=hole_d, h=board_thk+0.4);
        }
    }
}

module raised_mask(){
    // Slightly raised inset area to suggest soldermask/silkscreen (still one solid)
    inset_l = board_len - 2*mask_inset;
    inset_w = board_wid - 2*mask_inset;
    translate([mask_inset, mask_inset, board_thk - 0.01])
        rounded_box(inset_l, inset_w, soldermask_raise, max(0, corner_r - mask_inset));
}

module usb_port(){
    // Centered on left edge, protruding outward, overlapping into board
    // Place so inner face is inside board by usb_overlap
    translate([
        -usb_size[0] + usb_overlap,
        (board_wid - usb_size[1])/2,
        board_thk - 0.01
    ])
        cube(usb_size);
}

module mcu_chip(){
    translate([
        (board_len - mcu_size[0])/2 + mcu_offset[0],
        (board_wid - mcu_size[1])/2 + mcu_offset[1],
        board_thk - 0.01
    ])
        cube(mcu_size);
}

module header_block(x, y, rot=0){
    // Plastic body
    translate([x, y, board_thk - 0.01])
        rotate([0,0,rot])
            union(){
                // body centered around pin grid
                translate([-header_body_l/2, -header_body_w/2, 0])
                    cube([header_body_l, header_body_w, header_body_h]);

                // pins (cylinders) rising from board through body
                for (c = [0:header_cols-1])
                    for (r = [0:header_rows-1]){
                        translate([
                            (c*header_pitch) - (header_pitch*(header_cols-1))/2,
                            (r*header_pitch) - (header_pitch*(header_rows-1))/2,
                            -0.2
                        ])
                            cylinder(d=header_pin_d, h=header_pin_h + 0.2);
                    }
            }
}

module misc_components(){
    // A few generic SMD parts to make it look like a dev board
    // All placed on top and slightly overlapping into board for connectivity
    comp_h = 1.0;
    // regulator
    translate([board_len*0.70, board_wid*0.20, board_thk - 0.01])
        cube([8, 6, 1.4]);
    // capacitor blocks
    translate([board_len*0.62, board_wid*0.30, board_thk - 0.01])
        cube([4, 3, comp_h]);
    translate([board_len*0.58, board_wid*0.26, board_thk - 0.01])
        cube([3, 2.5, comp_h]);
    // crystal
    translate([board_len*0.45, board_wid*0.55, board_thk - 0.01])
        cube([6, 3, 1.2]);
}

union(){
    board_base();
    raised_mask();

    // USB port on left edge
    usb_port();

    // MCU in center
    mcu_chip();

    // Two long headers along top and bottom edges (inside board outline)
    // Positioned with formulas from board dimensions
    header_margin = 6.0;
    header_y_top = board_wid - header_margin;
    header_y_bot = header_margin;

    header_x_center = board_len/2;

    header_block(header_x_center, header_y_top, 0);
    header_block(header_x_center, header_y_bot, 0);

    // Extra components
    misc_components();
}