$fn = 64;

body_w = 27;
body_h = 46.8;
body_d = 16.5;

flange_w = 33;
flange_h = 57;
flange_t = 3;

screw_pitch = 40;
screw_d = 3.6;          // clearance
screw_csk_d = 7.5;      // simple countersink/counterbore-like relief
screw_csk_h = 1.8;

edge_r = 2.0;

module rounded_rect_prism(w,h,d,r){
    r2 = min(r, w/2, h/2);
    linear_extrude(height=d)
        offset(r=r2)
            square([w-2*r2, h-2*r2], center=true);
}

module iec_inlet_solid(){
    union(){
        // Body behind flange
        translate([0,0,-(flange_t + body_d/2)])
            rounded_rect_prism(body_w, body_h, body_d, 1.6);

        // Flange
        translate([0,0,-flange_t/2])
            rounded_rect_prism(flange_w, flange_h, flange_t, edge_r);
    }
}

module iec_inlet_with_mount_holes(){
    difference(){
        iec_inlet_solid();

        // Mounting holes through flange (along height direction)
        for (y = [-screw_pitch/2, screw_pitch/2]){
            // Through hole
            translate([0,y,-flange_t/2])
                cylinder(d=screw_d, h=flange_t + 0.4, center=true);

            // Shallow relief on front face
            translate([0,y,-(screw_csk_h/2)])
                cylinder(d=screw_csk_d, h=screw_csk_h + 0.2, center=true);
        }

        // Small lip relief at body/flange transition (optional but keeps it non-empty)
        translate([0,0,-(flange_t + 0.2)])
            rounded_rect_prism(body_w+0.6, body_h+0.6, 0.6, 1.2);
    }
}

// Top-level call (exercise modules)
iec_inlet_with_mount_holes();