// Long slender prismatic bar with socket head and tapered tip
// Units: mm

$fn = 64;

// Target overall bounding box (approx): X=0.03, Y=0.32, Z=0.07
bbox_x = 0.03;
bbox_y = 0.32;
bbox_z = 0.07;

// Main dimensions
head_L        = 0.06;
head_OD       = 0.03;   // collar OD (also approx max X)
head_H        = 0.07;   // collar height in Z (max Z)

shoulder_L    = 0.01;

shaft_L       = bbox_y - head_L - shoulder_L;  // ensures overall length matches bbox_y
shaft_W       = 0.022;  // X
shaft_H       = 0.045;  // Z

// Tip
tip_L         = 0.02;
tip_end_W     = 0.008;
tip_end_H     = 0.02;

// Socket
socket_depth  = 0.03;
socket_square = 0.016;
lead_in_L     = 0.006;

// Faceting/chamfers
facet_cut     = 0.002;
overlap       = 0.001;

// Derived positions along Y (object centered at origin)
y_min = -bbox_y/2;
y_max =  bbox_y/2;

y_head0     = y_min;
y_head1     = y_head0 + head_L;

y_shoulder0 = y_head1;
y_shoulder1 = y_shoulder0 + shoulder_L;

y_shaft0    = y_shoulder1;
y_shaft1    = y_shaft0 + shaft_L;

y_tip0      = y_max - tip_L;
y_tip1      = y_max;

// ---------- Helpers ----------
module hex_prism_y(flat_d, len_y, center_y=false) {
    // flat_d is across flats
    r = flat_d / sqrt(3); // circumradius for across-flats = sqrt(3)*r
    rotate([90,0,0])
        cylinder(r=r, h=len_y, center=center_y, $fn=6);
}

module collar_union() {
    // Cylindrical collar + hex flats, same length, unioned (connected)
    translate([0, (y_head0+y_head1)/2, 0]) {
        rotate([90,0,0]) cylinder(r=head_OD/2, h=head_L, center=true);
        // Slightly smaller hex so it reads as flats on the cylinder
        hex_prism_y(flat_d=head_OD*0.98, len_y=head_L, center_y=true);
    }
}

module shoulder_block() {
    // Transition block between collar and shaft (ensures connectivity)
    translate([0, (y_shoulder0+y_shoulder1)/2 - overlap/2, 0])
        cube([max(head_OD, shaft_W), shoulder_L + overlap, max(head_H, shaft_H)], center=true);
}

module shaft_block() {
    translate([0, (y_shaft0+y_shaft1)/2, 0])
        cube([shaft_W, shaft_L, shaft_H], center=true);
}

module tip_wedge() {
    // Tapered/chamfered tip made by hulling two rectangles (prismatic taper)
    hull() {
        translate([0, (y_tip0+y_tip0+overlap)/2, 0])
            cube([shaft_W, overlap, shaft_H], center=true);
        translate([0, (y_tip1+y_tip1-overlap)/2, 0])
            cube([tip_end_W, overlap, tip_end_H], center=true);
    }
}

module main_solid() {
    union() {
        collar_union();
        shoulder_block();
        shaft_block();
        // Blend into tip: overlap into shaft to guarantee connection
        translate([0, -overlap, 0]) tip_wedge();
    }
}

// Facet the shaft slightly (keep mostly rectangular)
module shaft_facets_subtractive() {
    // Cut small 45° bevels along the long edges by removing thin rotated prisms
    // Only applied over shaft+tip region to keep head mostly intact.
    y_mid = (y_shaft0 + y_tip1)/2;
    y_len = (y_tip1 - y_shaft0) + 2*overlap;

    for (sx = [-1, 1], sz = [-1, 1]) {
        translate([sx*(shaft_W/2), y_mid, sz*(shaft_H/2)])
            rotate([0,45,0])
                cube([facet_cut*4, y_len, facet_cut*4], center=true);
    }
}

// Socket cut: recessed square/diamond opening into the collar end
module socket_cut() {
    // Square rotated 45° around Y to appear diamond in XZ in end view
    // Cut starts at y_head0 and goes inward socket_depth
    translate([0, y_head0 + socket_depth/2 + overlap, 0])
        rotate([0,45,0])
            cube([socket_square, socket_depth + 2*overlap, socket_square], center=true);

    // Lead-in chamfer at the mouth
    translate([0, y_head0 + lead_in_L/2 + overlap, 0])
        rotate([90,0,0])
            cylinder(r1=socket_square*0.85, r2=socket_square*0.55, h=lead_in_L + 2*overlap, center=true);
}

// ---------- Final ----------
difference() {
    // Ensure one connected solid
    main_solid();

    // Facets (subtractive)
    shaft_facets_subtractive();

    // Recessed socket
    socket_cut();
}