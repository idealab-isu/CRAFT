// Battery cell: 70.7mm tall, 18.4mm diameter
// One connected solid; Z is the height axis (so Front/Back/Left/Right show side profile).

$fn = 128;

// Parameters
cell_H = 70.7;                 // overall height (mm)
cell_D = 18.4;                 // overall diameter (mm)

button_D = 6.5;
button_H = 1.2;

neg_indent_D = 10.0;
neg_indent_depth = 0.8;

label_band_H = 45.0;
label_band_thk = 0.25;
label_band_z = 0.0;

edge_chamfer_H = 0.6;
edge_chamfer_rad_reduction = 0.6;

// Robust overlap for boolean unions/differences
overlap = 0.05;

// Derived
cell_R = cell_D/2;

// Base body with chamfered ends (overall height exactly cell_H)
module chamfered_body() {
    union() {
        // Middle straight section
        cylinder(h = cell_H - 2*edge_chamfer_H, r = cell_R, center = true);

        // Top chamfer frustum
        translate([0, 0, (cell_H/2 - edge_chamfer_H/2)])
            cylinder(h = edge_chamfer_H,
                     r1 = cell_R - edge_chamfer_rad_reduction,
                     r2 = cell_R,
                     center = true);

        // Bottom chamfer frustum
        translate([0, 0, -(cell_H/2 - edge_chamfer_H/2)])
            cylinder(h = edge_chamfer_H,
                     r1 = cell_R,
                     r2 = cell_R - edge_chamfer_rad_reduction,
                     center = true);
    }
}

module positive_button() {
    // Overlap into top surface for guaranteed connectivity
    translate([0, 0, cell_H/2 + button_H/2 - overlap])
        cylinder(h = button_H, r = button_D/2, center = true);
}

module label_band() {
    // Overlap into body for guaranteed connectivity
    translate([0, 0, label_band_z])
        cylinder(h = label_band_H, r = cell_R + label_band_thk, center = true);
}

module negative_indent_cut() {
    // Cut starts at bottom face and goes inward by neg_indent_depth
    translate([0, 0, -cell_H/2 + neg_indent_depth/2 + overlap])
        cylinder(h = neg_indent_depth + 2*overlap, r = neg_indent_D/2, center = true);
}

// Final solid (rotate so orthographic Front/Back/Left/Right show the side profile)
rotate([90, 0, 0])
difference() {
    union() {
        chamfered_body();
        positive_button();
        label_band();
    }
    negative_indent_cut();
}