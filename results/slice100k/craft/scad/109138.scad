$fn = 96;

// Target bounding box (approx): 25.0 x 21.65 x 4.0 mm
bbox_X = 25.0;
bbox_Y = 21.65;
T      = 4.0;

// Geometry
hole_d = 10.0;     // through-hole diameter
step_d = 16.0;     // diameter of shallow recess/boss feature
step_h = 1.0;      // depth of recess from each face (creates a midsection "step")
overlap = 0.2;     // small overlap for robust booleans

// Regular hex sized by flat-to-flat distance
module hex_prism(flat_to_flat, h, center=true) {
    // For a regular hex, flat-to-flat = sqrt(3) * R (circumradius)
    R = flat_to_flat / sqrt(3);
    cylinder(h=h, r=R, $fn=6, center=center);
}

module model() {
    difference() {
        // Outer hex plate
        difference() {
            hex_prism(bbox_X, T, center=true);

            // Through hole
            cylinder(h=T + 2*overlap, r=hole_d/2, center=true);

            // Shallow recess from top face
            translate([0, 0,  T/2 - step_h/2 + overlap/2])
                cylinder(h=step_h + overlap, r=step_d/2, center=true);

            // Shallow recess from bottom face (symmetric)
            translate([0, 0, -T/2 + step_h/2 - overlap/2])
                cylinder(h=step_h + overlap, r=step_d/2, center=true);
        }
    }
}

color("Silver") model();