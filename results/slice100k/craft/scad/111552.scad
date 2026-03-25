// Long flat link/strap with rounded ends and two through-holes
// Bounding box target: 102.0 x 7.0 x 3.5 mm (X x Y x Z)

$fn = 96;

// Parameters
L = 102.0;                 // overall length (X)
W = 7.0;                   // overall width (Y)
T = 3.5;                   // thickness (Z)

hole_D = 3.0;              // through-hole diameter
hole_offset_from_end = 3.5; // hole center distance from each end along X

// Robust boolean overlap
overlap = 0.2;

// Derived
end_R = W/2;               // rounded end radius to match width
hole_r = hole_D/2;
hole_x = L/2 - hole_offset_from_end;

// 2D profile: rectangle + two semicircular ends (capsule)
module strap_profile_2d() {
    hull() {
        translate([-L/2 + end_R, 0]) circle(r=end_R);
        translate([ L/2 - end_R, 0]) circle(r=end_R);
    }
}

module strap_solid() {
    linear_extrude(height=T, center=true)
        strap_profile_2d();
}

module holes() {
    for (sx = [-1, 1]) {
        translate([sx * hole_x, 0, 0])
            cylinder(h=T + 2*overlap, r=hole_r, center=true);
    }
}

// Final model (single connected solid with two through-holes)
difference() {
    strap_solid();
    holes();
}