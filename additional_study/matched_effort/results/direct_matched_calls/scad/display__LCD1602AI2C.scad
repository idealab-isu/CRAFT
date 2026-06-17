$fn = 64;

// LCD 1602A display module (approx) overall size: 71.3mm x 24.3mm
// Simple solid model with PCB, bezel, and display window.

module lcd1602a_module(
    pcb_x = 71.3,
    pcb_y = 24.3,
    pcb_z = 1.6,

    bezel_margin = 1.2,     // bezel overhang beyond PCB on each side
    bezel_z = 3.2,          // bezel height above PCB top

    window_x = 56.0,        // visible window opening (approx)
    window_y = 14.0,
    window_inset = 0.8,     // inset from bezel top
    window_depth = 2.2,     // cut depth into bezel

    corner_r = 1.2,

    hole_d = 3.2,           // mounting holes (approx M3 clearance)
    hole_edge_x = 2.5,      // distance from PCB edge to hole center (approx)
    hole_edge_y = 2.5
) {
    pcb_color = [0.05, 0.35, 0.12];
    bezel_color = [0.10, 0.10, 0.10];
    glass_color = [0.05, 0.20, 0.25, 0.65];

    module rounded_rect_2d(x, y, r) {
        r2 = min(r, min(x, y)/2);
        hull() {
            translate([ r2,  r2]) circle(r=r2);
            translate([x-r2,  r2]) circle(r=r2);
            translate([ r2, y-r2]) circle(r=r2);
            translate([x-r2, y-r2]) circle(r=r2);
        }
    }

    module pcb_body() {
        difference() {
            color(pcb_color)
                linear_extrude(height=pcb_z)
                    rounded_rect_2d(pcb_x, pcb_y, corner_r);

            // mounting holes (4 corners)
            for (sx = [hole_edge_x, pcb_x - hole_edge_x])
            for (sy = [hole_edge_y, pcb_y - hole_edge_y])
                translate([sx, sy, -0.1])
                    cylinder(d=hole_d, h=pcb_z + 0.2);
        }
    }

    module bezel_body() {
        bx = pcb_x + 2*bezel_margin;
        by = pcb_y + 2*bezel_margin;

        difference() {
            color(bezel_color)
                translate([-bezel_margin, -bezel_margin, pcb_z])
                    linear_extrude(height=bezel_z)
                        rounded_rect_2d(bx, by, corner_r + 0.6);

            // window cut
            translate([ (pcb_x - window_x)/2, (pcb_y - window_y)/2, pcb_z + bezel_z - window_inset - window_depth ])
                cube([window_x, window_y, window_depth + 0.2], center=false);
        }

        // glass insert (slightly recessed)
        color(glass_color)
            translate([ (pcb_x - window_x)/2 + 0.4, (pcb_y - window_y)/2 + 0.4, pcb_z + bezel_z - window_inset - 0.8 ])
                cube([window_x - 0.8, window_y - 0.8, 0.8], center=false);
    }

    // Optional: simple 16-pin header block on top edge (approx)
    module header_block() {
        pin_count = 16;
        pitch = 2.54;
        hdr_x = (pin_count-1)*pitch + 2.0;
        hdr_y = 5.0;
        hdr_z = 3.5;

        // place near top edge, centered
        translate([ (pcb_x - hdr_x)/2, pcb_y - hdr_y - 1.0, pcb_z ])
            color([0.15,0.15,0.15])
                cube([hdr_x, hdr_y, hdr_z], center=false);
    }

    pcb_body();
    bezel_body();
    header_block();
}

lcd1602a_module();