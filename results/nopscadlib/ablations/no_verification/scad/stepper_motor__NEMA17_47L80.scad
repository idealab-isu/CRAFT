$fn = 96;

// Required dimensions
face_width = 42.3;          // motor face (square) width (X,Y)
body_length = 47.0;         // motor body length (Z)
shaft_diameter = 5.0;       // shaft diameter
mount_hole_spacing = 31.0;  // center-to-center spacing of mounting holes (square pattern)

// Additional typical details (kept reasonable, do not change required dims)
corner_radius = 2.0;
face_thickness = 3.0;

front_recess_depth = 0.8;
front_recess_margin = 2.5;

shaft_length = 20.0;
shaft_boss_diameter = 22.0;
shaft_boss_height = 2.0;

mount_hole_diameter = 3.5;

back_boss_diameter = 18.0;
back_boss_height = 1.5;

overlap = 0.6;

// Helpers
module rounded_square_prism(w, h, r, center=true) {
    // w x w x h, rounded corners in XY
    linear_extrude(height=h, center=center)
        offset(r=r)
            square([w - 2*r, w - 2*r], center=true);
}

module stepper_motor() {
    difference() {
        union() {
            // Main body (centered at origin)
            rounded_square_prism(face_width, body_length, corner_radius, center=true);

            // Front face plate (slight overlap into body)
            translate([0, 0, body_length/2 - face_thickness/2 + overlap])
                rounded_square_prism(face_width, face_thickness, corner_radius, center=true);

            // Front boss (connected)
            translate([0, 0, body_length/2 + shaft_boss_height/2 - overlap])
                cylinder(d=shaft_boss_diameter, h=shaft_boss_height, center=true);

            // Shaft (connected)
            translate([0, 0, body_length/2 + shaft_length/2 - overlap])
                cylinder(d=shaft_diameter, h=shaft_length, center=true);

            // Back boss (connected)
            translate([0, 0, -body_length/2 - back_boss_height/2 + overlap])
                cylinder(d=back_boss_diameter, h=back_boss_height, center=true);
        }

        // Front recess (shallow pocket for face detail)
        translate([0, 0, body_length/2 - front_recess_depth/2 + overlap])
            cube([face_width - 2*front_recess_margin,
                  face_width - 2*front_recess_margin,
                  front_recess_depth + 2*overlap], center=true);

        // Mounting holes (4x) on 31mm spacing, THROUGH the entire motor (verifiable)
        for (x = [-mount_hole_spacing/2, mount_hole_spacing/2])
            for (y = [-mount_hole_spacing/2, mount_hole_spacing/2])
                translate([x, y, 0])
                    cylinder(d=mount_hole_diameter,
                             h=body_length + face_thickness + shaft_boss_height + back_boss_height + 4*overlap,
                             center=true);

        // Small center pilot around shaft (visual cue on front face)
        translate([0, 0, body_length/2 - 1.0])
            cylinder(d=10.0, h=2.0 + 2*overlap, center=true);

        // Back face shallow recess to create distinct back view depth cue
        translate([0, 0, -body_length/2 + front_recess_depth/2 - overlap])
            cube([face_width - 2*(front_recess_margin + 0.8),
                  face_width - 2*(front_recess_margin + 0.8),
                  front_recess_depth + 2*overlap], center=true);
    }
}

stepper_motor();