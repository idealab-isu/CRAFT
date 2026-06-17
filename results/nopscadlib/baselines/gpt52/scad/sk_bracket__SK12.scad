$fn=64;

rod_d = 12.0;
height = 23.0;

base_len = 50.0;
base_wid = 30.0;
base_thk = 8.0;

post_wid = 18.0;
post_thk = 14.0;

clamp_od = 24.0;
clamp_len = post_thk;

bolt_d = 5.0;
bolt_head_d = 9.5;
bolt_head_h = 3.0;

mount_hole_d = 5.5;
mount_hole_spacing = 30.0;
mount_hole_edge_y = 10.0;

slot_w = 2.5;

module counterbore_hole(d_through, d_cb, h_cb, h_total){
    union(){
        cylinder(d=d_through, h=h_total+0.2, center=true);
        translate([0,0,(h_total-h_cb)/2])
            cylinder(d=d_cb, h=h_cb+0.2, center=true);
    }
}

module base_plate(){
    translate([0,0,-(height/2 - base_thk/2)])
        cube([base_len, base_wid, base_thk], center=true);
}

module upright_post(){
    zc = -height/2 + base_thk + (height - base_thk)/2;
    translate([0,0,zc])
        cube([post_wid, post_thk, height - base_thk], center=true);
}

module clamp_block(){
    zc = height/2 - clamp_od/2;
    translate([0,0,zc])
        rotate([90,0,0])
            cylinder(d=clamp_od, h=clamp_len, center=true);
}

module body(){
    union(){
        base_plate();
        upright_post();
        clamp_block();
    }
}

module rod_bore(){
    zc = height/2 - clamp_od/2;
    translate([0,0,zc])
        rotate([90,0,0])
            cylinder(d=rod_d, h=clamp_len+2, center=true);
}

module clamp_slot(){
    zc = height/2 - clamp_od/2;
    translate([0,0,zc])
        cube([slot_w, clamp_len+2, clamp_od+2], center=true);
}

module clamp_bolt_hole(){
    zc = height/2 - clamp_od/2;
    translate([0,0,zc])
        rotate([0,90,0])
            counterbore_hole(bolt_d, bolt_head_d, bolt_head_h, clamp_od+4);
}

module mount_holes(){
    z_base = -(height/2 - base_thk/2);
    for(x=[-mount_hole_spacing/2, mount_hole_spacing/2]){
        translate([x, base_wid/2 - mount_hole_edge_y, z_base])
            cylinder(d=mount_hole_d, h=base_thk+0.6, center=true);
        translate([x, -(base_wid/2 - mount_hole_edge_y), z_base])
            cylinder(d=mount_hole_d, h=base_thk+0.6, center=true);
    }
}

difference(){
    body();
    rod_bore();
    clamp_slot();
    clamp_bolt_hole();
    mount_holes();
}