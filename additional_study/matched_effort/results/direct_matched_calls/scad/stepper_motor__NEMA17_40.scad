$fn = 96;

// Parameters (mm)
face_w = 42.3;          // motor face width (square)
body_len = 40.0;        // motor body length (excluding front boss/shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 22.0;       // typical protrusion
mount_spacing = 31.0;   // mounting hole spacing (center-to-center)
mount_hole_d = 3.2;     // typical for M3 clearance
front_boss_d = 22.0;    // typical NEMA17 pilot diameter
front_boss_h = 2.0;     // typical pilot height
corner_r = 3.0;         // body corner radius (approx)
face_plate_th = 2.0;    // front face plate thickness (visual)
back_cap_th = 1.5;      // back cap thickness (visual)

module rounded_square_prism(w, h, r, center=false) {
    // 2D rounded square via offset, then linear_extrude
    linear_extrude(height=h, center=center)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module stepper_motor() {
    // Body (rounded square)
    color([0.25,0.25,0.27])
    translate([0,0,0])
    rounded_square_prism(face_w, body_len, corner_r, center=false);

    // Front face plate (slightly different shade)
    color([0.18,0.18,0.20])
    translate([0,0,0])
    linear_extrude(height=face_plate_th)
        offset(r=corner_r)
            square([face_w-2*corner_r, face_w-2*corner_r], center=true);

    // Back cap
    color([0.18,0.18,0.20])
    translate([0,0,body_len-back_cap_th])
    linear_extrude(height=back_cap_th)
        offset(r=corner_r)
            square([face_w-2*corner_r, face_w-2*corner_r], center=true);

    // Front boss (pilot)
    color([0.65,0.65,0.68])
    translate([0,0,face_plate_th])
    cylinder(d=front_boss_d, h=front_boss_h);

    // Shaft
    color([0.75,0.75,0.78])
    translate([0,0,face_plate_th+front_boss_h])
    cylinder(d=shaft_d, h=shaft_len);

    // Mounting holes (through front plate into body for visualization)
    // NEMA17 holes are typically on a 31mm square pattern.
    hole_depth = face_plate_th + 6; // shallow holes for appearance
    for (sx = [-1,1], sy = [-1,1]) {
        translate([sx*mount_spacing/2, sy*mount_spacing/2, 0])
        color([0.05,0.05,0.05])
        cylinder(d=mount_hole_d, h=hole_depth);
    }
}

difference() {
    stepper_motor();

    // Actually subtract the mounting holes from the body/face
    hole_depth = face_plate_th + 6;
    for (sx = [-1,1], sy = [-1,1]) {
        translate([sx*mount_spacing/2, sy*mount_spacing/2, -0.1])
            cylinder(d=mount_hole_d, h=hole_depth+0.2);
    }
}