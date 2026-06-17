$fn = 64;

// Parameters (exact PCB size)
board_length = 123.0;   // X
board_width  = 100.0;   // Y
board_thickness = 1.6;  // Z

// Small overlap to guarantee one connected solid
eps = 0.4;

// ---------- Helpers ----------
module rounded_rect_prism(l, w, h, r) {
    // Rounded rectangle extruded to height h, centered
    linear_extrude(height=h, center=true)
        offset(r=r)
            square([l - 2*r, w - 2*r], center=true);
}

module box_centered(size=[10,10,10]) {
    cube(size, center=true);
}

// ---------- Main Model ----------
module printer_control_board() {

    // PCB base with mounting holes removed (holes are voids; remaining solid is connected)
    corner_r = 3.0;
    hole_d = 3.2;
    hole_r = hole_d/2;

    // Place holes with formula-based offsets from edges
    hole_edge_x = 6.0;
    hole_edge_y = 6.0;

    // Z references
    pcb_top_z = board_thickness/2;
    pcb_bot_z = -board_thickness/2;

    // Component heights
    comp_clear = eps; // overlap into PCB
    header_h = 9.0;
    header_w = 10.0;
    header_l = 50.0;

    usb_w = 14.0;
    usb_l = 16.0;
    usb_h = 11.0;

    power_w = 12.0;
    power_l = 18.0;
    power_h = 12.0;

    stepper_w = 10.0;
    stepper_l = 16.0;
    stepper_h = 9.0;

    cap_d = 8.0;
    cap_h = 12.0;

    mcu_l = 18.0;
    mcu_w = 18.0;
    mcu_h = 3.0;

    heatsink_l = 14.0;
    heatsink_w = 14.0;
    heatsink_h = 8.0;

    // Positions (all formula-based from board dimensions)
    x_left  = -board_length/2;
    x_right =  board_length/2;
    y_front = -board_width/2;
    y_back  =  board_width/2;

    // Connector centerlines near edges
    edge_inset = 2.0;

    // Build as one connected solid: union of PCB + components, with holes subtracted
    difference() {
        union() {
            // PCB
            color([0.0, 0.4, 0.2])
                rounded_rect_prism(board_length, board_width, board_thickness, corner_r);

            // --- Major connectors/components on top side (all overlap into PCB by eps) ---
            // Long pin header along back edge
            translate([0,
                       y_back - edge_inset - header_w/2 + eps,
                       pcb_top_z + header_h/2 - comp_clear])
                color([0.1,0.1,0.1])
                    box_centered([header_l, header_w, header_h]);

            // USB connector on right edge (mid)
            translate([x_right - edge_inset - usb_l/2 + eps,
                       0,
                       pcb_top_z + usb_h/2 - comp_clear])
                color([0.75,0.75,0.75])
                    box_centered([usb_l, usb_w, usb_h]);

            // Power terminal on left edge (front-ish)
            translate([x_left + edge_inset + power_l/2 - eps,
                       y_front + board_width*0.25,
                       pcb_top_z + power_h/2 - comp_clear])
                color([0.0,0.2,0.8])
                    box_centered([power_l, power_w, power_h]);

            // Three stepper driver sockets along front edge
            for (i = [-1, 0, 1]) {
                translate([i * (stepper_l + 6.0),
                           y_front + edge_inset + stepper_w/2 - eps,
                           pcb_top_z + stepper_h/2 - comp_clear])
                    color([0.1,0.1,0.1])
                        box_centered([stepper_l, stepper_w, stepper_h]);
            }

            // MCU in center
            translate([0, 0, pcb_top_z + mcu_h/2 - comp_clear])
                color([0.15,0.15,0.15])
                    box_centered([mcu_l, mcu_w, mcu_h]);

            // Heatsink near center-right
            translate([board_length*0.20, 0, pcb_top_z + heatsink_h/2 - comp_clear])
                color([0.2,0.2,0.2])
                    box_centered([heatsink_l, heatsink_w, heatsink_h]);

            // Two electrolytic capacitors near left-middle
            for (yy = [-10, 10]) {
                translate([x_left + board_length*0.22,
                           yy,
                           pcb_top_z + cap_h/2 - comp_clear])
                    color([0.05,0.05,0.05])
                        cylinder(h=cap_h, r=cap_d/2, center=true);
            }

            // Small "chip" near back-left
            translate([x_left + board_length*0.30,
                       y_back - board_width*0.25,
                       pcb_top_z + 2.0/2 - comp_clear])
                color([0.2,0.2,0.2])
                    box_centered([10, 8, 2.0]);
        }

        // Mounting holes (through PCB only)
        for (sx = [-1, 1])
            for (sy = [-1, 1]) {
                translate([sx*(board_length/2 - hole_edge_x),
                           sy*(board_width/2  - hole_edge_y),
                           0])
                    cylinder(h=board_thickness + 2*eps, r=hole_r, center=true);
            }
    }
}

// Render
printer_control_board();