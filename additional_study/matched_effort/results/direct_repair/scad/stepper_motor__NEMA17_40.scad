$fn=96;

// Parameters (mm)
face_w = 42.3;          // motor face width (square)
body_len = 40.0;        // motor body length (excluding front boss and shaft)
shaft_d = 5.0;          // shaft diameter
mount_spacing = 31.0;   // mounting hole center-to-center spacing (square pattern)

// Common NEMA17-ish details (reasonable defaults)
corner_r = 3.0;         // body corner radius
front_boss_d = 22.0;    // front pilot/boss diameter
front_boss_h = 2.0;     // boss height
mount_hole_d = 3.2;     // clearance for M3
shaft_len = 24.0;       // shaft protrusion length from front face
shaft_flat = 0.0;       // set >0 for D-shaft flat depth (0 = round)

// Helpers
module rounded_square_prism(w, h, r){
    // centered in X/Y, extends from z=0..h
    linear_extrude(height=h)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module d_shaft(d=5, len=20, flat=0){
    // flat is radial depth removed from one side (0 => round)
    if(flat <= 0){
        cylinder(d=d, h=len);
    } else {
        difference(){
            cylinder(d=d, h=len);
            translate([d/2 - flat, 0, -0.5])
                cube([d, d*2, len+1], center=false);
        }
    }
}

module stepper_motor(){
    difference(){
        union(){
            // Body
            rounded_square_prism(face_w, body_len, corner_r);

            // Front boss (pilot)
            translate([0,0,body_len])
                cylinder(d=front_boss_d, h=front_boss_h);

            // Shaft
            translate([0,0,body_len + front_boss_h])
                d_shaft(d=shaft_d, len=shaft_len, flat=shaft_flat);
        }

        // Mounting holes through body (from front face backward)
        for(x=[-mount_spacing/2, mount_spacing/2])
            for(y=[-mount_spacing/2, mount_spacing/2])
                translate([x,y,-0.5])
                    cylinder(d=mount_hole_d, h=body_len + front_boss_h + 1.0);
    }
}

stepper_motor();