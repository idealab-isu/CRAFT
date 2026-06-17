$fn = 96;

// Required dimensions
face_w = 42.3;          // motor face width (X,Y)
body_len = 47.0;        // motor body length (Z, excluding shaft)
shaft_d = 5.0;          // shaft diameter
mount_spacing = 31.0;   // mounting hole spacing (center-to-center)

// Additional (reasonable) details for recognizability
corner_r = 2.0;         // rounded body corners
front_plate_t = 3.0;    // front face plate thickness
boss_d = 22.0;          // front boss diameter
boss_h = 2.0;           // front boss height
shaft_len = 20.0;       // shaft length in front of face
hole_d = 3.2;           // clearance hole diameter
hole_depth = front_plate_t + 0.6; // cut depth into front plate
eps = 0.2;              // overlap to ensure connectivity / robust booleans

module rounded_box_xy(size=[10,10,10], r=1, center=true) {
    // Rounded in XY, straight in Z
    x = size[0]; y = size[1]; z = size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r)
                square([x-2*r, y-2*r], center=true);
}

module mounting_holes_cut(z_center) {
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*mount_spacing/2, sy*mount_spacing/2, z_center])
                cylinder(h=hole_depth + 2*eps, d=hole_d, center=true);
}

module stepper_motor() {
    // Coordinate system:
    // Front face at z = 0, body extends to negative Z, shaft extends to positive Z.
    union() {
        // Body + front plate with holes cut (single connected solid)
        difference() {
            union() {
                // Main body (ends at z=0)
                translate([0, 0, -body_len/2])
                    rounded_box_xy([face_w, face_w, body_len], r=corner_r, center=true);

                // Front face plate (slightly proud of body, connected with overlap)
                translate([0, 0, front_plate_t/2 - eps])
                    rounded_box_xy([face_w, face_w, front_plate_t], r=corner_r, center=true);

                // Front boss (centered on face, connected)
                translate([0, 0, front_plate_t + boss_h/2 - eps])
                    cylinder(h=boss_h, d=boss_d, center=true);
            }

            // Mounting holes (cut into front plate)
            mounting_holes_cut(z_center=front_plate_t/2);
        }

        // Shaft (connected to boss/face)
        translate([0, 0, front_plate_t + boss_h + shaft_len/2 - eps])
            cylinder(h=shaft_len, d=shaft_d, center=true);
    }
}

stepper_motor();