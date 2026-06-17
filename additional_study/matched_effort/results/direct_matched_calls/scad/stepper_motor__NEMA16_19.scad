$fn = 96;

// Parameters (mm)
face_w = 39.5;          // square face width
body_len = 19.2;        // motor body length (excluding front boss and shaft)
shaft_d = 5.0;          // shaft diameter
mount_spacing = 31.0;   // mounting hole center-to-center spacing (square pattern)

// Typical NEMA-style details (not provided; chosen to be reasonable defaults)
corner_r = 3.0;         // body corner radius
front_boss_d = 22.0;    // front pilot/boss diameter
front_boss_h = 2.0;     // front pilot/boss height
mount_hole_d = 3.2;     // clearance for M3
shaft_len = 20.0;       // shaft protrusion length
face_plate_th = 2.0;    // front face plate thickness (visual detail)
back_cap_th = 1.5;      // back cap thickness (visual detail)

module rounded_square_prism(w, h, r){
    // centered on XY, extends from z=0..h
    linear_extrude(height=h)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module stepper_motor(){
    union(){
        // Main body
        color([0.25,0.25,0.25])
        rounded_square_prism(face_w, body_len, corner_r);

        // Front face plate (slight step)
        color([0.18,0.18,0.18])
        translate([0,0,0])
            rounded_square_prism(face_w, face_plate_th, corner_r);

        // Back cap (slight step)
        color([0.18,0.18,0.18])
        translate([0,0,body_len-back_cap_th])
            rounded_square_prism(face_w, back_cap_th, corner_r);

        // Front boss/pilot
        color([0.35,0.35,0.35])
        translate([0,0,0])
            cylinder(d=front_boss_d, h=front_boss_h);

        // Shaft
        color([0.75,0.75,0.75])
        translate([0,0,front_boss_h])
            cylinder(d=shaft_d, h=shaft_len);
    }
}

module mounting_holes(){
    // Through-holes along Z, starting at front face
    for (sx = [-1,1], sy = [-1,1]){
        translate([sx*mount_spacing/2, sy*mount_spacing/2, -0.5])
            cylinder(d=mount_hole_d, h=body_len + 1.0);
    }
}

difference(){
    stepper_motor();
    mounting_holes();
}