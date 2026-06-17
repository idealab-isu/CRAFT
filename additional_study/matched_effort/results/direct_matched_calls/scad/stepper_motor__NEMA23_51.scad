$fn = 96;

// Parameters (mm)
face_w = 56.4;          // square face width
body_len = 51.2;        // motor body length (excluding front boss and shaft)
shaft_d = 6.35;         // shaft diameter
shaft_len = 22;         // visible shaft length
mount_spacing = 47.1;   // mounting hole center-to-center spacing (square pattern)

// Typical details (not provided; chosen to be reasonable)
corner_r = 3.0;         // body corner radius
front_boss_d = 22.0;    // front pilot/boss diameter
front_boss_h = 2.0;     // boss height
mount_hole_d = 3.5;     // clearance for M3
face_plate_th = 2.0;    // front face plate thickness (visual)
rear_cap_th = 2.0;      // rear cap thickness (visual)

module rounded_box_xy(size=[10,10,10], r=1) {
    // size = [x,y,z], centered at origin
    x = size[0]; y = size[1]; z = size[2];
    linear_extrude(height=z, center=true)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module stepper_motor() {
    // Body centered on XY, with front face at z=0 and body extending to +Z
    // We'll build with front at z=0 for easy mounting reference.
    union() {
        // Main body
        translate([0,0, body_len/2])
            rounded_box_xy([face_w, face_w, body_len], r=corner_r);

        // Front face plate (slightly proud)
        translate([0,0, face_plate_th/2])
            rounded_box_xy([face_w, face_w, face_plate_th], r=corner_r);

        // Rear cap (slightly proud)
        translate([0,0, body_len - rear_cap_th/2])
            rounded_box_xy([face_w, face_w, rear_cap_th], r=corner_r);

        // Front boss/pilot
        translate([0,0, front_boss_h/2])
            cylinder(d=front_boss_d, h=front_boss_h, center=true);

        // Shaft (extends out of front, negative Z)
        translate([0,0, -shaft_len/2])
            cylinder(d=shaft_d, h=shaft_len, center=true);
    }
}

module mounting_holes() {
    // Through-holes through front plate and into body a bit (visual)
    hole_depth = face_plate_th + 6;
    for (sx = [-1,1], sy = [-1,1]) {
        translate([sx*mount_spacing/2, sy*mount_spacing/2, hole_depth/2])
            cylinder(d=mount_hole_d, h=hole_depth, center=true);
    }
}

difference() {
    stepper_motor();
    mounting_holes();
}