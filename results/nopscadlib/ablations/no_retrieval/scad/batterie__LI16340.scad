// Battery cell: 35.2mm tall, 16.4mm diameter
// One connected solid, with button-top (+) and recessed (-) end.

$fn = 128;

// Parameters
cell_H = 35.2;          // overall height (including terminals)
cell_D = 16.4;          // overall diameter
eps = 0.05;             // small overlap for robust unions/differences

// End details
button_D = 5.5;
button_H = 1.2;

neg_indent_D = 8.0;
neg_indent_depth = 0.8;

// Small edge rounding via chamfer (keeps overall height/diameter unchanged)
chamfer_H = 0.6;
chamfer_radial = 0.5;

// Derived
R = cell_D/2;

// Main body height excludes the protruding positive button so total height stays cell_H
body_H = cell_H - button_H;

// Helpers
module body_with_chamfers(h, r, ch_h, ch_r) {
    // Cylinder with small chamfers at both ends, preserving overall height and max diameter.
    union() {
        // Middle straight section
        translate([0,0,0])
            cylinder(h = max(eps, h - 2*ch_h), r = r, center = true);

        // Top chamfer
        translate([0,0, (h/2 - ch_h/2)])
            cylinder(h = ch_h, r1 = r - ch_r, r2 = r, center = true);

        // Bottom chamfer
        translate([0,0, -(h/2 - ch_h/2)])
            cylinder(h = ch_h, r1 = r, r2 = r - ch_r, center = true);
    }
}

module positive_button() {
    // Sits on top of the body; overlaps slightly to ensure connectivity
    translate([0,0, body_H/2 + button_H/2 - eps])
        cylinder(h = button_H, r = button_D/2, center = true);
}

module negative_indent_cut() {
    // Recess into the bottom face of the body
    translate([0,0, -(body_H/2 - neg_indent_depth/2) ])
        cylinder(h = neg_indent_depth + 2*eps, r = neg_indent_D/2, center = true);
}

// Final model
difference() {
    union() {
        body_with_chamfers(body_H, R, chamfer_H, chamfer_radial);
        positive_button();
    }
    negative_indent_cut();
}