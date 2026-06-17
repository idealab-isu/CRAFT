$fn=96;

// Parameters (mm)
face_w = 42.3;          // motor face width (square)
body_len = 34.0;        // motor body length (excluding front boss/shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 22.0;       // typical protrusion
mount_spacing = 31.0;   // center-to-center mounting hole spacing
mount_hole_d = 3.2;     // typical for M3 clearance
corner_r = 3.0;         // typical NEMA-style corner radius

boss_d = 22.0;          // front pilot/boss diameter
boss_h = 2.0;           // boss height

// Small rear cable bulge (optional aesthetic)
rear_bulge_d = 18.0;
rear_bulge_h = 2.0;

module rounded_square_prism(w, h, r, center=false){
    // 2D rounded square via hull of corner circles, then linear_extrude
    linear_extrude(height=h, center=center)
        hull(){
            for (sx=[-1,1], sy=[-1,1])
                translate([sx*(w/2 - r), sy*(w/2 - r)]) circle(r=r);
        }
}

module stepper_motor(){
    difference(){
        union(){
            // Main body
            color([0.25,0.25,0.25])
                rounded_square_prism(face_w, body_len, corner_r, center=false);

            // Front boss (pilot)
            color([0.6,0.6,0.6])
                translate([0,0,body_len])
                    cylinder(d=boss_d, h=boss_h);

            // Shaft
            color([0.75,0.75,0.75])
                translate([0,0,body_len+boss_h])
                    cylinder(d=shaft_d, h=shaft_len);

            // Rear bulge
            color([0.2,0.2,0.2])
                translate([0,0,-rear_bulge_h])
                    cylinder(d=rear_bulge_d, h=rear_bulge_h);
        }

        // Mounting holes through front face into body
        for (x=[-mount_spacing/2, mount_spacing/2])
            for (y=[-mount_spacing/2, mount_spacing/2])
                translate([x,y,body_len-10]) // start slightly inside to avoid coincident faces
                    cylinder(d=mount_hole_d, h=20);
    }
}

stepper_motor();