// Stepper motor (NEMA-style) - corrected, single connected solid
// Target: 20.0mm face width, 30.0mm body length, 5.0mm shaft diameter, 16.0mm mounting hole spacing

$fn = 64;

// Parameters
face_width_mm = 20.0;                 // square face width
body_length_mm = 30.0;                // motor body length (Z)
face_thickness_mm = 3.0;              // front faceplate thickness
shaft_diameter_mm = 5.0;              // shaft diameter
shaft_length_mm = 15.0;               // shaft length protruding from face
mount_hole_spacing_mm = 16.0;         // center-to-center spacing (square pattern)
mount_hole_diameter_mm = 3.2;         // clearance hole
corner_radius_mm = 1.0;               // body edge rounding
pilot_diameter_mm = 10.0;             // front pilot/boss diameter (typical)
pilot_height_mm = 2.0;                // pilot height
overlap_mm = 0.6;                     // small overlap to ensure connectivity / robust booleans

// Rounded box helper (centered)
module rounded_box(size=[20,20,30], r=1.0) {
    r2 = min(r, min(size[0], size[1]) / 2);
    linear_extrude(height=size[2], center=true)
        offset(r=r2)
            square([size[0]-2*r2, size[1]-2*r2], center=true);
}

// Main motor solid (single connected solid)
module stepper_motor() {
    // Coordinate system:
    // Motor body centered at origin, Z axis along motor length.
    // Front face is at +body_length_mm/2.

    front_z = body_length_mm/2;
    face_center_z = front_z - face_thickness_mm/2; // faceplate sits on front of body
    pilot_center_z = front_z + pilot_height_mm/2 - overlap_mm;
    shaft_center_z = front_z + shaft_length_mm/2 - overlap_mm;

    difference() {
        union() {
            // Body (square)
            rounded_box([face_width_mm, face_width_mm, body_length_mm], corner_radius_mm);

            // Front faceplate (slightly larger square, connected with overlap)
            translate([0, 0, face_center_z])
                rounded_box([face_width_mm, face_width_mm, face_thickness_mm + 2*overlap_mm], corner_radius_mm);

            // Front pilot/boss (connected)
            translate([0, 0, pilot_center_z])
                cylinder(d=pilot_diameter_mm, h=pilot_height_mm + 2*overlap_mm, center=true);

            // Shaft (connected)
            translate([0, 0, shaft_center_z])
                cylinder(d=shaft_diameter_mm, h=shaft_length_mm + 2*overlap_mm, center=true);
        }

        // Mounting holes through the faceplate (visible from front)
        // Place holes on a 16mm square pattern: (±8, ±8)
        hole_offset = mount_hole_spacing_mm/2;
        hole_h = face_thickness_mm + 4*overlap_mm;
        for (x = [-hole_offset, hole_offset])
            for (y = [-hole_offset, hole_offset])
                translate([x, y, face_center_z])
                    cylinder(d=mount_hole_diameter_mm, h=hole_h, center=true);
    }
}

stepper_motor();