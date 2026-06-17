$fn = 64;

// LCD 1602A overall target: 71.3mm x 24.3mm (PCB outline)
module lcd1602a_module(pcb_w=71.3, pcb_h=24.3) {

    // --- Key dimensions (approximate but feature-complete) ---
    pcb_t        = 1.6;

    bezel_w      = 71.3;
    bezel_h      = 24.3;
    bezel_t      = 3.2;

    // Viewing window (approx)
    win_w        = 60.0;
    win_h        = 15.0;
    win_depth    = 1.2;   // recess depth into bezel

    // Back components (approx)
    blob_w       = 66.0;
    blob_h       = 18.0;
    blob_t       = 4.8;

    // Mounting holes (typical 1602A: 4 holes)
    hole_d       = 3.2;
    hole_edge_x  = 2.5;   // distance from PCB edge to hole center (x)
    hole_edge_y  = 2.5;   // distance from PCB edge to hole center (y)

    hole_x = pcb_w/2 - hole_edge_x;
    hole_y = pcb_h/2 - hole_edge_y;

    // Pin header (1x16) on top edge
    pins_n       = 16;
    pin_pitch    = 2.54;
    pin_d        = 0.9;
    pin_len      = 6.0;   // protrusion below PCB
    header_body_t= 2.5;
    header_body_h= 3.0;
    header_body_w= (pins_n-1)*pin_pitch + 2.0; // small margin
    header_body_d= 4.0;

    // Placement along top edge (y+)
    header_y = pcb_h/2 - 1.2; // near top edge, still on PCB

    // Z stacking (centered around PCB midplane)
    pcb_z        = 0;
    bezel_z      = pcb_t/2 + bezel_t/2 - 0.2; // slight overlap into PCB
    blob_z       = -pcb_t/2 - blob_t/2 + 0.2; // slight overlap into PCB

    // Header body sits on top of PCB, pins go downward
    header_body_z = pcb_t/2 + header_body_t/2 - 0.2;
    pins_z        = -pcb_t/2 - pin_len/2 + 0.2;

    // Small overlap helper
    ov = 0.2;

    // --- Build ONE connected solid (no subtractions that separate parts) ---
    difference() {
        union() {
            // PCB
            translate([0,0,pcb_z])
                cube([pcb_w, pcb_h, pcb_t], center=true);

            // Front bezel (with recessed window cut later via difference)
            translate([0,0,bezel_z])
                cube([bezel_w, bezel_h, bezel_t], center=true);

            // Back "controller blob"
            translate([0,0,blob_z])
                cube([blob_w, blob_h, blob_t], center=true);

            // Pin header plastic body (on top edge)
            translate([0, header_y - header_body_d/2 + 0.6, header_body_z])
                cube([header_body_w, header_body_d, header_body_t], center=true);

            // Pins (cylinders) - connected to PCB by slight overlap
            for (i = [0:pins_n-1]) {
                x = -((pins_n-1)*pin_pitch)/2 + i*pin_pitch;
                translate([x, header_y, pins_z])
                    cylinder(d=pin_d, h=pin_len + ov, center=true);
            }

            // Small solder pad strip under header (keeps connectivity robust)
            translate([0, header_y, -pcb_t/2 + 0.4])
                cube([header_body_w, 2.2, 0.8], center=true);
        }

        // Viewing window recess into bezel (does not cut through entire model)
        translate([0,0,bezel_z + bezel_t/2 - win_depth/2 + ov])
            cube([win_w, win_h, win_depth + ov], center=true);

        // Mounting holes through PCB+bezel (keeps model as one solid via difference)
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx*hole_x, sy*hole_y, 0])
                    cylinder(d=hole_d, h=pcb_t + bezel_t + 2*ov, center=true);
    }
}

lcd1602a_module();