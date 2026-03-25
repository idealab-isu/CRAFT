// Single-board computer (RPI3-like) - 85.0mm x 56.0mm x 1.4mm PCB with connected components
// One connected solid; all placements derived from dimensions (no arbitrary floating).

$fn = 48;

// Board parameters
length = 85.0;
width  = 56.0;
thickness = 1.4;

// Small overlap to guarantee manifold unions
overlap = 0.4;

// Helper: rounded rectangle prism (centered)
module rounded_box(size=[10,10,2], r=1, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r)
                square([x-2*r, y-2*r], center=true);
}

// Helper: place a part sitting on top of PCB, with slight overlap into PCB
module on_top(part_h) {
    translate([0,0, thickness/2 + part_h/2 - overlap])
        children();
}

// Helper: place a part sitting on bottom of PCB, with slight overlap into PCB
module on_bottom(part_h) {
    translate([0,0, -thickness/2 - part_h/2 + overlap])
        children();
}

// PCB with mounting holes (holes are cut, but board remains a single solid)
module pcb() {
    hole_d = 2.75;
    hole_r = hole_d/2;

    // Approximate RPi mounting hole pattern (derived from board size)
    // Keep formulas tied to board dimensions:
    edge_x = 3.5;
    edge_y = 3.5;

    xL = -length/2 + edge_x;
    xR =  length/2 - edge_x;
    yB = -width/2  + edge_y;
    yT =  width/2  - edge_y;

    difference() {
        color([0.0, 0.4, 0.2])
            rounded_box([length, width, thickness], r=3, center=true);

        // 4 mounting holes
        for (px = [xL, xR])
            for (py = [yB, yT])
                translate([px, py, 0])
                    cylinder(h=thickness + 2, r=hole_r, center=true);
    }
}

// Components (simple but recognizable), all connected to PCB via overlap
module components() {
    // Coordinate convention:
    // X along length (85), Y along width (56), Z thickness.

    // Keep a small margin from edges for connectors
    edge_margin = 1.5;

    // --- 40-pin GPIO header (top side) ---
    gpio_len = 51.0;
    gpio_w   = 5.5;
    gpio_h   = 8.5;

    // Place near one long edge (top edge in Y), offset from one end in X
    gpio_y =  width/2 - edge_margin - gpio_w/2;
    gpio_x = -length/2 + 10 + gpio_len/2; // derived: start 10mm from left edge

    color([0.1,0.1,0.1])
    translate([gpio_x, gpio_y, 0])
        on_top(gpio_h)
            rounded_box([gpio_len, gpio_w, gpio_h], r=0.8, center=true);

    // --- SoC chip (top side) ---
    soc_x = -length/2 + 34;
    soc_y = 0;
    soc_w = 14;
    soc_l = 14;
    soc_h = 2.2;

    color([0.15,0.15,0.15])
    translate([soc_x, soc_y, 0])
        on_top(soc_h)
            rounded_box([soc_l, soc_w, soc_h], r=1.0, center=true);

    // --- RAM chip (top side) ---
    ram_x = soc_x + soc_l/2 + 8;
    ram_y = soc_y;
    ram_l = 12;
    ram_w = 10;
    ram_h = 1.8;

    color([0.18,0.18,0.18])
    translate([ram_x, ram_y, 0])
        on_top(ram_h)
            rounded_box([ram_l, ram_w, ram_h], r=0.8, center=true);

    // --- USB stack (2x USB) on one short edge (right side in X) ---
    usb_w = 16.0;   // along Y
    usb_l = 17.0;   // along X (depth into board)
    usb_h = 15.0;

    // Position so outer face is near +X edge, connected by overlap into PCB
    usb_x = length/2 - edge_margin - usb_l/2;
    usb_y = -width/2 + 10 + usb_w/2;

    color([0.75,0.75,0.75])
    translate([usb_x, usb_y, 0])
        on_top(usb_h)
            rounded_box([usb_l, usb_w, usb_h], r=1.2, center=true);

    // Second USB above the first (stacked along Y)
    usb2_y = usb_y + usb_w + 2;
    color([0.75,0.75,0.75])
    translate([usb_x, usb2_y, 0])
        on_top(usb_h)
            rounded_box([usb_l, usb_w, usb_h], r=1.2, center=true);

    // --- Ethernet jack near USB (right edge) ---
    eth_w = 16.5;
    eth_l = 21.0;
    eth_h = 14.0;

    eth_x = length/2 - edge_margin - eth_l/2;
    eth_y = usb2_y + usb_w/2 + 2 + eth_w/2;

    color([0.7,0.7,0.7])
    translate([eth_x, eth_y, 0])
        on_top(eth_h)
            rounded_box([eth_l, eth_w, eth_h], r=1.2, center=true);

    // --- HDMI connector on bottom long edge (negative Y) ---
    hdmi_w = 14.0;  // along X
    hdmi_l = 11.5;  // along Y (depth)
    hdmi_h = 6.0;

    hdmi_y = -width/2 + edge_margin + hdmi_l/2;
    hdmi_x = -length/2 + 32;

    color([0.6,0.6,0.6])
    translate([hdmi_x, hdmi_y, 0])
        on_top(hdmi_h)
            rounded_box([hdmi_w, hdmi_l, hdmi_h], r=0.8, center=true);

    // --- Micro USB power connector on bottom edge (negative Y), left of HDMI ---
    pwr_w = 8.0;   // along X
    pwr_l = 7.0;   // along Y
    pwr_h = 4.0;

    pwr_y = -width/2 + edge_margin + pwr_l/2;
    pwr_x = hdmi_x - hdmi_w/2 - 10;

    color([0.65,0.65,0.65])
    translate([pwr_x, pwr_y, 0])
        on_top(pwr_h)
            rounded_box([pwr_w, pwr_l, pwr_h], r=0.7, center=true);

    // --- 3.5mm audio jack on bottom edge (negative Y), right of HDMI ---
    aud_w = 7.5;   // along X
    aud_l = 13.0;  // along Y
    aud_h = 6.5;

    aud_y = -width/2 + edge_margin + aud_l/2;
    aud_x = hdmi_x + hdmi_w/2 + 14;

    color([0.1,0.1,0.1])
    translate([aud_x, aud_y, 0])
        on_top(aud_h)
            rounded_box([aud_w, aud_l, aud_h], r=1.0, center=true);

    // --- Camera/Display ribbon connectors (top edge, small) ---
    rib_l = 16.0;
    rib_w = 5.0;
    rib_h = 2.5;

    rib_y = width/2 - edge_margin - rib_w/2;
    rib1_x = length/2 - 22;
    rib2_x = rib1_x - rib_l - 6;

    color([0.85,0.85,0.85])
    translate([rib1_x, rib_y - (gpio_w + 3), 0])
        on_top(rib_h)
            rounded_box([rib_l, rib_w, rib_h], r=0.6, center=true);

    color([0.85,0.85,0.85])
    translate([rib2_x, rib_y - (gpio_w + 3), 0])
        on_top(rib_h)
            rounded_box([rib_l, rib_w, rib_h], r=0.6, center=true);

    // --- MicroSD card slot (bottom side) ---
    sd_l = 18.0; // along X
    sd_w = 16.0; // along Y
    sd_h = 2.2;

    sd_x = -length/2 + 18;
    sd_y = -width/2 + 18;

    color([0.2,0.2,0.2])
    translate([sd_x, sd_y, 0])
        on_bottom(sd_h)
            rounded_box([sd_l, sd_w, sd_h], r=0.8, center=true);
}

// Assembly: one connected solid (union of PCB and components with overlaps)
module assembly() {
    union() {
        pcb();
        components();
    }
}

assembly();