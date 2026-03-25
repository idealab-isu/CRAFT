// Dimension-calibrated (target: 0.04 x 0.04 x 0.02 mm)
scale([0.000950, 0.000950, 0.001189])
{
// Thick circular disk/button with shallow recessed rim, 5 diamond cutouts,
// central square through feature, and a short square peg on the back.
// Units: mm

$fn = 160;

// -------------------- Parameters --------------------
disk_D = 40;
disk_H = 14;

peg_W = 10;
peg_H = 6;

center_sq_W = 8;                 // central square THROUGH feature size
center_sq_depth = disk_H + 4;    // ensure full through cut with margin

rim_recess_D_outer = 36;
rim_recess_D_inner = 28;
rim_recess_depth   = 1.5;

diamond_W = 6;                   // diamond width (before 45° rotation)
diamond_H = 10;                  // diamond height (before 45° rotation)
diamond_depth = disk_H + 4;      // through cut with margin

// Five diamonds: one at top + four around it (NE, SE, SW, NW) = 5 total
diamond_radial_offset = 12;

eps = 0.05;                      // small overlap to avoid coplanar artifacts
overlap = 1.5;                   // intentional overlap for solid connections

// -------------------- Base shapes --------------------
module disk_body() {
    cylinder(d=disk_D, h=disk_H, center=true);
}

module axial_square_peg() {
    // Peg protrudes from back face (negative Z) and overlaps into disk for a solid union
    translate([0, 0, -(disk_H/2 + peg_H/2 - overlap)])
        cube([peg_W, peg_W, peg_H], center=true);
}

module recessed_rim_cut() {
    // Shallow annular recess on the front face (positive Z), cut into disk
    translate([0, 0, (disk_H/2 - rim_recess_depth/2)])
        difference() {
            cylinder(d=rim_recess_D_outer, h=rim_recess_depth + 2*eps, center=true);
            cylinder(d=rim_recess_D_inner, h=rim_recess_depth + 4*eps, center=true);
        }
}

module central_square_through_cut() {
    cube([center_sq_W, center_sq_W, center_sq_depth], center=true);
}

module diamond_cutout() {
    // Diamond made by rotating a rectangle 45 degrees
    rotate([0, 0, 45])
        cube([diamond_W, diamond_H, diamond_depth], center=true);
}

module five_diamond_cutouts_pattern() {
    // EXACTLY five diamonds:
    // - one at top (N)
    // - four around it at diagonals (NE, SE, SW, NW)
    union() {
        // Top (N)
        translate([0,  diamond_radial_offset, 0]) diamond_cutout();

        // Four around (diagonals)
        translate([ diamond_radial_offset,  diamond_radial_offset, 0]) diamond_cutout(); // NE
        translate([ diamond_radial_offset, -diamond_radial_offset, 0]) diamond_cutout(); // SE
        translate([-diamond_radial_offset, -diamond_radial_offset, 0]) diamond_cutout(); // SW
        translate([-diamond_radial_offset,  diamond_radial_offset, 0]) diamond_cutout(); // NW
    }
}

// -------------------- Final model --------------------
difference() {
    union() {
        disk_body();
        axial_square_peg();
    }
    recessed_rim_cut();
    five_diamond_cutouts_pattern();
    central_square_through_cut();
}
}
