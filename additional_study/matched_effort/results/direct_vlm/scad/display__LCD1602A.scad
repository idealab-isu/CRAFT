$fn = 64;

// LCD 1602A display module (simplified) - overall PCB: 71.3mm x 24.3mm
// Single connected solid (unioned), with bezel, recessed window, header, and 4 mounting holes.

module lcd1602a(
    pcb_x = 71.3,
    pcb_y = 24.3,
    pcb_t = 1.6,

    // Bezel (black frame) on top of PCB
    bezel_x = 66.0,
    bezel_y = 16.0,
    bezel_t = 3.2,

    // Display window recess in bezel
    window_x = 56.0,
    window_y = 12.0,
    window_depth = 1.2,

    // Glass inset (fills the recess)
    glass_t = 1.2,

    // Mounting holes (typical 1602A has 4 holes)
    hole_d = 3.2,
    hole_edge_x = 2.5,   // distance from PCB edge to hole center (X)
    hole_edge_y = 2.0,   // distance from PCB edge to hole center (Y)

    // 16-pin header (1x16, 2.54mm pitch)
    header_pins = 16,
    header_pitch = 2.54,
    header_pin_w = 0.64,
    header_pin_h = 6.0,
    header_body_h = 2.5,
    header_body_w = 3.0,
    header_inset_from_edge = 3.5, // from PCB edge to header centerline
    overlap = 0.2                 // small overlap to guarantee connectivity
) {

    // Derived
    header_len = (header_pins - 1) * header_pitch;
    header_x = header_len + header_body_w; // plastic body length along X
    header_y = header_body_w;
    header_z = header_body_h;

    // Place header along one long edge (negative Y), sitting on PCB top
    header_center_y = -pcb_y/2 + header_inset_from_edge;
    header_body_z0 = pcb_t - overlap; // overlap into PCB to ensure one connected solid

    // Hole centers
    hx = pcb_x/2 - hole_edge_x;
    hy = pcb_y/2 - hole_edge_y;

    union() {

        // PCB with mounting holes
        difference() {
            translate([-pcb_x/2, -pcb_y/2, 0])
                cube([pcb_x, pcb_y, pcb_t], center=false);

            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*hx, sy*hy, -1])
                    cylinder(d=hole_d, h=pcb_t + 2, center=false);
            }
        }

        // Bezel (top) with window recess
        translate([0, 0, pcb_t - overlap])
        difference() {
            translate([-bezel_x/2, -bezel_y/2, 0])
                cube([bezel_x, bezel_y, bezel_t + overlap], center=false);

            // Window recess cut from top face down by window_depth
            translate([-window_x/2, -window_y/2, bezel_t - window_depth])
                cube([window_x, window_y, window_depth + 0.3], center=false);
        }

        // Glass inset (fills recess) - overlaps slightly into bezel for connectivity
        translate([0, 0, pcb_t + bezel_t - window_depth - overlap])
            translate([-window_x/2, -window_y/2, 0])
                cube([window_x, window_y, glass_t + overlap], center=false);

        // Header plastic body (on top of PCB, near one edge)
        translate([-header_x/2, header_center_y - header_y/2, header_body_z0])
            cube([header_x, header_y, header_z + overlap], center=false);

        // Pins (extend downward through/under PCB; overlap into header body)
        for (i = [0:header_pins-1]) {
            x = -header_len/2 + i*header_pitch;

            // Pin starts slightly inside header body and extends below PCB
            pin_z0 = header_body_z0 + header_z - overlap; // inside header body
            pin_h_total = header_pin_h + header_body_h + overlap;

            translate([x - header_pin_w/2,
                       header_center_y - header_pin_w/2,
                       pin_z0 - header_pin_h])
                cube([header_pin_w, header_pin_w, pin_h_total], center=false);
        }
    }
}

lcd1602a();