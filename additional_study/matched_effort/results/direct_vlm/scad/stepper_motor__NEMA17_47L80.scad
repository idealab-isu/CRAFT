$fn = 96;

// Parameters (mm)
face_w = 42.3;          // motor face width (square)
body_len = 47.0;        // motor body length (excluding front boss/shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 22.0;       // visible shaft length
mount_spacing = 31.0;   // mounting hole center-to-center spacing
mount_hole_d = 3.2;     // typical NEMA17 clearance for M3
corner_r = 3.0;         // body corner radius (approx)
front_boss_d = 22.0;    // typical pilot/boss diameter
front_boss_len = 2.0;   // boss thickness

module rounded_square_prism(w, h, r){
    // centered in X/Y, extends from z=0..h
    linear_extrude(height=h)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module stepper_motor(){
    // Body
    color([0.25,0.25,0.25])
    difference(){
        rounded_square_prism(face_w, body_len, corner_r);

        // Mounting holes through body (along Z)
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x,y,-0.5])
                    cylinder(d=mount_hole_d, h=body_len+1.0);
    }

    // Front boss (pilot)
    color([0.55,0.55,0.55])
    translate([0,0,body_len])
        cylinder(d=front_boss_d, h=front_boss_len);

    // Shaft
    color([0.75,0.75,0.75])
    translate([0,0,body_len+front_boss_len])
        cylinder(d=shaft_d, h=shaft_len);
}

stepper_motor();