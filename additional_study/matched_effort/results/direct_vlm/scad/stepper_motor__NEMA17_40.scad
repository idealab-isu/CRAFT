$fn = 96;

// Parameters (mm)
face_w = 42.3;          // motor face width (square)
body_len = 40.0;        // motor body length (excluding front boss/shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 22.0;       // typical protrusion
mount_spacing = 31.0;   // center-to-center mounting hole spacing
mount_hole_d = 3.2;     // typical for M3 clearance
front_boss_d = 22.0;    // typical NEMA17 pilot diameter
front_boss_h = 2.0;     // typical pilot height
corner_r = 3.0;         // slight rounding on body edges

module rounded_box_xy(size=[10,10,10], r=1) {
    // Rounded rectangle in XY, extruded in Z
    x = size[0]; y = size[1]; z = size[2];
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module stepper_motor_nema17_like() {
    // Coordinate system:
    // Front face at z=0, body extends to negative z.
    // Shaft extends to positive z.
    difference() {
        union() {
            // Body
            translate([0,0,-body_len])
                rounded_box_xy([face_w, face_w, body_len], r=corner_r);

            // Front boss (pilot)
            cylinder(d=front_boss_d, h=front_boss_h);

            // Shaft
            translate([0,0,front_boss_h])
                cylinder(d=shaft_d, h=shaft_len);
        }

        // Mounting holes through front face into body
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*mount_spacing/2, sy*mount_spacing/2, -body_len-0.5])
                cylinder(d=mount_hole_d, h=body_len + front_boss_h + 1.0);
        }

        // Optional: small center recess on front face (common on some motors)
        // Comment out if undesired
        translate([0,0,-0.01])
            cylinder(d=10.0, h=0.8);
    }
}

stepper_motor_nema17_like();