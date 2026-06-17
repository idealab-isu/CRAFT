$fn = 96;

// Parameters (mm)
face_w = 42.3;          // square face width
body_len = 26.5;        // motor body length (excluding shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 20.0;       // assumed visible shaft length
mount_spacing = 31.0;   // center-to-center mounting hole spacing
mount_hole_d = 3.2;     // typical NEMA17 clearance (assumed)
corner_r = 3.0;         // assumed corner radius
front_plate_th = 2.0;   // assumed front plate thickness
boss_d = 22.0;          // assumed front boss diameter
boss_h = 2.0;           // assumed boss height

module rounded_square_prism(w, h, r, center=false) {
    linear_extrude(height=h, center=center)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module motor_body() {
    // Main body
    color([0.25,0.25,0.27])
    translate([0,0,body_len/2])
        rounded_square_prism(face_w, body_len, corner_r, center=true);

    // Front plate
    color([0.35,0.35,0.38])
    translate([0,0,front_plate_th/2])
        rounded_square_prism(face_w, front_plate_th, corner_r, center=true);

    // Front boss
    color([0.55,0.55,0.58])
    translate([0,0,front_plate_th])
        cylinder(d=boss_d, h=boss_h);

    // Shaft
    color([0.75,0.75,0.78])
    translate([0,0,front_plate_th + boss_h])
        cylinder(d=shaft_d, h=shaft_len);
}

module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mount_spacing/2, sy*mount_spacing/2, -0.5])
            cylinder(d=mount_hole_d, h=front_plate_th + 1.0);
    }
}

difference() {
    motor_body();
    mounting_holes();
}