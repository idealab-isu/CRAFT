// Flat link/strap plate with rounded ends and two through-holes
// Bounding box: 44.4 x 7.6 x 2.5 mm

$fn = 96;

// Parameters (mm)
L = 44.42;
W = 7.62;
T = 2.54;

end_radius = W/2;          // capsule ends match width
hole_d = 3;
hole_offset_from_end = 5;  // hole center distance from each end along length
overlap = 0.2;             // small overlap for clean boolean cuts

module capsule_2d(len, wid) {
    r = wid/2;
    hull() {
        translate([-(len/2 - r), 0]) circle(r=r);
        translate([ (len/2 - r), 0]) circle(r=r);
    }
}

module link_plate() {
    linear_extrude(height=T, center=true)
        capsule_2d(L, W);
}

module hole_at_end(sign=1) {
    // sign = -1 (left), +1 (right)
    x = sign * (L/2 - hole_offset_from_end);
    translate([x, 0, 0])
        cylinder(h=T + 2*overlap, r=hole_d/2, center=true);
}

difference() {
    link_plate();
    hole_at_end(-1);
    hole_at_end( 1);
}