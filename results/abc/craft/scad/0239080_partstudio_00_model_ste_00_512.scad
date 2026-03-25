// Dimension-calibrated (target: 0.41 x 0.04 x 0.01 mm)
scale([0.990244, 1.075027, 0.625572])
{
// Long thin plate with a single row of rounded studs on ONE broad face only
// All dimensions in mm

$fn = 48;

// Parameters
L = 0.41;                  // overall length
W = 0.04;                  // overall width
plate_H = 0.006;           // plate thickness (flat opposite face)
stud_H = 0.004;            // stud protrusion height above plate
stud_D = 0.012;            // stud diameter
stud_pitch = 0.02;         // center-to-center spacing
stud_count = 19;           // number of studs
stud_edge_margin = 0.015;  // margin from each end to first/last stud center
stud_row_offset_W = 0.0;   // lateral offset of stud row (0 = centered)
overlap = 0.001;           // small overlap to ensure watertight union

H_total = plate_H + stud_H;

// Derived: ensure studs fit within length; if not, reduce count automatically
max_count = floor((L - 2*stud_edge_margin)/stud_pitch) + 1;
n = (stud_count > max_count) ? max_count : stud_count;

// Base plate centered at origin, with BOTTOM face at z = -H_total/2 (flat)
module base_plate() {
    translate([0, 0, -H_total/2 + plate_H/2])
        cube([L, W, plate_H], center=true);
}

// Single rounded stud: cylinder + hemispherical cap, protruding ONLY upward from plate top
module rounded_stud() {
    r = stud_D/2;

    // Plate top plane (stud base plane)
    z_top_plate = -H_total/2 + plate_H;

    union() {
        // Cylindrical portion (slightly sunk into plate for connectivity)
        translate([0, 0, z_top_plate + stud_H/2 - overlap/2])
            cylinder(h=stud_H + overlap, r=r, center=true);

        // Hemispherical cap: keep only the upper half above the stud base plane
        translate([0, 0, z_top_plate + stud_H])
            intersection() {
                sphere(r=r);
                // Keep z >= 0 in local coords (upper hemisphere)
                translate([0, 0, r/2])
                    cube([2*r + 2*overlap, 2*r + 2*overlap, r + 2*overlap], center=true);
            }
    }
}

// Row of studs along length (on top face only)
module stud_row() {
    x_start = -L/2 + stud_edge_margin;
    for (i = [0 : n-1]) {
        translate([x_start + i*stud_pitch, stud_row_offset_W, 0])
            rounded_stud();
    }
}

// Final connected solid
union() {
    base_plate();
    stud_row();
}
}
