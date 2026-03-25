// Microcontroller development board (Arduino Leonardo-style approximation)
// Target PCB size: 68.58mm x 53.34mm x 1.6mm
// Structural fixes:
// - Ensure header pins are NOT floating: extend pins into PCB and overlap 1-2mm
// - Ensure all parts are in a single union() and physically intersect

length = 68.58;     // X
width  = 53.34;     // Y
thickness = 1.6;    // Z

$fn = 64;

// Overlap to guarantee manifold unions (1-2mm as required)
overlap = 1.2;

// ---------- Helpers ----------
module rounded_rect_2d(l, w, r) {
    rr = min(r, min(l, w)/2 - 0.01);
    offset(r=rr) square([l - 2*rr, w - 2*rr], center=true);
}

module pcb_solid(l=length, w=width, t=thickness, corner_r=2.0) {
    linear_extrude(height=t, center=true, convexity=10)
        rounded_rect_2d(l, w, corner_r);
}

module chip_qfp(body=[10,10,1.2], lead=0.8, lead_t=0.35) {
    union() {
        cube(body, center=true);
        translate([0,0,-(body[2]/2 + lead_t/2 - overlap)])
            cube([body[0] + 2*lead, body[1] + 2*lead, lead_t], center=true);
    }
}

module ic_soic(body=[9,6,1.2], lead=0.6, lead_t=0.35) {
    union() {
        cube(body, center=true);
        translate([0,0,-(body[2]/2 + lead_t/2 - overlap)])
            cube([body[0] + 2*lead, body[1] + 2*lead, lead_t], center=true);
    }
}

module header_row(pins=10, pitch=2.54, pin=[0.7,0.7,6], base_h=2.5) {
    // One-piece header: plastic base + pins fused
    row_l = (pins-1)*pitch + pin[0];
    union() {
        cube([row_l, 2.6, base_h], center=true);
        for (i=[0:pins-1]) {
            x = -row_l/2 + pin[0]/2 + i*pitch;
            translate([x, 0, -(base_h/2 + pin[2]/2 - overlap)])
                cube(pin, center=true);
        }
    }
}

module usb_micro_b(conn=[7.5,7.0,3.0], tongue=[5.5,1.0,1.0]) {
    union() {
        cube(conn, center=true);
        translate([0, 0, -(conn[2]/2 - tongue[2]/2 - overlap)])
            cube(tongue, center=true);
    }
}

module barrel_jack(body=[14,9,11], nose=[6,7,7]) {
    union() {
        cube(body, center=true);
        translate([body[0]/2 + nose[0]/2 - overlap, 0, -(body[2]/2 - nose[2]/2 - overlap)])
            cube(nose, center=true);
    }
}

module reset_button(body=[6,6,2.5], plunger=[3.2,3.2,1.2]) {
    union() {
        cube(body, center=true);
        translate([0,0, body[2]/2 + plunger[2]/2 - overlap])
            cube(plunger, center=true);
    }
}

module led_0603(size=[1.6,0.8,0.6]) {
    cube(size, center=true);
}

// ---------- Assembly ----------
module assembly() {
    pcb_top = thickness/2;

    // Ensure header pins actually intersect the PCB (fix floating/gap):
    // Place header base on top of PCB with overlap, and extend pins downward so
    // their top is inside the header base and their bottom penetrates the PCB.
    header_base_h = 2.5;
    header_pin = [0.7,0.7,6];

    // Z center for header base: bottom of base goes into PCB by 'overlap'
    header_base_zc = pcb_top + header_base_h/2 - overlap;

    // Z center for pins: make pin top penetrate into base by 'overlap'
    // pin_top_z = (base_bottom_z) + overlap
    // base_bottom_z = header_base_zc - header_base_h/2
    // pin_center_z = pin_top_z - pin_h/2
    base_bottom_z = header_base_zc - header_base_h/2;
    pin_zc = (base_bottom_z + overlap) - header_pin[2]/2;

    union() {
        // PCB
        color([0.0, 0.4, 0.2]) pcb_solid();

        // --- Major components (approximate Leonardo-style layout) ---

        // USB connector on left edge, centered in Y
        usb = [7.5, 7.0, 3.0];
        usb_zc = pcb_top + usb[2]/2 - overlap;
        usb_xc = -length/2 + usb[0]/2 - overlap;
        translate([usb_xc, 0, usb_zc])
            color([0.75,0.75,0.75]) usb_micro_b(conn=usb, tongue=[5.5,1.0,1.0]);

        // DC barrel jack on right edge, slightly above center in Y
        jack_body = [14, 9, 11];
        jack_zc = pcb_top + jack_body[2]/2 - overlap;
        jack_xc = length/2 - jack_body[0]/2 + overlap;
        jack_yc = width*0.18;
        translate([jack_xc, jack_yc, jack_zc])
            color([0.1,0.1,0.1]) barrel_jack(body=jack_body, nose=[6,7,7]);

        // Main MCU (ATmega32u4-ish) near center-left
        mcu_body = [10,10,1.2];
        mcu_zc = pcb_top + mcu_body[2]/2 - overlap;
        mcu_xc = -length*0.10;
        mcu_yc = -width*0.05;
        translate([mcu_xc, mcu_yc, mcu_zc])
            color([0.15,0.15,0.15]) chip_qfp(body=mcu_body, lead=0.9, lead_t=0.35);

        // USB interface / regulator ICs (SOIC) near USB side
        soic1 = [9,6,1.2];
        soic_zc = pcb_top + soic1[2]/2 - overlap;
        translate([-length*0.28, -width*0.18, soic_zc])
            color([0.15,0.15,0.15]) ic_soic(body=soic1, lead=0.7, lead_t=0.35);

        translate([-length*0.22, width*0.18, soic_zc])
            color([0.15,0.15,0.15]) ic_soic(body=[8,5,1.1], lead=0.6, lead_t=0.35);

        // Crystal/resonator near MCU
        xtal = [7,3,1.6];
        xtal_zc = pcb_top + xtal[2]/2 - overlap;
        translate([mcu_xc + 10, mcu_yc + 8, xtal_zc])
            color([0.7,0.7,0.7]) cube(xtal, center=true);

        // Reset button near top-left quadrant
        btn = [6,6,2.5];
        btn_zc = pcb_top + btn[2]/2 - overlap;
        translate([-length*0.30, width*0.30, btn_zc])
            color([0.2,0.2,0.2]) reset_button(body=btn, plunger=[3.2,3.2,1.2]);

        // Power LED near USB
        led = [1.6,0.8,0.6];
        led_zc = pcb_top + led[2]/2 - overlap;
        translate([usb_xc + usb[0]*0.9, -width*0.22, led_zc])
            color([0.9,0.1,0.1]) led_0603(size=led);

        // --- Headers (approximate Arduino footprint) ---
        // Long header along top edge (digital pins)
        top_pins = 18;
        top_pitch = 2.54;
        top_row_l = (top_pins-1)*top_pitch + header_pin[0];
        top_yc = width/2 - 2.6/2 + overlap;

        // Base (fused to PCB)
        translate([0, top_yc, header_base_zc])
            color([0.05,0.05,0.05]) cube([top_row_l, 2.6, header_base_h], center=true);

        // Pins (explicitly placed so they penetrate PCB and overlap into base)
        for (i=[0:top_pins-1]) {
            x = -top_row_l/2 + header_pin[0]/2 + i*top_pitch;
            translate([x, top_yc, pin_zc])
                color([0.05,0.05,0.05]) cube(header_pin, center=true);
        }

        // Long header along bottom edge (analog/power)
        bot_pins = 16;
        bot_pitch = 2.54;
        bot_row_l = (bot_pins-1)*bot_pitch + header_pin[0];
        bot_yc = -width/2 + 2.6/2 - overlap;

        translate([0, bot_yc, header_base_zc])
            color([0.05,0.05,0.05]) cube([bot_row_l, 2.6, header_base_h], center=true);

        for (i=[0:bot_pins-1]) {
            x = -bot_row_l/2 + header_pin[0]/2 + i*bot_pitch;
            translate([x, bot_yc, pin_zc])
                color([0.05,0.05,0.05]) cube(header_pin, center=true);
        }

        // 2x3 ICSP header near center-right (ensure pins overlap into base and PCB)
        icsp_base = [7.62, 5.08, 2.5];
        icsp_pin = [0.7,0.7,6];

        icsp_base_zc = pcb_top + icsp_base[2]/2 - overlap;
        icsp_base_bottom_z = icsp_base_zc - icsp_base[2]/2;
        icsp_pin_zc = (icsp_base_bottom_z + overlap) - icsp_pin[2]/2;

        icsp_xc = length*0.18;
        icsp_yc = -width*0.02;

        translate([icsp_xc, icsp_yc, icsp_base_zc])
            color([0.05,0.05,0.05]) cube(icsp_base, center=true);

        for (ix=[-1:1]) for (iy=[-0.5,0.5]) {
            translate([icsp_xc + ix*2.54, icsp_yc + iy*2.54, icsp_pin_zc])
                color([0.8,0.8,0.8]) cube(icsp_pin, center=true);
        }

        // A few capacitors as small blocks (fused)
        cap1 = [3.2,1.6,1.6];
        cap_zc = pcb_top + cap1[2]/2 - overlap;
        translate([length*0.05, width*0.22, cap_zc])
            color([0.75,0.6,0.2]) cube(cap1, center=true);
        translate([length*0.12, width*0.18, cap_zc])
            color([0.75,0.6,0.2]) cube([2.0,1.2,1.2], center=true);
        translate([length*0.22, -width*0.22, cap_zc])
            color([0.75,0.6,0.2]) cube([3.2,1.6,1.6], center=true);
    }
}

assembly();