$fn = 96;

// Target dimensions (mm)
face_width = 42.3;                 // square face (X,Y)
body_length = 47.0;                // body length behind face (Z-)
front_face_thickness = 3.0;        // front plate thickness (Z)
shaft_diameter = 5.0;              // shaft diameter
shaft_length = 20.0;               // shaft protrusion (Z+)
mount_hole_spacing = 31.0;         // center-to-center (X,Y)
mount_hole_diameter = 3.2;         // clearance

// Visible stepper features (simple but recognizable)
pilot_diameter = 22.0;             // front pilot/boss
pilot_height = 2.0;

rear_boss_diameter = 16.0;         // rear bearing/shaft support boss
rear_boss_height = 1.6;

connector_w = 16.0;                // rear connector block
connector_h = 8.0;
connector_len = 6.0;               // protrusion from rear face

// Small overlap to ensure connectivity (no floating parts)
overlap = 0.6;

// Derived
body_w = face_width;
body_h = face_width;
total_z = body_length + front_face_thickness; // overall motor length excluding shaft/connector

module mount_holes(h, zc) {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2, zc])
            cylinder(d=mount_hole_diameter, h=h, center=true);
}

module stepper_motor() {
    // Coordinate convention:
    // Front face plate centered at Z=0 (spans +/- front_face_thickness/2)
    // Body extends to negative Z
    // Shaft/pilot extend to positive Z
    union() {
        difference() {
            union() {
                // Main body (behind face)
                translate([0, 0, -(front_face_thickness/2 + body_length/2 - overlap)])
                    cube([body_w, body_h, body_length], center=true);

                // Front face plate
                cube([face_width, face_width, front_face_thickness], center=true);

                // Front pilot boss (connected)
                translate([0, 0, front_face_thickness/2 + pilot_height/2 - overlap])
                    cylinder(d=pilot_diameter, h=pilot_height, center=true);

                // Output shaft (connected)
                translate([0, 0, front_face_thickness/2 + shaft_length/2 - overlap])
                    cylinder(d=shaft_diameter, h=shaft_length, center=true);

                // Rear boss (bearing/support hint) on back face of body (connected)
                translate([0, 0, -(front_face_thickness/2 + body_length) + rear_boss_height/2 + overlap])
                    cylinder(d=rear_boss_diameter, h=rear_boss_height, center=true);

                // Rear connector block (connected to rear face)
                translate([0,
                           -(face_width/2 + connector_len/2 - overlap),
                           -(front_face_thickness/2 + body_length) + connector_h/2 + overlap])
                    cube([connector_w, connector_len, connector_h], center=true);
            }

            // Mounting holes through the front face (and slightly into body)
            mount_holes(front_face_thickness + 2*overlap, 0);

            // Shallow counterbore hint on front face
            mount_holes(1.2, front_face_thickness/2 - 0.6);
        }
    }
}

stepper_motor();