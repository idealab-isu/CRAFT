$fn=96;

// Parameters (mm)
face_w = 35.2;          // square face width
body_len = 36.0;        // body length (excluding front boss and shaft)
shaft_d = 5.0;          // shaft diameter
mount_spacing = 26.0;   // mounting hole center-to-center spacing (square pattern)

// Common NEMA-ish details (reasonable defaults)
corner_r = 2.0;         // body corner radius
front_boss_d = 22.0;    // front pilot/boss diameter
front_boss_h = 2.0;     // front pilot/boss height
mount_hole_d = 3.2;     // clearance for M3
shaft_len = 20.0;       // exposed shaft length
shaft_flat = 0.0;       // set >0 to add a flat (not requested)

// Helpers
module rounded_square_prism(w, h, r){
    linear_extrude(height=h)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module motor_body(){
    // Main body
    color([0.25,0.25,0.27])
    difference(){
        rounded_square_prism(face_w, body_len, corner_r);

        // Mounting holes through body (from front face)
        for (x = [-mount_spacing/2, mount_spacing/2])
        for (y = [-mount_spacing/2, mount_spacing/2])
            translate([x,y,-0.5])
                cylinder(d=mount_hole_d, h=body_len+1.0);
    }

    // Front boss
    color([0.65,0.65,0.68])
    translate([0,0,body_len])
        cylinder(d=front_boss_d, h=front_boss_h);

    // Shaft
    color([0.75,0.75,0.78])
    translate([0,0,body_len+front_boss_h])
        cylinder(d=shaft_d, h=shaft_len);
}

motor_body();