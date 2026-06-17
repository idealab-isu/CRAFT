$fn = 96;

// Target dimensions (mm)
motor_face_w   = 42.3;   // square face width
motor_body_l   = 47.0;   // body length (front face to back)
shaft_d        = 5.0;    // shaft diameter
hole_spacing   = 31.0;   // mounting hole center-to-center spacing

// Detail dimensions (reasonable NEMA17-like features)
front_plate_t  = 3.0;    // front face plate thickness
boss_d         = 22.0;   // front pilot/boss diameter
boss_h         = 2.0;    // boss height
shaft_l        = 20.0;   // shaft length protruding from boss
hole_d         = 3.5;    // mounting hole diameter
corner_r       = 2.0;    // slight corner rounding
eps            = 0.2;    // overlap to ensure connectivity

module rounded_box_xy(size=[10,10,10], r=1, center=true) {
    // Rounded in XY, straight in Z
    w = size[0]; d = size[1]; h = size[2];
    translate(center ? [0,0,0] : [w/2, d/2, h/2])
        linear_extrude(height=h, center=true)
            offset(r=r)
                square([w-2*r, d-2*r], center=true);
}

module stepper_motor() {
    // Place front face at z=0, body extends to negative z, shaft to positive z
    difference() {
        union() {
            // Main body (connected to front plate)
            translate([0,0,-motor_body_l/2])
                rounded_box_xy([motor_face_w, motor_face_w, motor_body_l], r=corner_r, center=true);

            // Front plate (overlaps body slightly to guarantee union)
            translate([0,0,front_plate_t/2 - eps])
                rounded_box_xy([motor_face_w, motor_face_w, front_plate_t], r=corner_r, center=true);

            // Front boss/pilot (overlaps front plate)
            translate([0,0,front_plate_t + boss_h/2 - eps])
                cylinder(h=boss_h, d=boss_d, center=true);

            // Output shaft (overlaps boss)
            translate([0,0,front_plate_t + boss_h + shaft_l/2 - eps])
                cylinder(h=shaft_l, d=shaft_d, center=true);
        }

        // Mounting holes through front plate (and slightly into body for clean cut)
        for (x = [-1, 1])
            for (y = [-1, 1])
                translate([x*hole_spacing/2, y*hole_spacing/2, front_plate_t/2 - eps])
                    cylinder(h=front_plate_t + 2*eps, d=hole_d, center=true);

        // Optional shallow front recess ring to add recognizable face detail
        translate([0,0,front_plate_t/2 - eps])
            difference() {
                cylinder(h=front_plate_t + 2*eps, d=boss_d + 10, center=true);
                cylinder(h=front_plate_t + 2*eps + 0.1, d=boss_d + 4, center=true);
            }
    }
}

stepper_motor();