$fn = 48;

// Board dimensions (must match request)
width_mm     = 33.8;   // X
length_mm    = 37.5;   // Y
thickness_mm = 1.6;    // Z

// Small overlap to guarantee one connected solid
overlap = 0.25;

// ---------- Helpers ----------
module rounded_rect_prism(size=[10,10,1], r=1, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r)
                square([x-2*r, y-2*r], center=true);
}

module pin_row(n=4, pitch=2.54, pin=[0.7,0.7,3.0]) {
    for (i=[0:n-1]) {
        translate([(i-(n-1)/2)*pitch, 0, 0])
            cube(pin, center=true);
    }
}

// ---------- Main PCB ----------
module pcb_board() {
    // Slightly rounded PCB with mounting holes (holes are cut, but board remains solid)
    corner_r = 2.0;
    hole_d   = 3.0;
    hole_off = 3.2; // from edges

    difference() {
        color([0.0, 0.4, 0.2])
            rounded_rect_prism([width_mm, length_mm, thickness_mm], r=corner_r, center=true);

        // 4 mounting holes
        for (sx=[-1,1], sy=[-1,1]) {
            translate([ sx*(width_mm/2 - hole_off),
                        sy*(length_mm/2 - hole_off),
                        0 ])
                cylinder(d=hole_d, h=thickness_mm + 2, center=true);
        }
    }
}

// ---------- Components (all connected to PCB via overlap) ----------
module usb_connector() {
    // USB-B-ish block on one edge
    body = [12.0, 10.0, 6.0]; // X,Y,Z
    // Place so it protrudes beyond +Y edge, sitting on top of PCB
    translate([0,
               length_mm/2 + body[1]/2 - overlap,
               thickness_mm/2 + body[2]/2 - overlap])
        cube(body, center=true);
}

module power_terminal() {
    // 2-pin screw terminal near -Y edge
    body = [10.0, 8.0, 7.0];
    translate([0,
               -length_mm/2 - body[1]/2 + overlap,
               thickness_mm/2 + body[2]/2 - overlap])
        cube(body, center=true);
}

module stepper_headers() {
    // Two 2x4-ish header blocks along +X edge
    hdr = [6.0, 10.0, 5.0];

    for (ypos = [-8.0, 8.0]) {
        translate([ width_mm/2 + hdr[0]/2 - overlap,
                    ypos,
                    thickness_mm/2 + hdr[2]/2 - overlap ])
            cube(hdr, center=true);
    }
}

module endstop_headers() {
    // Small pin headers along -X edge
    hdr = [5.0, 12.0, 4.0];
    translate([ -width_mm/2 - hdr[0]/2 + overlap,
                0,
                thickness_mm/2 + hdr[2]/2 - overlap ])
        cube(hdr, center=true);
}

module mcu_chip() {
    // Central MCU package
    chip = [14.0, 14.0, 2.2];
    translate([0, 0, thickness_mm/2 + chip[2]/2 - overlap])
        cube(chip, center=true);

    // Simple "pins" as a skirt to look more like an IC (still connected)
    pin_h = 1.2;
    pin_t = 0.8;
    // North/South pin strips
    for (sy=[-1,1]) {
        translate([0,
                   sy*(chip[1]/2 + pin_t/2 - overlap),
                   thickness_mm/2 + pin_h/2 - overlap])
            cube([chip[0] + 2.0, pin_t, pin_h], center=true);
    }
    // East/West pin strips
    for (sx=[-1,1]) {
        translate([sx*(chip[0]/2 + pin_t/2 - overlap),
                   0,
                   thickness_mm/2 + pin_h/2 - overlap])
            cube([pin_t, chip[1] + 2.0, pin_h], center=true);
    }
}

module capacitors() {
    // A few cylindrical caps near power area
    cap_d = 5.0;
    cap_h = 6.0;

    for (p = [[-10, -10], [10, -10], [-10, 10]]) {
        translate([p[0], p[1], thickness_mm/2 + cap_h/2 - overlap])
            cylinder(d=cap_d, h=cap_h, center=true);
    }
}

module board_assembly() {
    union() {
        pcb_board();

        // Components (all placed with formulas relative to board edges)
        color("DimGray") usb_connector();
        color("DimGray") power_terminal();
        color("DimGray") stepper_headers();
        color("DimGray") endstop_headers();
        color([0.15,0.15,0.15]) mcu_chip();
        color([0.2,0.2,0.2]) capacitors();
    }
}

board_assembly();