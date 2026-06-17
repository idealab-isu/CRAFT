$fn = 32;

// Mainboard overall size (mm)
board_x  = 102.0;
board_y  = 90.25;
board_th = 1.6;

// Small overlap to guarantee watertight unions
ov = 0.15;

// ---------- Helpers ----------
module rounded_plate(x, y, z, r) {
    // Fast rounded rectangle prism using 2D offset (no minkowski)
    linear_extrude(height=z, center=true, convexity=5)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module box_solid(x, y, z) { cube([x,y,z], center=true); }

// ---------- Board + features ----------
module mainboard() {

    corner_r = 3;

    // Mounting holes (typical M3 clearance)
    hole_d = 3.2;
    hole_edge_x = 6.0;
    hole_edge_y = 6.0;

    // Component heights
    comp_base_h = 2.0;
    ic_h        = 3.0;
    conn_h      = 10.0;

    // Component footprints
    ic_x = 18; ic_y = 18;
    driver_x = 14; driver_y = 18;

    // Connectors (approximate)
    usb_x = 14; usb_y = 12;
    sd_x  = 16; sd_y  = 14;
    term_x = 40; term_y = 12;
    pin_x  = 50; pin_y  = 8;

    // Z placement
    z_top_surface = board_th/2;
    function z_comp(comp_h) = z_top_surface + comp_h/2 - ov;

    difference() {
        union() {
            // PCB
            color([0.05, 0.45, 0.18])
                rounded_plate(board_x, board_y, board_th, corner_r);

            // Central MCU/SoC
            translate([0, 0, z_comp(ic_h)])
                box_solid(ic_x, ic_y, ic_h);

            // Stepper driver modules (3x)
            for (i = [-1, 0, 1]) {
                translate([board_x*0.18, i*(driver_y+4), z_comp(comp_base_h)])
                    box_solid(driver_x, driver_y, comp_base_h);
            }

            // USB connector on left edge
            translate([-(board_x/2 - usb_x/2), -(board_y*0.15), z_comp(conn_h)])
                box_solid(usb_x, usb_y, conn_h);

            // SD card slot on left edge (toward top)
            translate([-(board_x/2 - sd_x/2), (board_y*0.25), z_comp(6)])
                box_solid(sd_x, sd_y, 6);

            // Screw terminal block on right edge
            translate([(board_x/2 - term_x/2), -(board_y*0.25), z_comp(conn_h)])
                box_solid(term_x, term_y, conn_h);

            // Long pin header along top edge
            translate([0, (board_y/2 - pin_y/2), z_comp(6)])
                box_solid(pin_x, pin_y, 6);

            // Capacitors (reduced segmentation via $fn=32)
            cap_r = 4;
            cap_h = 8;
            for (p = [[board_x*0.25, board_y*0.10],
                      [board_x*0.30, board_y*0.22],
                      [board_x*0.18, -board_y*0.05]]) {
                translate([p[0], p[1], z_comp(cap_h)])
                    cylinder(r=cap_r, h=cap_h, center=true);
            }

            // Heatsink-ish block near drivers
            hs_x = 30; hs_y = 22; hs_h = 6;
            translate([board_x*0.18, 0, z_comp(hs_h)])
                box_solid(hs_x, hs_y, hs_h);
        }

        // Mounting holes through PCB
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(board_x/2 - hole_edge_x), sy*(board_y/2 - hole_edge_y), 0])
                cylinder(d=hole_d, h=board_th + 2, center=true);
        }
    }
}

mainboard();