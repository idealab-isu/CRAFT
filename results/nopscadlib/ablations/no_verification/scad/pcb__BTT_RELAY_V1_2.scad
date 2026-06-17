$fn = 64;

// Mainboard overall dimensions (must match)
pcb_L = 80.4;
pcb_W = 36.3;
pcb_T = 1.5;

// Small overlap to guarantee connectivity between parts
ov = 0.25;

// Helper: rounded rectangle prism (centered)
module rounded_box(size=[10,10,2], r=1, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, x/2, y/2);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=rr)
                square([x-2*rr, y-2*rr], center=true);
}

// Helper: simple pin header block (centered)
module pin_header(cols=4, rows=1, pitch=2.54, body_h=6, body_w=5.5, body_l=12) {
    union() {
        // plastic body
        rounded_box([body_l, body_w, body_h], r=0.8, center=true);
        // pins (kept short; still connected to body)
        pin_r = 0.55;
        pin_h = 3.0;
        for (c=[0:cols-1])
            for (r=[0:rows-1]) {
                translate([
                    (c-(cols-1)/2)*pitch,
                    (r-(rows-1)/2)*pitch,
                    -body_h/2 - pin_h/2 + ov
                ])
                    cylinder(h=pin_h, r=pin_r, center=true);
            }
    }
}

// Helper: terminal block (centered)
module terminal_block(poles=2, pitch=5.08, body_h=10, body_w=12, body_l=12) {
    union() {
        rounded_box([body_l, body_w, body_h], r=1.2, center=true);
        // screw bumps
        bump_r = 2.0;
        bump_h = 1.5;
        for (i=[0:poles-1]) {
            translate([
                (i-(poles-1)/2)*pitch,
                0,
                body_h/2 + bump_h/2 - ov
            ])
                cylinder(h=bump_h, r=bump_r, center=true);
        }
    }
}

// Helper: USB-like connector (centered)
module usb_connector(body_l=14, body_w=12, body_h=6) {
    union() {
        rounded_box([body_l, body_w, body_h], r=1.0, center=true);
        // metal shell lip
        lip_t = 1.2;
        translate([body_l/2 - lip_t/2 + ov, 0, 0])
            rounded_box([lip_t, body_w-1.5, body_h-1.0], r=0.6, center=true);
    }
}

// Helper: stepper driver heatsink-ish block (centered)
module heatsink_block(l=14, w=14, h=6, fins=6) {
    union() {
        rounded_box([l, w, h], r=1.0, center=true);
        fin_t = 0.9;
        fin_gap = (l - fins*fin_t)/(fins+1);
        for (i=[0:fins-1]) {
            x = -l/2 + fin_gap*(i+1) + fin_t*(i+0.5);
            translate([x, 0, h/2 + 1.2/2 - ov])
                cube([fin_t, w-2, 1.2], center=true);
        }
    }
}

// Main PCB with mounting holes and slight corner radius
module pcb() {
    hole_d = 3.2;
    edge_m = 4.0; // margin from edges to hole centers
    r_corner = 2.0;

    difference() {
        color([0.0, 0.4, 0.2])
            rounded_box([pcb_L, pcb_W, pcb_T], r=r_corner, center=true);

        // 4 mounting holes
        for (sx=[-1,1], sy=[-1,1]) {
            translate([
                sx*(pcb_L/2 - edge_m),
                sy*(pcb_W/2 - edge_m),
                0
            ])
                cylinder(h=pcb_T + 2, d=hole_d, center=true);
        }
    }
}

// Components placed on top; all overlap into PCB by ov to ensure one connected solid
module components() {
    top_z = pcb_T/2;

    union() {
        // Large terminal block on one long edge
        term_h = 10;
        term_w = 12;
        term_l = 22;
        translate([
            0,
            pcb_W/2 - term_w/2 + ov,
            top_z + term_h/2 - ov
        ])
            color([0.15,0.15,0.15])
                terminal_block(poles=3, pitch=5.08, body_h=term_h, body_w=term_w, body_l=term_l);

        // USB connector on opposite long edge, offset to one side
        usb_h = 6;
        usb_w = 12;
        usb_l = 14;
        translate([
            -pcb_L/2 + usb_l/2 - ov,
            -pcb_W/2 + usb_w/2 - ov,
            top_z + usb_h/2 - ov
        ])
            color([0.75,0.75,0.75])
                usb_connector(body_l=usb_l, body_w=usb_w, body_h=usb_h);

        // Two pin headers along the top edge
        hdr_h = 6;
        hdr_w = 5.5;
        hdr_l = 18;
        for (xpos=[-10, 18]) {
            translate([
                xpos,
                pcb_W/2 - hdr_w/2 + ov,
                top_z + hdr_h/2 - ov
            ])
                color([0.05,0.05,0.05])
                    pin_header(cols=6, rows=1, pitch=2.54, body_h=hdr_h, body_w=hdr_w, body_l=hdr_l);
        }

        // Three heatsink blocks (stepper drivers) in a row
        hs_h = 6;
        hs_w = 14;
        hs_l = 14;
        y_hs = 0;
        for (xpos=[-18, 0, 18]) {
            translate([
                xpos,
                y_hs,
                top_z + hs_h/2 - ov
            ])
                color([0.25,0.25,0.25])
                    heatsink_block(l=hs_l, w=hs_w, h=hs_h, fins=6);
        }

        // A couple of capacitors (cylinders) near one corner
        cap_r = 3.2;
        cap_h = 8;
        for (dx=[0, 8]) {
            translate([
                pcb_L/2 - 14 - dx,
                -pcb_W/2 + 10,
                top_z + cap_h/2 - ov
            ])
                color([0.1,0.1,0.1])
                    cylinder(h=cap_h, r=cap_r, center=true);
        }

        // A flat IC package
        ic_l = 16;
        ic_w = 16;
        ic_h = 2.2;
        translate([
            pcb_L/2 - 22,
            pcb_W/2 - 16,
            top_z + ic_h/2 - ov
        ])
            color([0.08,0.08,0.08])
                rounded_box([ic_l, ic_w, ic_h], r=1.0, center=true);
    }
}

// Final: one connected solid (PCB with holes + components fused to PCB)
union() {
    pcb();
    components();
}