$fn = 64;

// Target overall size (mm)
body_length = 11.40;
body_width  = 7.50;
body_height = 2.00;

// Feature parameters (kept proportional and connected)
edge_round_r   = 0.35;   // corner rounding for body
top_chamfer_h  = 0.25;   // slight top taper
pin1_mark_r    = 0.55;
pin1_mark_h    = 0.18;
pin1_inset_xy  = 1.10;   // from outer edges
overlap        = 0.05;   // small overlap to guarantee single connected solid

// Simple SMD terminals (as bottom pads)
pad_len   = 1.60;
pad_thk   = 0.20;
pad_inset = 0.15;        // inset from body ends

module rounded_box_xy(l, w, h, r) {
    // Rounded rectangle in XY, extruded in Z
    linear_extrude(height=h, center=true)
        offset(r=r)
            square([l - 2*r, w - 2*r], center=true);
}

module smd_body() {
    // Slight top taper via hull of two rounded boxes
    color("DimGray")
    hull() {
        translate([0,0,-top_chamfer_h/2])
            rounded_box_xy(body_length, body_width, body_height - top_chamfer_h, edge_round_r);

        translate([0,0, body_height/2 - top_chamfer_h/2])
            rounded_box_xy(body_length - 2*top_chamfer_h,
                           body_width  - 2*top_chamfer_h,
                           top_chamfer_h,
                           max(0.01, edge_round_r - top_chamfer_h/2));
    }
}

module pad_at_end(sign) { // sign = -1 (left), +1 (right)
    // Pads are connected to body by slight overlap into the body bottom
    color("Silver")
    translate([
        sign * (body_length/2 - pad_inset - pad_len/2),
        0,
        -body_height/2 - pad_thk/2 + overlap
    ])
        cube([pad_len, body_width*0.78, pad_thk + 2*overlap], center=true);
}

module pin1_mark() {
    // Small top mark near one corner, connected with overlap
    color("Silver")
    translate([
        -body_length/2 + pin1_inset_xy,
         body_width/2  - pin1_inset_xy,
         body_height/2 - pin1_mark_h/2 + overlap
    ])
        cylinder(r=pin1_mark_r, h=pin1_mark_h + 2*overlap, center=true);
}

union() {
    smd_body();
    pad_at_end(-1);
    pad_at_end( 1);
    pin1_mark();
}