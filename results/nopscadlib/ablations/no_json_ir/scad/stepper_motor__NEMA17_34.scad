$fn = 96;

// Target dimensions (mm)
motor_face_w = 42.3;     // face width
motor_body_l = 34.0;     // body length (Z)
shaft_d     = 5.0;       // shaft diameter
mount_pitch = 31.0;      // mounting hole spacing (center-center)

// Detail parameters (kept reasonable, derived placements are formulas)
corner_r = 2.0;          // slight corner rounding
face_plate_t = 3.0;      // front plate thickness
pilot_d = 22.0;          // front pilot/boss diameter (typical NEMA17)
pilot_h = 2.0;           // pilot height
shaft_l = 20.0;          // visible shaft length
hole_d  = 3.5;           // mounting hole diameter
hole_depth = face_plate_t + 0.6; // cut through face plate with margin
eps = 0.2;               // overlap / boolean safety

module rounded_box_xy(size=[10,10,10], r=1) {
    // Rounded in XY, straight in Z
    w = size[0]; d = size[1]; h = size[2];
    r2 = min(r, min(w,d)/2 - 0.01);
    linear_extrude(height=h, center=true)
        offset(r=r2)
            square([w-2*r2, d-2*r2], center=true);
}

module stepper_motor() {
    union() {
        // Main body (centered at origin)
        rounded_box_xy([motor_face_w, motor_face_w, motor_body_l], r=corner_r);

        // Front face plate (connected with slight overlap)
        translate([0, 0, motor_body_l/2 + face_plate_t/2 - eps])
            rounded_box_xy([motor_face_w, motor_face_w, face_plate_t], r=corner_r);

        // Front pilot/boss (connected)
        translate([0, 0, motor_body_l/2 + face_plate_t + pilot_h/2 - eps])
            cylinder(h=pilot_h, d=pilot_d, center=true);

        // Shaft (connected to pilot with overlap)
        translate([0, 0, motor_body_l/2 + face_plate_t + pilot_h + shaft_l/2 - eps])
            cylinder(h=shaft_l, d=shaft_d, center=true);
    }
}

module mounting_holes_cut() {
    // Holes cut into the front face plate region
    for (x = [-1, 1])
        for (y = [-1, 1])
            translate([x*mount_pitch/2, y*mount_pitch/2,
                       motor_body_l/2 + face_plate_t/2 - eps])
                cylinder(h=hole_depth, d=hole_d, center=true);
}

difference() {
    stepper_motor();
    mounting_holes_cut();
}