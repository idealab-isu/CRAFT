$fn = 96;

// Parameters (mm)
face_w = 42.3;          // square face width
body_len = 40.0;        // motor body length (excluding front boss/shaft)
shaft_d = 8.0;          // shaft diameter
shaft_len = 22.0;       // typical protrusion
mount_spacing = 31.0;   // hole center-to-center spacing
mount_hole_d = 3.2;     // typical for M3 clearance
front_boss_d = 22.0;    // typical NEMA17 pilot
front_boss_h = 2.0;     // typical pilot height
corner_r = 3.0;         // rounded corners (approx)
face_th = 3.0;          // front face plate thickness (visual)
back_cap_th = 2.0;      // back cap thickness (visual)

module rounded_square_2d(w, r){
    // Rounded rectangle centered at origin
    offset(r=r) offset(delta=-r)
        square([w, w], center=true);
}

module motor_body(){
    // Main body with rounded corners
    color([0.25,0.25,0.27])
    linear_extrude(height=body_len)
        rounded_square_2d(face_w, corner_r);
}

module front_face_features(){
    // Front face plate (slight visual step)
    color([0.20,0.20,0.22])
    translate([0,0,0])
    linear_extrude(height=face_th)
        rounded_square_2d(face_w, corner_r);

    // Front boss/pilot
    color([0.65,0.65,0.68])
    translate([0,0,face_th])
        cylinder(d=front_boss_d, h=front_boss_h);

    // Shaft
    color([0.75,0.75,0.78])
    translate([0,0,face_th + front_boss_h])
        cylinder(d=shaft_d, h=shaft_len);
}

module mounting_holes(){
    // Through holes in the front face region (visual)
    for (sx = [-1,1], sy = [-1,1]){
        translate([sx*mount_spacing/2, sy*mount_spacing/2, -0.1])
            cylinder(d=mount_hole_d, h=face_th + front_boss_h + 0.2);
    }
}

module back_cap(){
    // Slight back cap step
    color([0.18,0.18,0.20])
    translate([0,0,body_len - back_cap_th])
        linear_extrude(height=back_cap_th)
            rounded_square_2d(face_w, corner_r);
}

module stepper_motor(){
    // Body
    motor_body();

    // Back cap
    back_cap();

    // Front face + boss + shaft, with mounting holes cut
    difference(){
        front_face_features();
        mounting_holes();
    }
}

stepper_motor();