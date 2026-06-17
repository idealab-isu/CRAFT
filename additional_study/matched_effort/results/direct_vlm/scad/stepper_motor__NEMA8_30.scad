$fn = 96;

// Parameters
face_w = 20.0;          // square face width
body_len = 30.0;        // body length (excluding front boss/shaft)
shaft_d = 4.0;          // shaft diameter
mount_spacing = 16.0;   // mounting hole center-to-center spacing (square pattern)

// Typical small stepper details (reasonable defaults)
corner_r = 2.0;         // rounded corners on face
front_boss_d = 10.0;    // centering boss diameter
front_boss_h = 1.5;     // centering boss height
mount_hole_d = 2.2;     // clearance for M2-ish screws
shaft_len = 18.0;       // exposed shaft length
shaft_flat = 0.0;       // set >0 to add a flat (not used)

// Derived
half = face_w/2;
hole_off = mount_spacing/2;

module rounded_square_2d(w, r){
    // 2D rounded square centered at origin
    offset(r=r) offset(delta=-r)
        square([w, w], center=true);
}

module motor_body(){
    // Main body with rounded corners
    linear_extrude(height=body_len)
        rounded_square_2d(face_w, corner_r);
}

module front_face_features(){
    // Front boss
    translate([0,0,body_len])
        cylinder(d=front_boss_d, h=front_boss_h);

    // Shaft
    translate([0,0,body_len + front_boss_h])
        cylinder(d=shaft_d, h=shaft_len);
}

module mounting_holes(){
    // Through holes along body length (from front face through to back)
    for (x = [-hole_off, hole_off])
    for (y = [-hole_off, hole_off])
        translate([x,y,-0.5])
            cylinder(d=mount_hole_d, h=body_len + 1.0);
}

module stepper_motor(){
    difference(){
        motor_body();
        mounting_holes();
    }
    front_face_features();
}

stepper_motor();