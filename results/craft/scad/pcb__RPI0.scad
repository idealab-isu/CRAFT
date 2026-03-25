// Single-board computer (generic) 65.0mm x 30.0mm x 1.4mm PCB with connected components
// Fixed to ensure visible geometry and ONE connected solid (no floating parts)

$fn = 64;

// Parameters
length = 65.0;
width  = 30.0;
thickness = 1.4;

// Overlap to guarantee watertight union between parts
overlap = 0.25;

// Rounded rectangle prism (centered by default)
module rounded_box(size=[10,10,2], r=1, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, x/2 - 0.01, y/2 - 0.01);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true, convexity=10)
            offset(r=rr)
                square([max(0.01, x-2*rr), max(0.01, y-2*rr)], center=true);
}

// Place a part on top of PCB with slight overlap into PCB
module on_top(part_h) {
    translate([0, 0, thickness/2 + part_h/2 - overlap])
        children();
}

// Place a part on bottom of PCB with slight overlap into PCB
module on_bottom(part_h) {
    translate([0, 0, -thickness/2 - part_h/2 + overlap])
        children();
}

// Generic SBC geometry (single connected solid)
module SBC() {
    union() {
        // PCB
        rounded_box([length, width, thickness], r=2.0, center=true);

        // --- Top-side components (connected via on_top overlap) ---
        // Main SoC
        soc_l = 14; soc_w = 14; soc_h = 1.6;
        on_top(soc_h)
            rounded_box([soc_l, soc_w, soc_h], r=0.8, center=true);

        // RAM / secondary IC
        ram_l = 10; ram_w = 10; ram_h = 1.4;
        translate([-length*0.18, width*0.18, 0])
            on_top(ram_h)
                rounded_box([ram_l, ram_w, ram_h], r=0.6, center=true);

        // Power management IC
        pm_l = 8; pm_w = 6; pm_h = 1.2;
        translate([length*0.22, width*0.18, 0])
            on_top(pm_h)
                rounded_box([pm_l, pm_w, pm_h], r=0.5, center=true);

        // USB connector (near right edge, on top)
        usb_l = 8.0; usb_w = 7.5; usb_h = 3.2;
        translate([length/2 - usb_l/2, -width*0.18, 0])
            on_top(usb_h)
                rounded_box([usb_l, usb_w, usb_h], r=0.6, center=true);

        // HDMI connector (near right edge, on top)
        hdmi_l = 12.0; hdmi_w = 7.5; hdmi_h = 3.0;
        translate([length/2 - hdmi_l/2, width*0.18, 0])
            on_top(hdmi_h)
                rounded_box([hdmi_l, hdmi_w, hdmi_h], r=0.6, center=true);

        // Camera/Display FFC connector (near top edge)
        ffc_l = 16.0; ffc_w = 4.0; ffc_h = 2.0;
        translate([-length*0.18, width/2 - ffc_w/2, 0])
            on_top(ffc_h)
                rounded_box([ffc_l, ffc_w, ffc_h], r=0.4, center=true);

        // 40-pin header block (near bottom edge)
        hdr_l = 26.0; hdr_w = 5.5; hdr_h = 3.5;
        translate([-length*0.10, -width/2 + hdr_w/2, 0])
            on_top(hdr_h)
                rounded_box([hdr_l, hdr_w, hdr_h], r=0.6, center=true);

        // --- Bottom-side components (connected via on_bottom overlap) ---
        // MicroSD socket
        sd_l = 16.0; sd_w = 14.0; sd_h = 2.2;
        translate([-length*0.22, 0, 0])
            on_bottom(sd_h)
                rounded_box([sd_l, sd_w, sd_h], r=0.8, center=true);

        // Small bottom IC
        bic_l = 7.0; bic_w = 7.0; bic_h = 1.2;
        translate([length*0.20, -width*0.10, 0])
            on_bottom(bic_h)
                rounded_box([bic_l, bic_w, bic_h], r=0.6, center=true);
    }
}

SBC();