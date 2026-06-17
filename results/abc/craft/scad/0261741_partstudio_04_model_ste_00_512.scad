// Thin keyed plate with asymmetric tabs on opposite Z faces
// Goal: one connected solid; visible asymmetry between front/back and left/right views.

// Parameters (mm)
plate_W = 0.30;
plate_H = 0.30;
plate_T = 0.01;

// Tab sizes
tab_out    = 0.01;   // protrusion outward from edge (in XY)
tab_w      = 0.06;   // width of top/bottom tabs (along X)
tab_side_h = 0.06;   // height of side tabs (along Y)

// Make face-specific tabs clearly visible in orthographic views
tab_face_T = plate_T * 0.90;   // thickness of a tab on one face (along Z)

// Small overlap to guarantee manifold union
overlap = 0.001;

// Base plate
module base_plate() {
    cube([plate_W, plate_H, plate_T], center=true);
}

// Helper: Z-center for a tab that sits on +Z or -Z face and overlaps into plate
function zc(sign) = sign * (plate_T/2 - tab_face_T/2 + overlap);

// +Y edge tab on +Z face (front)
module top_tab_front_face() {
    translate([0,
               plate_H/2 + tab_out/2 - overlap,
               zc(+1)])
        cube([tab_w, tab_out + 2*overlap, tab_face_T], center=true);
}

// -Y edge tab on -Z face (back)
module bottom_tab_back_face() {
    translate([0,
               -(plate_H/2 + tab_out/2 - overlap),
               zc(-1)])
        cube([tab_w, tab_out + 2*overlap, tab_face_T], center=true);
}

// -X edge tab on +Z face (front)
module left_mid_tab_front_face() {
    translate([-(plate_W/2 + tab_out/2 - overlap),
               0,
               zc(+1)])
        cube([tab_out + 2*overlap, tab_side_h, tab_face_T], center=true);
}

// +X edge tab on -Z face (back)
module right_mid_tab_back_face() {
    translate([+(plate_W/2 + tab_out/2 - overlap),
               0,
               zc(-1)])
        cube([tab_out + 2*overlap, tab_side_h, tab_face_T], center=true);
}

// Final connected solid
union() {
    base_plate();
    top_tab_front_face();
    bottom_tab_back_face();
    left_mid_tab_front_face();
    right_mid_tab_back_face();
}