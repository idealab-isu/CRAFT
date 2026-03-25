$fn = 64;

// Board dimensions (requested)
width_mm     = 102.0;
height_mm    = 90.25;
thickness_mm = 1.6;

// Small overlap to guarantee watertight unions
ov = 0.2;

// ---------- Helpers ----------
module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
    // size = [x,y,z]
    x = size[0]; y = size[1]; z = size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r)
                square([x-2*r, y-2*r], center=true);
}

module chip_qfp(body=[14,14,1.2], lead_len=1.2, lead_w=0.5, lead_h=0.35) {
    // Simple QFP-like package: body + 4 lead bars (all connected)
    union() {
        rounded_rect_prism([body[0], body[1], body[2]], r=1.0, center=true);

        // Leads on +X / -X
        for (sx = [-1, 1]) {
            translate([sx*(body[0]/2 + lead_len/2 - ov), 0, -(body[2]/2) + lead_h/2 - ov])
                cube([lead_len, body[1]*0.85, lead_h], center=true);
        }
        // Leads on +Y / -Y
        for (sy = [-1, 1]) {
            translate([0, sy*(body[1]/2 + lead_len/2 - ov), -(body[2]/2) + lead_h/2 - ov])
                cube([body[0]*0.85, lead_len, lead_h], center=true);
        }
    }
}

module connector_block(body=[12,10,8], lip=[12,2,2]) {
    // Generic connector: main block + small lip (connected)
    union() {
        cube(body, center=true);
        translate([0, -(body[1]/2 + lip[1]/2 - ov), -(body[2]/2) + lip[2]/2 - ov])
            cube(lip, center=true);
    }
}

module usb_like(body=[14,12,6], tongue=[10,8,2]) {
    // Simple USB-like connector: shell + inner tongue (connected)
    union() {
        cube(body, center=true);
        translate([0, body[1]/2 - tongue[1]/2 - 1.0, -(body[2]/2) + tongue[2]/2 - ov])
            cube(tongue, center=true);
    }
}

module barrel_jack(body=[14,12,10], pin=[4,4,4]) {
    // Simple power jack: block + pin nub (connected)
    union() {
        cube(body, center=true);
        translate([0, body[1]/2 + pin[1]/2 - ov, -(body[2]/2) + pin[2]/2 - ov])
            cube(pin, center=true);
    }
}

module heatsink_block(size=[14,14,6], fin_w=1.2, gap=1.2) {
    // Heatsink: base + fins (all connected)
    union() {
        cube(size, center=true);
        // Fins along X
        fin_h = size[2]*0.9;
        n = floor((size[0] - fin_w) / (fin_w + gap));
        for (i = [0:n]) {
            x = -size[0]/2 + fin_w/2 + i*(fin_w+gap);
            translate([x, 0, size[2]/2 + fin_h/2 - ov])
                cube([fin_w, size[1]*0.9, fin_h], center=true);
        }
    }
}

module mounting_hole_boss(hole_d=3.2, boss_d=6.8, boss_h=2.2) {
    // Boss is part of the solid; hole is subtracted later
    difference() {
        cylinder(d=boss_d, h=boss_h, center=true);
        cylinder(d=hole_d, h=boss_h + 2, center=true);
    }
}

// ---------- Mainboard ----------
module mainboard_102x90p25x1p6() {
    w = width_mm;
    h = height_mm;
    t = thickness_mm;

    // PCB corner radius (visual)
    pcb_r = 3.0;

    // Mounting hole pattern (approximate, symmetric)
    edge_x = 6.0;
    edge_y = 6.0;
    hole_d = 3.2;
    boss_d = 7.0;
    boss_h = 2.2;

    // Component placement Z reference: top of PCB
    z_top = t/2;

    // Build as one connected solid: PCB + components + bosses, then subtract holes
    difference() {
        union() {
            // PCB
            color([0.0, 0.4, 0.2])
                rounded_rect_prism([w, h, t], r=pcb_r, center=true);

            // Mounting bosses (connected to PCB with slight overlap)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(w/2 - edge_x), sy*(h/2 - edge_y), z_top + boss_h/2 - ov])
                    mounting_hole_boss(hole_d=hole_d, boss_d=boss_d, boss_h=boss_h);
            }

            // --- Top-side components (all connected to PCB) ---
            // Central MCU (QFP)
            translate([0, 0, z_top + 1.2/2 - ov])
                color([0.15,0.15,0.15])
                    chip_qfp(body=[16,16,1.2], lead_len=1.4, lead_w=0.5, lead_h=0.35);

            // Stepper driver heatsinks (3 blocks)
            drv_sz = [14,14,6];
            drv_y = -h*0.18;
            drv_x_spacing = 18;
            for (i = [-1, 0, 1]) {
                translate([i*drv_x_spacing, drv_y, z_top + drv_sz[2]/2 - ov])
                    color([0.6,0.6,0.6])
                        heatsink_block(size=drv_sz, fin_w=1.2, gap=1.2);
            }

            // USB connector on one edge (+Y)
            usb_body = [16, 14, 7];
            translate([0, h/2 - usb_body[1]/2 + ov, z_top + usb_body[2]/2 - ov])
                color([0.75,0.75,0.78])
                    usb_like(body=usb_body, tongue=[11,9,2]);

            // Power barrel jack near corner (+Y, +X)
            pwr_body = [16, 14, 11];
            translate([w/2 - pwr_body[0]/2 - 10, h/2 - pwr_body[1]/2 + ov, z_top + pwr_body[2]/2 - ov])
                color([0.1,0.1,0.1])
                    barrel_jack(body=pwr_body, pin=[5,5,4]);

            // Terminal blocks along -Y edge (2 blocks)
            term_body = [18, 12, 10];
            for (xpos = [-w*0.22, w*0.22]) {
                translate([xpos, -(h/2 - term_body[1]/2 + ov), z_top + term_body[2]/2 - ov])
                    color([0.0,0.35,0.55])
                        connector_block(body=term_body, lip=[term_body[0], 2.5, 2.2]);
            }

            // Pin header strips along +X edge (two long low blocks)
            hdr1 = [6, 40, 6];
            hdr2 = [6, 28, 6];
            translate([w/2 - hdr1[0]/2 + ov, -h*0.05, z_top + hdr1[2]/2 - ov])
                color([0.05,0.05,0.05])
                    cube(hdr1, center=true);
            translate([w/2 - hdr2[0]/2 + ov,  h*0.28, z_top + hdr2[2]/2 - ov])
                color([0.05,0.05,0.05])
                    cube(hdr2, center=true);

            // Small capacitors (cylinders) near power area
            cap_d = 8; cap_h = 12;
            for (p = [[w*0.25, h*0.18], [w*0.18, h*0.10]]) {
                translate([p[0], p[1], z_top + cap_h/2 - ov])
                    color([0.1,0.1,0.1])
                        cylinder(d=cap_d, h=cap_h, center=true);
            }

            // A couple of ICs (rectangular)
            ic1 = [10, 8, 1.6];
            ic2 = [12, 10, 1.8];
            translate([-w*0.22, h*0.18, z_top + ic1[2]/2 - ov])
                color([0.12,0.12,0.12])
                    rounded_rect_prism(ic1, r=0.8, center=true);
            translate([ -w*0.05, h*0.22, z_top + ic2[2]/2 - ov])
                color([0.12,0.12,0.12])
                    rounded_rect_prism(ic2, r=1.0, center=true);
        }

        // Subtract through-holes (mounting holes) through PCB + bosses
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(w/2 - edge_x), sy*(h/2 - edge_y), 0])
                cylinder(d=hole_d, h=t + boss_h + 6, center=true);
        }
    }
}

// Assembly
mainboard_102x90p25x1p6();