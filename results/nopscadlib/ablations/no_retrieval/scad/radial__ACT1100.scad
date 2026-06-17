// Radial parameters: [20.4, 10.8, 5.3, 1]
// Interpreted as: [outer_diameter, inner_diameter, height, wall_thickness]

outer_diameter = 20.4;
inner_diameter = 10.8;
height         = 5.3;
wall_thickness = 1;

$fn = 128;

outer_r = outer_diameter/2;
inner_r = inner_diameter/2;

// Ensure a single connected solid: a ring (annulus) with the specified radii and height.
difference() {
    cylinder(h=height, r=outer_r, center=true);
    cylinder(h=height + 2*0.02, r=inner_r, center=true); // slight overshoot to avoid coplanar artifacts
}