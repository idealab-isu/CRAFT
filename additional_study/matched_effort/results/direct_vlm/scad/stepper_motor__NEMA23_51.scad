$fn=96;

// Parameters (mm)
face_w = 56.4;          // square face width
body_len = 51.2;        // motor body length (excluding shaft)
shaft_d = 6.35;         // shaft diameter
shaft_len = 20;         // assumed visible shaft length
mount_spacing = 47.1;   // center-to-center mounting hole spacing
mount_hole_d = 4.2;     // typical NEMA mounting clearance (assumed)
front_plate_th = 3;     // assumed front plate thickness
boss_d = 22;            // assumed pilot/boss diameter
boss_h = 2;             // assumed boss height
corner_r = 3;           // assumed corner radius

module rounded_square(w, r){
    // 2D rounded square centered at origin
    offset(r=r) offset(delta=-r)
        square([w, w], center=true);
}

module motor_body(){
    // Main body with rounded corners
    linear_extrude(height=body_len)
        rounded_square(face_w, corner_r);
}

module front_features(){
    // Front plate (slightly proud)
    translate([0,0,body_len-front_plate_th])
        linear_extrude(height=front_plate_th)
            rounded_square(face_w, corner_r);

    // Pilot/boss
    translate([0,0,body_len])
        cylinder(d=boss_d, h=boss_h);

    // Shaft
    translate([0,0,body_len+boss_h])
        cylinder(d=shaft_d, h=shaft_len);
}

module mounting_holes(){
    // Through holes along body length (for visualization/clearance)
    for (x = [-mount_spacing/2, mount_spacing/2])
        for (y = [-mount_spacing/2, mount_spacing/2])
            translate([x,y,-1])
                cylinder(d=mount_hole_d, h=body_len+front_plate_th+boss_h+shaft_len+2);
}

difference(){
    union(){
        motor_body();
        front_features();
    }
    mounting_holes();
}