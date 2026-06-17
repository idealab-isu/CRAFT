$fn = 64;

// =====================
// Parameters (mm)
// =====================
pcb_length = 123.0;
pcb_width  = 100.0;
pcb_thickness = 1.6;

corner_radius = 5.0;

mount_hole_diameter = 3.2;
mount_hole_edge_offset = 6.0;

mask_thickness = 0.05;
silkscreen_thickness = 0.03;

// Small overlap to guarantee watertight unions
overlap = 0.25;

// =====================
// Helpers
// =====================
module rounded_rect_prism(L, W, H, R) {
    // Rounded rectangle using hull of 4 cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(r=R, h=H, center=true);
        }
    }
}

module mount_hole_cutter() {
    cylinder(r=mount_hole_diameter/2, h=pcb_thickness + 2, center=true);
}

module pcb_board() {
    difference() {
        rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_radius);

        // 4 mounting holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_length/2 - mount_hole_edge_offset),
                       sy*(pcb_width/2  - mount_hole_edge_offset),
                       0])
                mount_hole_cutter();
        }
    }
}

// Thin cosmetic layers (kept connected via overlap)
module solder_mask() {
    union() {
        translate([0, 0, pcb_thickness/2 + mask_thickness/2 - overlap])
            cube([pcb_length, pcb_width, mask_thickness], center=true);

        translate([0, 0, -pcb_thickness/2 - mask_thickness/2 + overlap])
            cube([pcb_length, pcb_width, mask_thickness], center=true);
    }
}

module silkscreen() {
    translate([0, 0, pcb_thickness/2 + mask_thickness + silkscreen_thickness/2 - overlap])
        cube([pcb_length*0.90, pcb_width*0.90, silkscreen_thickness], center=true);
}

// =====================
// Component primitives
// =====================
module box_comp(x,y,z){ cube([x,y,z], center=true); }

// Simple pin header block (adds recognizable detail)
module pin_header(rows=1, cols=6, pitch=2.54, body_h=6, pin_h=3, body_overhang=0.6) {
    body_x = cols*pitch + body_overhang*2;
    body_y = rows*pitch + body_overhang*2;
    union() {
        // plastic body
        translate([0,0,(body_h)/2])
            cube([body_x, body_y, body_h], center=true);

        // pins (protrude upward)
        for (r=[0:rows-1], c=[0:cols-1]) {
            translate([(c-(cols-1)/2)*pitch, (r-(rows-1)/2)*pitch, body_h + pin_h/2 - overlap])
                cube([0.7,0.7,pin_h], center=true);
        }
    }
}

// USB-like connector (block + small tongue)
module usb_like(w=14, d=16, h=8, tongue_w=10, tongue_d=8, tongue_h=2) {
    union() {
        cube([w,d,h], center=true);
        translate([0, -d/2 + tongue_d/2 - overlap, -h/2 + tongue_h/2 + 1])
            cube([tongue_w, tongue_d, tongue_h], center=true);
    }
}

// Screw terminal block with 3 "holes" (visual)
module screw_terminal(pins=3, pitch=5.08, w_extra=2, d=12, h=10, hole_d=3.2) {
    w = (pins-1)*pitch + w_extra*2;
    difference() {
        cube([w,d,h], center=true);
        for (i=[0:pins-1]) {
            translate([(i-(pins-1)/2)*pitch, 0, 0])
                rotate([90,0,0])
                    cylinder(d=hole_d, h=d+2, center=true);
        }
    }
}

// Heatsink with fins (recognizable)
module heatsink_finned(base=18, depth=18, h=12, fin_t=1.2, fin_gap=1.6, fins=6) {
    union() {
        cube([base, depth, h], center=true);
        // fins on top
        fin_span = (fins-1)*(fin_t+fin_gap);
        for (i=[0:fins-1]) {
            x = (i-(fins-1)/2)*(fin_t+fin_gap);
            translate([x, 0, h/2 + 3/2 - overlap])
                cube([fin_t, depth*0.95, 3], center=true);
        }
    }
}

// =====================
// Components placement (all connected to PCB via computed Z)
// =====================
module components_top() {
    top_z = pcb_thickness/2;

    // Edge connector sizes (computed, not arbitrary placement)
    usb_w = 16;
    usb_d = 18;
    usb_h = 9;

    term_pins = 4;
    term_pitch = 5.08;
    term_d = 12;
    term_h = 11;
    term_w = (term_pins-1)*term_pitch + 4;

    sd_w = 28;
    sd_d = 18;
    sd_h = 4;

    chip_x = 14;
    chip_y = 14;
    chip_z = 2.0;

    reg_x = 10;
    reg_y = 8;
    reg_z = 3.0;

    // Place parts so they touch/overlap PCB top surface
    union() {
        // USB-like connector on Y+ edge, centered
        translate([0,
                   pcb_width/2 - usb_d/2 + overlap,
                   top_z + usb_h/2 - overlap])
            usb_like(w=usb_w, d=usb_d, h=usb_h);

        // Screw terminal on X- edge near Y+
        translate([-pcb_length/2 + term_d/2 - overlap,
                   pcb_width*0.25,
                   top_z + term_h/2 - overlap])
            rotate([0,0,90])
                screw_terminal(pins=term_pins, pitch=term_pitch, d=term_d, h=term_h);

        // SD-card-like low profile connector on Y- edge, slightly right
        translate([pcb_length*0.20,
                   -pcb_width/2 + sd_d/2 - overlap,
                   top_z + sd_h/2 - overlap])
            box_comp(sd_w, sd_d, sd_h);

        // Heatsink near center-left
        hs_base = 18;
        hs_depth = 18;
        hs_h = 12;
        translate([-pcb_length*0.18,
                   -pcb_width*0.05,
                   top_z + hs_h/2 - overlap])
            heatsink_finned(base=hs_base, depth=hs_depth, h=hs_h);

        // Main MCU chip near center-right
        translate([pcb_length*0.12,
                   -pcb_width*0.12,
                   top_z + chip_z/2 - overlap])
            box_comp(chip_x, chip_y, chip_z);

        // Voltage regulator block near X+ edge
        translate([pcb_length/2 - reg_x/2 - 8,
                   pcb_width*0.10,
                   top_z + reg_z/2 - overlap])
            box_comp(reg_x, reg_y, reg_z);

        // Two pin headers along Y+ edge (recognizable)
        hdr1_cols = 8;
        hdr2_cols = 6;
        hdr_pitch = 2.54;

        hdr1_x = hdr1_cols*hdr_pitch + 1.2;
        hdr2_x = hdr2_cols*hdr_pitch + 1.2;

        hdr_body_h = 6;
        hdr_pin_h  = 3;

        translate([-pcb_length*0.25,
                   pcb_width/2 - (hdr_pitch*2)/2 - 6,
                   top_z - overlap])  // module builds upward from z=0, so anchor at PCB top
            pin_header(rows=2, cols=hdr1_cols, pitch=hdr_pitch, body_h=hdr_body_h, pin_h=hdr_pin_h);

        translate([pcb_length*0.28,
                   pcb_width/2 - (hdr_pitch*2)/2 - 6,
                   top_z - overlap])
            pin_header(rows=2, cols=hdr2_cols, pitch=hdr_pitch, body_h=hdr_body_h, pin_h=hdr_pin_h);

        // Small SMD components row (adds surface detail)
        smd_x = 6;
        smd_y = 3;
        smd_z = 1.5;
        for (i=[0:5]) {
            translate([-pcb_length*0.30 + i*(smd_x+3),
                       pcb_width*0.02,
                       top_z + smd_z/2 - overlap])
                box_comp(smd_x, smd_y, smd_z);
        }
    }
}

module components_bottom() {
    bot_z = -pcb_thickness/2;

    // Bottom blocks to make underside populated (kept connected by overlap)
    b1_x = pcb_length*0.42;
    b1_y = pcb_width*0.20;
    b1_z = 3.0;

    b2_x = 22;
    b2_y = 16;
    b2_z = 2.5;

    union() {
        // Large underside module near Y-
        translate([0,
                   -pcb_width/2 + b1_y/2 - overlap,
                   bot_z - b1_z/2 + overlap])
            box_comp(b1_x, b1_y, b1_z);

        // Smaller underside module near X+
        translate([pcb_length/2 - b2_x/2 - 10,
                   -pcb_width*0.05,
                   bot_z - b2_z/2 + overlap])
            box_comp(b2_x, b2_y, b2_z);
    }
}

// =====================
// Final model (ONE connected solid)
// =====================
module pcb_complete_model() {
    union() {
        pcb_board();
        solder_mask();
        silkscreen();
        components_top();
        components_bottom();
    }
}

color([0.0, 0.4, 0.2]) pcb_complete_model();