$fn = 96;

// Parameters (mm)
face_w = 42.3;          // motor face width (square)
body_len = 34.0;        // motor body length (excluding front boss/shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 22.0;       // typical protrusion
mount_spacing = 31.0;   // center-to-center mounting hole spacing
mount_hole_d = 3.2;     // typical for M3 clearance
front_boss_d = 22.0;    // typical NEMA17 pilot
front_boss_h = 2.0;     // typical pilot height
corner_r = 3.0;         // slight corner radius for body

module rounded_square(size=42.3, r=3.0, center=true){
    s = size;
    rr = min(r, s/2);
    if (rr <= 0)
        square([s,s], center=center);
    else
        offset(r=rr) offset(delta=-rr) square([s,s], center=center);
}

module motor_body(){
    // Main body with rounded corners
    difference(){
        linear_extrude(height=body_len, center=false)
            rounded_square(face_w, corner_r, center=true);

        // Mounting holes through the face/body (along Z)
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x,y,-0.5])
                    cylinder(d=mount_hole_d, h=body_len+1.0);
    }
}

module front_features(){
    // Front boss (pilot)
    translate([0,0,body_len])
        cylinder(d=front_boss_d, h=front_boss_h);

    // Shaft
    translate([0,0,body_len+front_boss_h])
        cylinder(d=shaft_d, h=shaft_len);
}

module stepper_motor(){
    color([0.25,0.25,0.27]) motor_body();
    color([0.65,0.65,0.68]) front_features();
}

stepper_motor();