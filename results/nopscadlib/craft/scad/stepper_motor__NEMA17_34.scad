$fn = 96;

// Requested key dimensions
face_width = 42.3;                 // motor face square (X,Y)
body_length = 34.0;                // motor body length behind face (Z-)
shaft_diameter = 5.0;              // shaft diameter
mount_hole_spacing = 31.0;         // hole-to-hole spacing (square pattern)

// Typical NEMA-style details (kept simple but recognizable)
front_face_thickness = 3.0;
pilot_diameter = 22.0;             // front pilot/boss
pilot_height = 2.0;
rear_boss_diameter = 22.0;
rear_boss_height = 2.0;

mount_hole_diameter = 3.2;
shaft_length = 20.0;               // protruding from front face
shaft_flat_depth = 0.6;
shaft_flat_length = 12.0;

corner_radius = 3.0;               // rounded body corners (visual)
eps = 0.25;                        // overlap to ensure connectivity / robust booleans

module rounded_square_prism(w, h, r, center=true) {
    // w: width in X and Y, h: height in Z
    // r: corner radius
    linear_extrude(height=h, center=center, convexity=10)
        offset(r=r)
            square([w - 2*r, w - 2*r], center=true);
}

module stepper_motor() {

    // Coordinate convention:
    // Front face outer plane at Z = 0
    // Motor extends to negative Z (body), shaft extends to positive Z

    difference() {
        // ONE connected solid (union of all positive geometry)
        union() {
            // --- Main motor body (behind face) ---
            // Body spans Z: [-front_face_thickness - body_length, -front_face_thickness]
            translate([0, 0, -front_face_thickness - body_length/2])
                rounded_square_prism(face_width, body_length, corner_radius, center=true);

            // --- Front face plate ---
            // Face spans Z: [-front_face_thickness, 0]
            translate([0, 0, -front_face_thickness/2])
                cube([face_width, face_width, front_face_thickness], center=true);

            // --- Front pilot/boss (protrudes forward so it is visible in orthographic views) ---
            // Boss spans Z: [-eps, pilot_height] (overlaps into face by eps)
            translate([0, 0, pilot_height/2 - eps/2])
                cylinder(d=pilot_diameter, h=pilot_height + eps, center=true);

            // --- Rear boss (on back) ---
            // Back plane at Z = -front_face_thickness - body_length
            translate([0, 0, -front_face_thickness - body_length - rear_boss_height/2 + eps/2])
                cylinder(d=rear_boss_diameter, h=rear_boss_height + eps, center=true);

            // --- Shaft (base cylinder) ---
            // Shaft spans Z: [0, shaft_length] and overlaps into pilot/face by eps
            translate([0, 0, shaft_length/2 - eps/2])
                cylinder(d=shaft_diameter, h=shaft_length + eps, center=true);
        }

        // --- Mounting holes (through face plate only) ---
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x*mount_hole_spacing/2, y*mount_hole_spacing/2, -front_face_thickness/2])
                cylinder(d=mount_hole_diameter, h=front_face_thickness + 2*eps, center=true);
        }

        // --- Shaft flat (remove a slab from one side of the shaft) ---
        // Cut only along the front portion of the shaft.
        translate([shaft_diameter/2 - shaft_flat_depth/2, 0, shaft_flat_length/2 - eps/2])
            cube([shaft_diameter + 2*eps, shaft_diameter*1.4, shaft_flat_length + 2*eps], center=true);
    }
}

stepper_motor();