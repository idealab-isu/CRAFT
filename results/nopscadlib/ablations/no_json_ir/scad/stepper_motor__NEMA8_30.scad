$fn = 96;

// Requested dimensions
face_w = 20.0;          // square face width (X,Y)
body_len = 30.0;        // body length along Z
shaft_d = 4.0;          // shaft diameter
hole_spacing = 16.0;    // mounting hole center-to-center (square pattern)

// Additional reasonable details (kept small, connected, and derived from above)
corner_r = face_w * 0.08;
front_plate_t = max(1.6, body_len * 0.06);
boss_d = face_w * 0.45;
boss_t = max(1.2, front_plate_t * 0.8);
shaft_len = max(8.0, body_len * 0.35);
hole_d = 3.0;
hole_depth = front_plate_t + boss_t + 0.6; // ensure through front features
overlap = 0.2;

module rounded_box_xy(size=[20,20,30], r=1.5) {
    // Rounded in XY, straight in Z
    linear_extrude(height=size[2], center=true)
        offset(r=r)
            square([size[0]-2*r, size[1]-2*r], center=true);
}

module stepper_motor() {
    difference() {
        union() {
            // Main body centered at origin
            rounded_box_xy([face_w, face_w, body_len], corner_r);

            // Front plate (slightly proud of body), connected with small overlap
            translate([0, 0, body_len/2 + front_plate_t/2 - overlap])
                rounded_box_xy([face_w, face_w, front_plate_t], corner_r);

            // Front boss around shaft, connected
            translate([0, 0, body_len/2 + front_plate_t + boss_t/2 - overlap])
                cylinder(d=boss_d, h=boss_t, center=true);

            // Shaft protruding from front, connected
            translate([0, 0, body_len/2 + front_plate_t + boss_t + shaft_len/2 - overlap])
                cylinder(d=shaft_d, h=shaft_len, center=true);
        }

        // Mounting holes: subtract from front face inward (along -Z)
        for (x = [-1, 1])
            for (y = [-1, 1])
                translate([x*hole_spacing/2, y*hole_spacing/2,
                           body_len/2 + front_plate_t + boss_t - hole_depth/2 + 0.1])
                    cylinder(d=hole_d, h=hole_depth + 0.2, center=true);

        // Optional center recess around shaft (helps show detail in orthographic views)
        translate([0, 0, body_len/2 + front_plate_t + boss_t/2 - overlap])
            cylinder(d=boss_d*0.55, h=boss_t + 0.4, center=true);
    }
}

stepper_motor();