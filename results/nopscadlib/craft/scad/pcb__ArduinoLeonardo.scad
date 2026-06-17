$fn = 64;

// Board dimensions (requested)
pcb_length = 68.58;
pcb_width  = 53.34;
pcb_thickness = 1.6;

// Small overlap to guarantee watertight unions
eps = 0.2;

// ---------- Helpers ----------
module rounded_rect_prism(l, w, h, r) {
    // Rounded rectangle prism using hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r), 0])
                cylinder(r=r, h=h, center=true);
    }
}

module pin_header_row(n=20, pitch=2.54, pin_w=0.7, pin_h=3.0, base_h=2.5, base_w=5.0) {
    // One connected solid: plastic base + pins
    union() {
        // Base
        cube([n*pitch, base_w, base_h], center=true);

        // Pins (slightly embedded into base)
        for (i = [0:n-1]) {
            translate([-(n-1)*pitch/2 + i*pitch, 0, -(base_h/2) - pin_h/2 + eps])
                cube([pin_w, pin_w, pin_h], center=true);
        }
    }
}

module usb_micro_port(port_w=7.5, port_d=6.0, port_h=2.6) {
    // Simple USB micro-like block (connected to board by overlap)
    cube([port_w, port_d, port_h], center=true);
}

module chip(q_l=14, q_w=14, q_h=1.6) {
    cube([q_l, q_w, q_h], center=true);
}

module small_ic(l=10, w=6, h=1.4) {
    cube([l, w, h], center=true);
}

module capacitor(d=4.0, h=5.0) {
    cylinder(d=d, h=h, center=true);
}

module led_0603(l=1.6, w=0.8, h=0.6) {
    cube([l, w, h], center=true);
}

// ---------- Main Model ----------
module dev_board() {
    // Board corner radius (typical)
    corner_r = 3.0;

    // Mounting holes (typical dev board feature)
    hole_d = 3.2;
    hole_edge = 4.0; // distance from edges to hole center (formula-based placement)

    // Component heights
    comp_clear = eps; // overlap into PCB
    header_base_h = 2.5;
    header_pin_h  = 3.0;
    header_total_h = header_base_h + header_pin_h;

    usb_h = 2.6;
    usb_d = 6.0;
    usb_w = 7.5;

    mcu_h = 1.6;
    reg_h = 1.4;
    cap_h = 5.0;

    // Header geometry
    pitch = 2.54;
    n_pins = 20;
    header_len = n_pins * pitch;
    header_base_w = 5.0;

    // Header placement (two long headers along the length)
    header_y_offset = pcb_width/2 - header_base_w/2 - 3.0; // inset from edge

    // USB placement on one short edge
    usb_y = pcb_width/2 - usb_d/2 + eps; // slightly overlapping into board edge
    usb_x = 0;

    // MCU placement
    mcu_x = 0;
    mcu_y = 0;

    // Regulator / small IC near USB
    reg_x = pcb_length/2 - 14;
    reg_y = pcb_width/2 - 14;

    // Capacitor near regulator
    cap_x = reg_x - 10;
    cap_y = reg_y;

    // LEDs near opposite corner
    led_x = -(pcb_length/2 - 10);
    led_y = pcb_width/2 - 10;

    union() {
        // PCB with mounting holes (holes are voids but model remains one connected solid)
        color([0.0, 0.4, 0.2])
        difference() {
            rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_r);

            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(pcb_length/2 - hole_edge), sy*(pcb_width/2 - hole_edge), 0])
                    cylinder(d=hole_d, h=pcb_thickness + 2*eps, center=true);
            }
        }

        // USB port (connected via overlap into PCB top surface and edge)
        color([0.75, 0.75, 0.78])
        translate([usb_x, usb_y, pcb_thickness/2 + usb_h/2 - comp_clear])
            usb_micro_port(usb_w, usb_d, usb_h);

        // Two pin headers (connected via overlap into PCB)
        color([0.1, 0.1, 0.1])
        translate([0,  header_y_offset, pcb_thickness/2 + header_total_h/2 - comp_clear])
            pin_header_row(n=n_pins, pitch=pitch, pin_w=0.7, pin_h=header_pin_h, base_h=header_base_h, base_w=header_base_w);

        color([0.1, 0.1, 0.1])
        translate([0, -header_y_offset, pcb_thickness/2 + header_total_h/2 - comp_clear])
            pin_header_row(n=n_pins, pitch=pitch, pin_w=0.7, pin_h=header_pin_h, base_h=header_base_h, base_w=header_base_w);

        // Main MCU
        color([0.15, 0.15, 0.15])
        translate([mcu_x, mcu_y, pcb_thickness/2 + mcu_h/2 - comp_clear])
            chip(14, 14, mcu_h);

        // Small IC (regulator)
        color([0.18, 0.18, 0.18])
        translate([reg_x, reg_y, pcb_thickness/2 + reg_h/2 - comp_clear])
            small_ic(10, 6, reg_h);

        // Capacitor
        color([0.2, 0.2, 0.2])
        translate([cap_x, cap_y, pcb_thickness/2 + cap_h/2 - comp_clear])
            capacitor(4.0, cap_h);

        // A couple of LEDs
        color([0.9, 0.1, 0.1])
        translate([led_x, led_y, pcb_thickness/2 + 0.6/2 - comp_clear])
            led_0603(1.6, 0.8, 0.6);

        color([0.1, 0.6, 0.9])
        translate([led_x + 3.0, led_y, pcb_thickness/2 + 0.6/2 - comp_clear])
            led_0603(1.6, 0.8, 0.6);
    }
}

dev_board();