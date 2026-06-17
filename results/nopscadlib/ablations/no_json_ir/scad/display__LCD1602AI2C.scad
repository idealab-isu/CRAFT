$fn = 64;

// LCD1602A display module overall footprint: 71.3mm x 24.3mm
// Model is ONE connected solid (union of PCB + bezel + header + pins + bosses)

module lcd1602a_module() {

    // --- Key dimensions (mm) ---
    pcb_L = 71.3;
    pcb_W = 24.3;
    pcb_T = 1.6;

    // Front bezel / LCD frame (raised)
    bezel_L = 66.0;
    bezel_W = 20.0;
    bezel_T = 3.2;

    // Display window recess (subtracted from bezel)
    win_L = 56.0;
    win_W = 14.0;
    win_depth = 1.2;

    // Mounting holes (typical 1602A: 4 holes)
    hole_d = 3.2;
    hole_x = 66.0;  // center-to-center along length
    hole_y = 18.0;  // center-to-center along width

    // Back header block + pins (1x16)
    hdr_pins = 16;
    pitch = 2.54;
    hdr_block_L = (hdr_pins - 1) * pitch + 4.0;
    hdr_block_W = 5.0;
    hdr_block_T = 2.5;

    pin_d = 0.8;
    pin_len = 3.0;

    // Small back "controller blob" to add recognizable detail
    blob_L = 28.0;
    blob_W = 10.0;
    blob_T = 1.8;

    // Back standoff bosses around holes (kept solid; holes drilled through)
    boss_d = 6.0;
    boss_T = 1.2;

    // Overlaps to guarantee watertight union
    ov = 0.2;

    difference() {
        union() {
            // PCB base (centered at origin)
            translate([0, 0, 0])
                cube([pcb_L, pcb_W, pcb_T], center=true);

            // Front bezel/frame on top of PCB
            translate([0, 0, pcb_T/2 + bezel_T/2 - ov])
                cube([bezel_L, bezel_W, bezel_T], center=true);

            // Back header plastic block (near one long edge)
            // Place along -Y edge, centered in X
            translate([0,
                       -pcb_W/2 + hdr_block_W/2 - ov,
                       -pcb_T/2 - hdr_block_T/2 + ov])
                cube([hdr_block_L, hdr_block_W, hdr_block_T], center=true);

            // Pins protruding further down from header block
            for (i = [0:hdr_pins-1]) {
                x_i = -((hdr_pins-1)*pitch)/2 + i*pitch;
                translate([x_i,
                           -pcb_W/2 + hdr_block_W/2 - ov,
                           -pcb_T/2 - hdr_block_T + ov - pin_len/2])
                    cylinder(d=pin_d, h=pin_len, center=true);
            }

            // Back controller blob (adds recognizable PCB detail)
            translate([0,
                       pcb_W*0.10,
                       -pcb_T/2 - blob_T/2 + ov])
                cube([blob_L, blob_W, blob_T], center=true);

            // Back bosses at mounting holes (so holes have surrounding material)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*hole_x/2,
                           sy*hole_y/2,
                           -pcb_T/2 - boss_T/2 + ov])
                    cylinder(d=boss_d, h=boss_T, center=true);
            }
        }

        // Drill mounting holes through entire assembly thickness
        total_T = pcb_T + bezel_T + hdr_block_T + pin_len + blob_T + boss_T + 2.0;
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*hole_x/2, sy*hole_y/2, 0])
                cylinder(d=hole_d, h=total_T, center=true);
        }

        // Recessed display window in bezel (front side)
        translate([0, 0, pcb_T/2 + bezel_T - win_depth/2 + 0.01])
            cube([win_L, win_W, win_depth + 0.02], center=true);
    }
}

lcd1602a_module();