// Stepper motor (NEMA-style) - corrected, connected, dimension-driven
$fn = 96;

// Required dimensions
face_width            = 39.5;   // square face width
body_length           = 19.2;   // body length (excluding front face plate)
shaft_diameter        = 5.0;    // shaft diameter
mounting_hole_spacing = 31.0;   // center-to-center spacing

// Reasonable detail defaults (can be adjusted)
front_face_thickness  = 3.0;
rear_cap_thickness    = 2.5;

shaft_length          = 20.0;
shaft_boss_diameter   = 22.0;
shaft_boss_thickness  = 2.0;

mounting_hole_diameter = 3.2;   // typical M3 clearance
overlap               = 0.6;    // small overlap to guarantee watertight unions

// Visual/shape details
body_corner_radius    = 2.0;    // rounded body corners
face_corner_radius    = 1.2;    // slightly sharper face corners

// Rear connector/cable exit (simple block)
connector_w = 12.0;
connector_h = 8.0;
connector_l = 6.0; // protrusion beyond rear cap

// Helpers
module rounded_cube_xy(size=[10,10,10], r=1.0, center=true) {
    // Rounded in XY, straight in Z
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, min(x,y)/2 - 0.01);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=rr)
                square([x-2*rr, y-2*rr], center=true);
}

module stepper_motor() {
    // Coordinate system:
    // Front face plane centered at z=0, motor extends to negative z, shaft to positive z.
    // Total solid is ONE connected body; holes are subtracted from the solid.

    difference() {
        union() {
            // Front face plate (at z=0)
            translate([0,0,0])
                rounded_cube_xy([face_width, face_width, front_face_thickness], r=face_corner_radius, center=true);

            // Main body behind the face plate
            translate([0,0, -(front_face_thickness/2 + body_length/2 - overlap)])
                rounded_cube_xy([face_width, face_width, body_length], r=body_corner_radius, center=true);

            // Rear cap
            translate([0,0, -(front_face_thickness/2 + body_length + rear_cap_thickness/2 - overlap)])
                rounded_cube_xy([face_width*0.98, face_width*0.98, rear_cap_thickness], r=body_corner_radius, center=true);

            // Front boss (pilot)
            translate([0,0, (front_face_thickness/2 + shaft_boss_thickness/2 - overlap)])
                cylinder(d=shaft_boss_diameter, h=shaft_boss_thickness, center=true);

            // Output shaft
            translate([0,0, (front_face_thickness/2 + shaft_length/2 - overlap)])
                cylinder(d=shaft_diameter, h=shaft_length, center=true);

            // Rear connector/cable exit (attached to rear cap)
            translate([0,0, -(front_face_thickness/2 + body_length + rear_cap_thickness + connector_l/2 - overlap)])
                rounded_cube_xy([connector_w, connector_h, connector_l], r=1.0, center=true);
        }

        // Mounting holes: THROUGH the front face plate (and slightly into body for robustness)
        hole_h = front_face_thickness + 2*overlap;
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*mounting_hole_spacing/2, sy*mounting_hole_spacing/2, 0])
                cylinder(d=mounting_hole_diameter, h=hole_h, center=true);
        }
    }
}

stepper_motor();