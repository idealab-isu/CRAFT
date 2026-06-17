$fn = 64;

// Parameters (target PCB size)
pcb_L = 110.0;   // X
pcb_W = 85.0;    // Y
pcb_T = 1.6;     // Z

// Small overlap to guarantee watertight unions
ov = 0.25;

// ---------- Helper modules ----------
module rounded_plate(L, W, T, r) {
    // Rounded rectangle prism via hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r), sy*(W/2 - r), 0])
                cylinder(r=r, h=T, center=true);
    }
}

module box_on_top(size_xyz, pos_xy) {
    // Places a box so its bottom slightly overlaps into PCB top surface
    translate([pos_xy[0], pos_xy[1], pcb_T/2 + size_xyz[2]/2 - ov])
        cube(size_xyz, center=true);
}

module cyl_on_top(r, h, pos_xy) {
    translate([pos_xy[0], pos_xy[1], pcb_T/2 + h/2 - ov])
        cylinder(r=r, h=h, center=true);
}

// ---------- Mainboard model ----------
module mainboard() {
    // Board outline + mounting holes (holes are subtracted, but model remains one connected solid)
    difference() {
        union() {
            // PCB
            color([0.0, 0.4, 0.2])
                rounded_plate(pcb_L, pcb_W, pcb_T, r=3);

            // Major components/connectors (all connected to PCB top)
            // USB-B style connector near left edge
            box_on_top([14, 16, 11], [-(pcb_L/2 - 7), 0]);

            // Power terminal block near top-left
            box_on_top([18, 12, 12], [-(pcb_L/2 - 12), (pcb_W/2 - 10)]);

            // Stepper driver heatsink blocks (row)
            for (i = [0:3]) {
                x = -10 + i*18;
                y = (pcb_W/2 - 22);
                box_on_top([14, 14, 8], [x, y]);
            }

            // MCU / main IC
            box_on_top([22, 22, 3], [10, 0]);

            // Capacitors cluster (cylinders)
            for (i = [0:2]) {
                x = (pcb_L/2 - 22) - i*10;
                y = -(pcb_W/2 - 18);
                cyl_on_top(4, 10, [x, y]);
            }

            // Long pin header along right edge
            box_on_top([6, 60, 8], [(pcb_L/2 - 3), 0]);

            // Endstop/aux headers along bottom edge
            for (i = [0:4]) {
                x = -30 + i*15;
                y = -(pcb_W/2 - 4);
                box_on_top([10, 6, 7], [x, y]);
            }

            // Small components scatter (low profile)
            for (i = [0:5]) {
                x = -40 + i*16;
                y = -10 + (i%2)*12;
                box_on_top([8, 6, 2], [x, y]);
            }
        }

        // Mounting holes (typical 4-corner pattern)
        hole_r = 1.7;          // ~3.4mm dia
        edge_x = 6.0;
        edge_y = 6.0;

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_L/2 - edge_x), sy*(pcb_W/2 - edge_y), 0])
                cylinder(r=hole_r, h=pcb_T + 2*ov, center=true);
        }
    }
}

// Final Output
mainboard();