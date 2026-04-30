$fn=64;

module shaft_coupler_5_to_8(
    body_d=19,
    body_h=25,
    bore1_d=5.2,
    bore2_d=8.2,
    bore_depth=12.5,
    center_gap=1.0,
    set_screw_d=3.2,
    set_screw_head_d=6.2,
    set_screw_head_h=2.2,
    set_screw_z_offset=5.5,
    slit_w=1.2,
    slit_depth=3.0,
    slit_len=18,
    chamfer_h=1.0
){
    difference(){
        union(){
            cylinder(d=body_d, h=body_h, center=true);
        }

        // Axial bores (5mm side and 8mm side), separated by a small gap
        translate([0,0, (body_h/2) - (bore_depth/2)])
            cylinder(d=bore1_d, h=bore_depth, center=true);

        translate([0,0, -(body_h/2) + (bore_depth/2)])
            cylinder(d=bore2_d, h=bore_depth, center=true);

        // Center gap (prevents bottoming out)
        cylinder(d=max(bore1_d,bore2_d)+1.0, h=center_gap, center=true);

        // Set screw holes: two per side, 90 degrees apart
        for (side=[1,-1]){
            for (a=[0,90]){
                rotate([0,0,a])
                translate([0,0, side*set_screw_z_offset])
                rotate([0,90,0]){
                    // through hole
                    cylinder(d=set_screw_d, h=body_d+2, center=true);
                    // counterbore for head (one side)
                    translate([0,0,(body_d/2)-(set_screw_head_h/2)])
                        cylinder(d=set_screw_head_d, h=set_screw_head_h, center=true);
                }
            }
        }

        // Flexible helical-ish slits: alternating angular positions along Z
        for (i=[0:5]){
            zpos = -slit_len/2 + i*(slit_len/5);
            ang  = (i%2==0) ? 25 : -25;
            rotate([0,0,ang])
            translate([0,0,zpos])
            rotate([0,0, i*30])
            translate([body_d/2 - slit_depth/2, 0, 0])
                cube([slit_depth, slit_w, body_h], center=true);
        }

        // Additional straight slits (4 around) to increase flexibility
        for (a=[0,90,180,270]){
            rotate([0,0,a])
            translate([body_d/2 - slit_depth/2, 0, 0])
                cube([slit_depth, slit_w, slit_len], center=true);
        }

        // Chamfers (simple conical cuts)
        translate([0,0, body_h/2 - chamfer_h/2])
            cylinder(d1=body_d+1.0, d2=body_d-2.0, h=chamfer_h, center=true);
        translate([0,0,-body_h/2 + chamfer_h/2])
            cylinder(d1=body_d-2.0, d2=body_d+1.0, h=chamfer_h, center=true);
    }
}

shaft_coupler_5_to_8();