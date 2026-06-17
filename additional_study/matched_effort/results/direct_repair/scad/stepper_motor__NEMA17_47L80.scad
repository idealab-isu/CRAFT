$fn=96;

// Parameters (mm)
face_w = 42.3;          // square face width
body_len = 47.0;        // body length (excluding front boss and shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 22.0;       // typical protrusion
mount_spacing = 31.0;   // hole center-to-center spacing
mount_hole_d = 3.2;     // typical for M3 clearance
front_boss_d = 22.0;    // typical NEMA17 pilot
front_boss_h = 2.0;     // typical pilot height
corner_r = 3.0;         // slight rounding
face_plate_th = 2.0;    // front face thickness detail
back_cap_th = 1.5;      // rear cap detail

// Helpers
module rounded_square_prism(w, h, r, center=false){
    // 2D rounded square via hull of circles, then linear_extrude
    linear_extrude(height=h, center=center)
        hull(){
            for (sx=[-1,1], sy=[-1,1])
                translate([sx*(w/2 - r), sy*(w/2 - r)]) circle(r=r);
        }
}

module motor_body(){
    // Main body with subtle front/back caps
    union(){
        // Main can
        rounded_square_prism(face_w, body_len, corner_r, center=false);

        // Front face plate (slightly proud)
        translate([0,0,-face_plate_th])
            rounded_square_prism(face_w, face_plate_th, corner_r, center=false);

        // Rear cap (slightly proud)
        translate([0,0,body_len])
            rounded_square_prism(face_w, back_cap_th, corner_r, center=false);
    }
}

module mount_holes(){
    for (x=[-mount_spacing/2, mount_spacing/2])
        for (y=[-mount_spacing/2, mount_spacing/2])
            translate([x,y,-face_plate_th-0.5])
                cylinder(d=mount_hole_d, h=face_plate_th+front_boss_h+2.0, center=false);
}

module front_boss(){
    translate([0,0,0])
        cylinder(d=front_boss_d, h=front_boss_h, center=false);
}

module shaft(){
    translate([0,0,-(shaft_len)])
        cylinder(d=shaft_d, h=shaft_len + front_boss_h + 0.01, center=false);
}

// Assemble with origin at motor face center, Z+ into body, Z- out of shaft
difference(){
    union(){
        motor_body();
        front_boss();
        shaft();
    }
    mount_holes();
}