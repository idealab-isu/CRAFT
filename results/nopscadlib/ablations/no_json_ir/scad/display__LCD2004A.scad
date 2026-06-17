// LCD 2004A (20x4) display module approximation
// Overall PCB: 97.0mm x 39.5mm
// One connected solid; no floating parts; all placements derived from dimensions.

$fn = 64;

module lcd_2004a() {
    // --- Key dimensions ---
    pcb_w = 97.0;
    pcb_h = 39.5;
    pcb_t = 1.6;

    // Front bezel/frame (sits on top of PCB)
    bezel_t = 2.4;
    bezel_margin_x = 3.0;
    bezel_margin_y = 2.5;

    // Viewing window (cut into bezel only)
    win_w = 76.0;
    win_h = 25.0;
    win_depth = bezel_t + 0.4;

    // Rear/backpack area (a raised block on the back)
    back_w = 86.0;
    back_h = 30.0;
    back_t = 6.0;

    // Header/pin block on back (connected to back block)
    header_w = 36.0;
    header_h = 6.0;
    header_t = 4.0;

    // Mounting holes (through PCB + bezel)
    hole_d = 3.2;
    hole_r = hole_d/2;
    hole_edge_x = 2.5;
    hole_edge_y = 2.5;

    // Small standoffs around holes on back (keeps model one solid while holes remain)
    standoff_r = 3.2;
    standoff_h = 2.0;

    // --- Derived placements ---
    z_pcb_bot = 0;
    z_pcb_top = z_pcb_bot + pcb_t;

    z_bezel_bot = z_pcb_top;
    z_bezel_top = z_bezel_bot + bezel_t;

    z_back_bot = z_pcb_bot - back_t;
    z_back_top = z_pcb_bot;

    z_header_bot = z_back_bot - header_t;
    z_header_top = z_back_bot;

    // Bezel outer size
    bezel_w = pcb_w - 2*bezel_margin_x;
    bezel_h = pcb_h - 2*bezel_margin_y;

    // Hole positions (from edges)
    hx = pcb_w/2 - hole_edge_x;
    hy = pcb_h/2 - hole_edge_y;

    // Header placement: near bottom edge on back
    header_y = -pcb_h/2 + (hole_edge_y + header_h/2 + 1.0); // derived from edge + clearance

    // Back block centered
    // Ensure it stays within PCB outline
    back_w2 = min(back_w, pcb_w - 2.0);
    back_h2 = min(back_h, pcb_h - 2.0);

    difference() {
        union() {
            // PCB plate
            translate([-pcb_w/2, -pcb_h/2, z_pcb_bot])
                cube([pcb_w, pcb_h, pcb_t], center=false);

            // Front bezel/frame (solid ring; window cut later)
            translate([-bezel_w/2, -bezel_h/2, z_bezel_bot])
                cube([bezel_w, bezel_h, bezel_t], center=false);

            // Rear/backpack block (connected to PCB underside)
            translate([-back_w2/2, -back_h2/2, z_back_bot])
                cube([back_w2, back_h2, back_t], center=false);

            // Header/pin block (connected to back block)
            translate([-header_w/2, header_y - header_h/2, z_header_bot])
                cube([header_w, header_h, header_t], center=false);

            // Rear standoffs around mounting holes (connected to PCB underside)
            for (x = [-hx, hx])
                for (y = [-hy, hy])
                    translate([x, y, z_pcb_bot - standoff_h])
                        cylinder(h=standoff_h, r=standoff_r, center=false);
        }

        // Viewing window cut (only through bezel; does not remove PCB)
        translate([-win_w/2, -win_h/2, z_bezel_bot - 0.01])
            cube([win_w, win_h, win_depth], center=false);

        // Mounting holes through entire assembly thickness
        // From top of bezel to bottom of header (covers all)
        total_h = (z_bezel_top - z_header_bot) + 0.2;
        for (x = [-hx, hx])
            for (y = [-hy, hy])
                translate([x, y, z_header_bot - 0.1])
                    cylinder(h=total_h, r=hole_r, center=false);
    }
}

lcd_2004a();