$fn = 64;

// Target PCB dimensions (mm)
pcb_length = 85.0;
pcb_width  = 56.0;
pcb_thickness = 1.4;

// Detail parameters (kept small and connected)
corner_r = 3.0;          // rounded corner radius
overlap = 0.2;           // small overlap to guarantee connectivity
mask = 0.01;             // tiny offset to avoid coplanar artifacts

// Component heights (above PCB)
chip_h = 1.2;
usb_h  = 6.0;
eth_h  = 7.5;
hdmi_h = 4.0;
jack_h = 6.5;
gpio_h = 8.5;

// Helper: rounded rectangle prism centered at origin
module rounded_rect_prism(L, W, H, R) {
    // Ensure R is valid
    r = min(R, min(L, W)/2 - 0.01);
    linear_extrude(height=H, center=true)
        offset(r=r)
            square([L - 2*r, W - 2*r], center=true);
}

// Helper: place a part so it sits on top of PCB (and overlaps slightly into it)
module on_top(part_h) {
    translate([0, 0, pcb_thickness/2 + part_h/2 - overlap])
        children();
}

// Main model: one connected solid (union of PCB + components)
module single_board_computer() {
    union() {
        // PCB body
        color([0.0, 0.4, 0.2])
            rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_r);

        // Mounting hole pads (solid bosses; no holes to keep one solid)
        pad_d = 6.0;
        pad_h = 0.6;
        hole_inset_x = 3.5;
        hole_inset_y = 3.5;

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(pcb_length/2 - hole_inset_x),
                sy*(pcb_width/2  - hole_inset_y),
                pcb_thickness/2 + pad_h/2 - overlap
            ])
            color([0.85, 0.75, 0.2])
                cylinder(d=pad_d, h=pad_h, center=true);
        }

        // Main SoC chip (center-ish)
        chip1_l = 14; chip1_w = 14;
        translate([ -pcb_length*0.08, 0, 0 ])
            on_top(chip_h)
                color([0.15, 0.15, 0.15])
                    cube([chip1_l, chip1_w, chip_h], center=true);

        // RAM chip
        chip2_l = 12; chip2_w = 10; chip2_h = 1.1;
        translate([ pcb_length*0.10, pcb_width*0.10, 0 ])
            on_top(chip2_h)
                color([0.18, 0.18, 0.18])
                    cube([chip2_l, chip2_w, chip2_h], center=true);

        // Small power/regulator block
        reg_l = 8; reg_w = 6; reg_h = 1.4;
        translate([ -pcb_length*0.22, -pcb_width*0.18, 0 ])
            on_top(reg_h)
                color([0.12, 0.12, 0.12])
                    cube([reg_l, reg_w, reg_h], center=true);

        // GPIO header (pin block) along top edge (y+)
        gpio_l = 52; gpio_w = 5.5;
        translate([ 0, pcb_width/2 - gpio_w/2 - 2.0, 0 ])
            on_top(gpio_h)
                color([0.05, 0.05, 0.05])
                    cube([gpio_l, gpio_w, gpio_h], center=true);

        // Side connectors along right edge (x+): USB + Ethernet blocks
        // Ethernet (larger)
        eth_l = 16; eth_w = 21;
        translate([ pcb_length/2 - eth_l/2 + mask, pcb_width*0.18, 0 ])
            on_top(eth_h)
                color([0.75, 0.75, 0.75])
                    cube([eth_l, eth_w, eth_h], center=true);

        // Two USB ports (stacked-ish)
        usb_l = 14; usb_w = 15;
        for (yy = [ -pcb_width*0.10, -pcb_width*0.32 ]) {
            translate([ pcb_length/2 - usb_l/2 + mask, yy, 0 ])
                on_top(usb_h)
                    color([0.78, 0.78, 0.78])
                        cube([usb_l, usb_w, usb_h], center=true);
        }

        // Bottom edge connectors (y-): HDMI + audio jack
        // HDMI
        hdmi_l = 15; hdmi_w = 11;
        translate([ pcb_length*0.05, -pcb_width/2 + hdmi_w/2 - mask, 0 ])
            on_top(hdmi_h)
                color([0.65, 0.65, 0.65])
                    cube([hdmi_l, hdmi_w, hdmi_h], center=true);

        // Audio jack
        jack_l = 14; jack_w = 12;
        translate([ -pcb_length*0.22, -pcb_width/2 + jack_w/2 - mask, 0 ])
            on_top(jack_h)
                color([0.10, 0.10, 0.10])
                    cube([jack_l, jack_w, jack_h], center=true);

        // Camera/Display connector (small) near left edge (x-)
        ffc_l = 18; ffc_w = 6; ffc_h = 2.5;
        translate([ -pcb_length/2 + ffc_l/2 - mask, pcb_width*0.28, 0 ])
            on_top(ffc_h)
                color([0.85, 0.85, 0.85])
                    cube([ffc_l, ffc_w, ffc_h], center=true);

        // Micro-USB / USB-C power connector near bottom-left edge
        pwr_l = 9; pwr_w = 7; pwr_h = 3.2;
        translate([ -pcb_length*0.40, -pcb_width/2 + pwr_w/2 - mask, 0 ])
            on_top(pwr_h)
                color([0.70, 0.70, 0.70])
                    cube([pwr_l, pwr_w, pwr_h], center=true);
    }
}

single_board_computer();