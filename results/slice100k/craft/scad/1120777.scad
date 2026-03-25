// Flat link/strap plate with rounded (capsule) ends and two through-holes
// Bounding box target: 44.4 x 7.6 x 2.5 mm

$fn = 96;

// Parameters (mm)
L = 44.4;
W = 7.6;
T = 2.5;

hole_D = 3.2;
hole_offset_from_end = 5;   // hole center distance from each end along length
hole_clearance = 0.05;

overlap = 0.8;              // used only to ensure clean boolean cuts

// Derived
end_R = W/2;                // capsule ends match width
rect_L = L - 2*end_R;       // center rectangle length (tangent-to-tangent)

// Capsule body (one connected solid)
module strap_body() {
    union() {
        cube([rect_L, W, T], center=true);
        translate([ rect_L/2, 0, 0]) cylinder(r=end_R, h=T, center=true);
        translate([-rect_L/2, 0, 0]) cylinder(r=end_R, h=T, center=true);
    }
}

// Through-holes (aligned on long axis)
module strap_holes() {
    for (sx = [-1, 1]) {
        translate([sx*(L/2 - hole_offset_from_end), 0, 0])
            cylinder(r=hole_D/2 + hole_clearance, h=T + 2*overlap, center=true);
    }
}

// Final model
color("Silver")
difference() {
    strap_body();
    strap_holes();
}