// 3D Printer Control Board (connected solid)
// Exact PCB size: 123.0mm x 100.0mm x 1.6mm

$fn = 64;

// Parameters
pcb_L = 123.0;
pcb_W = 100.0;
pcb_T = 1.6;

corner_R = 3.0;

hole_d = 3.2;
edge_margin = 5.0;

eps = 0.2;          // small overlap for watertight unions
cut_eps = 0.6;      // extra height for through-cuts

// ---------- Helpers ----------
module rounded_rect_prism(L, W, T, R) {
    // Rounded rectangle via hull of 4 cylinders, then extruded to thickness
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(r=R, h=T, center=true);
    }
}

module pcb_with_holes() {
    difference() {
        rounded_rect_prism(pcb_L, pcb_W, pcb_T, corner_R);

        // Mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(pcb_L/2 - edge_margin), sy*(pcb_W/2 - edge_margin), 0])
                cylinder(d=hole_d, h=pcb_T + cut_eps, center=true);
    }
}

// ---------- Board Features (all CONNECTED to PCB) ----------
module board_features() {
    // Place features on top surface with slight overlap into PCB
    z_top = pcb_T/2;

    union() {
        // Main MCU / SoC package
        mcu_L = 22; mcu_W = 22; mcu_H = 3.0;
        translate([0, 0, z_top + mcu_H/2 - eps])
            cube([mcu_L, mcu_W, mcu_H], center=true);

        // Driver heatsinks (3)
        hs_L = 14; hs_W = 14; hs_H = 6.0;
        hs_pitch = 18;
        for (i = [-1, 0, 1])
            translate([i*hs_pitch, pcb_W*0.18, z_top + hs_H/2 - eps])
                cube([hs_L, hs_W, hs_H], center=true);

        // Capacitors (cylinders)
        cap_d = 10; cap_h = 12;
        for (i = [-1, 1])
            translate([i*16, -pcb_W*0.18, z_top + cap_h/2 - eps])
                cylinder(d=cap_d, h=cap_h, center=true);

        // USB connector on left edge
        usb_L = 12; usb_W = 14; usb_H = 6;
        translate([-(pcb_L/2) + usb_L/2 - eps, -pcb_W*0.25, z_top + usb_H/2 - eps])
            cube([usb_L, usb_W, usb_H], center=true);

        // Power terminal block on right edge
        pwr_L = 14; pwr_W = 18; pwr_H = 12;
        translate([(pcb_L/2) - pwr_L/2 + eps, -pcb_W*0.20, z_top + pwr_H/2 - eps])
            cube([pwr_L, pwr_W, pwr_H], center=true);

        // Stepper motor headers (row) along top edge
        hdr_L = 10; hdr_W = 8; hdr_H = 9;
        hdr_count = 4;
        hdr_span = pcb_L * 0.55;
        hdr_pitch = hdr_span/(hdr_count-1);
        for (k = [0:hdr_count-1]) {
            xk = -hdr_span/2 + k*hdr_pitch;
            translate([xk, (pcb_W/2) - hdr_W/2 + eps, z_top + hdr_H/2 - eps])
                cube([hdr_L, hdr_W, hdr_H], center=true);
        }

        // Endstop / signal headers along bottom edge (smaller)
        sh_L = 8; sh_W = 6; sh_H = 7;
        sh_count = 5;
        sh_span = pcb_L * 0.65;
        sh_pitch = sh_span/(sh_count-1);
        for (k = [0:sh_count-1]) {
            xk = -sh_span/2 + k*sh_pitch;
            translate([xk, -(pcb_W/2) + sh_W/2 - eps, z_top + sh_H/2 - eps])
                cube([sh_L, sh_W, sh_H], center=true);
        }

        // Small regulator / ICs
        ic_L = 10; ic_W = 8; ic_H = 2.2;
        translate([pcb_L*0.22, 0, z_top + ic_H/2 - eps])
            cube([ic_L, ic_W, ic_H], center=true);

        translate([-pcb_L*0.22, 0, z_top + ic_H/2 - eps])
            cube([ic_L, ic_W, ic_H], center=true);

        // Bottom-side components (still connected) - flip below PCB
        z_bot = -pcb_T/2;

        // SD card slot (underside, near left)
        sd_L = 26; sd_W = 18; sd_H = 3.0;
        translate([-(pcb_L*0.25), -pcb_W*0.05, z_bot - sd_H/2 + eps])
            cube([sd_L, sd_W, sd_H], center=true);

        // Underside crystal / small can
        xtal_d = 8; xtal_h = 3.0;
        translate([pcb_L*0.10, pcb_W*0.05, z_bot - xtal_h/2 + eps])
            cylinder(d=xtal_d, h=xtal_h, center=true);
    }
}

// ---------- Final Model (ONE connected solid) ----------
union() {
    color([0.0, 0.4, 0.2]) pcb_with_holes();
    color([0.15, 0.15, 0.15]) board_features();
}