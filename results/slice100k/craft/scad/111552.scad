// Long flat link/strap with rounded ends and two through-holes
// Bounding box target: 102.0 x 7.0 x 3.5 mm (X x Y x Z)

$fn = 128;  // smooth, clearly circular holes

// Parameters
L = 102.0;                 // overall length (X)
W = 7.0;                   // overall width (Y)
T = 3.5;                   // thickness (Z)
end_radius = W/2;          // rounded end radius to match width
hole_d = 3.0;              // through-hole diameter
hole_offset_from_end = 6.0;// hole center offset from each end along X
hole_clearance_z = 0.5;    // extra cut height to guarantee through-cut

// Derived
core_len = L - 2*end_radius;                 // straight section length
end_center_x = L/2 - end_radius;             // x position of end-cap centers
hole_x = L/2 - hole_offset_from_end;         // x position of hole centers

module strap_solid() {
    // Build as a 2D rounded-rectangle then linear_extrude for robust, connected geometry
    linear_extrude(height=T, center=true, convexity=10)
        hull() {
            translate([ end_center_x, 0]) circle(r=end_radius);
            translate([-end_center_x, 0]) circle(r=end_radius);
        }
}

module holes() {
    // Cut cylinders through thickness (Z)
    for (sx = [-1, 1])
        translate([sx*hole_x, 0, 0])
            cylinder(d=hole_d, h=T + 2*hole_clearance_z, center=true);
}

difference() {
    strap_solid();
    holes();
}