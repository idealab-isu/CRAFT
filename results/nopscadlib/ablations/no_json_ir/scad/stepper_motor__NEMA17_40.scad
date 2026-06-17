$fn = 96;

// Target dimensions (mm)
face_size              = 42.3;   // square face width
motor_length           = 40.0;   // body length (Z)
shaft_diameter         = 5.0;    // shaft diameter
shaft_length           = 20.0;   // shaft protrusion from front face
mounting_hole_spacing  = 31.0;   // hole center-to-center spacing
mounting_hole_diameter = 3.5;    // mounting hole diameter

// Simple NEMA-style details
front_plate_thickness  = 2.0;    // front face plate thickness
pilot_diameter         = 22.0;   // front boss (typical-ish)
pilot_height           = 2.0;    // boss height
corner_radius          = 2.0;    // slight edge rounding (visual)
eps                    = 0.2;    // overlap to ensure connectivity

module rounded_square_prism(w, h, r, center=false) {
    // 2D rounded square extruded
    linear_extrude(height=h, center=center)
        offset(r=r)
            square([w - 2*r, w - 2*r], center=true);
}

module stepper_motor() {
    // Coordinate system:
    // Front face at z=0, body extends to negative z, shaft extends to positive z.
    difference() {
        union() {
            // Main body (connected to front plate)
            translate([0, 0, -motor_length/2])
                rounded_square_prism(face_size, motor_length, corner_radius, center=true);

            // Front face plate (slight step)
            translate([0, 0, front_plate_thickness/2 - eps])
                rounded_square_prism(face_size, front_plate_thickness, corner_radius, center=true);

            // Front pilot/boss (centered)
            translate([0, 0, front_plate_thickness + pilot_height/2 - eps])
                cylinder(h=pilot_height, d=pilot_diameter, center=true);

            // Output shaft (centered, connected into pilot)
            translate([0, 0, front_plate_thickness + pilot_height - eps + shaft_length/2])
                cylinder(h=shaft_length, d=shaft_diameter, center=true);
        }

        // Mounting holes through the front plate (and slightly into body)
        for (x = [-1, 1])
            for (y = [-1, 1])
                translate([x * mounting_hole_spacing/2,
                           y * mounting_hole_spacing/2,
                           front_plate_thickness/2])
                    cylinder(h=front_plate_thickness + 2*eps,
                             d=mounting_hole_diameter,
                             center=true);
    }
}

stepper_motor();