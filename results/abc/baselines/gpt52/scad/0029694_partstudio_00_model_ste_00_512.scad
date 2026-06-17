$fn=64;

bbox_x = 0.1;
bbox_y = 0.1;
bbox_z = 0.01;

ring_od = 0.08;
ring_id = 0.04;
plate_t = bbox_z;

arm_len = 0.03;
arm_w  = 0.02;

clevis_len = 0.02;
clevis_w   = 0.02;
prong_w    = 0.006;
gap_w      = clevis_w - 2*prong_w;
u_depth    = 0.012;

module annulus(od, id, t){
    difference(){
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t+0.02, center=true);
    }
}

module arm_plate(len, w, t){
    translate([len/2,0,0]) cube([len,w,t], center=true);
}

module clevis_u_end(len, w, t, prong, udepth){
    difference(){
        translate([len/2,0,0]) cube([len,w,t], center=true);
        translate([len-udepth/2,0,0]) cube([udepth, w-2*prong, t+0.02], center=true);
    }
}

module horizontal_clevis(){
    union(){
        arm_plate(arm_len, arm_w, plate_t);
        translate([arm_len,0,0]) clevis_u_end(clevis_len, clevis_w, plate_t, prong_w, u_depth);
    }
}

module vertical_clevis(){
    rotate([0,0,90]) horizontal_clevis();
}

scale_factor = min(bbox_x/(ring_od + 2*(arm_len+clevis_len)), bbox_y/(ring_od + 2*(arm_len+clevis_len)));

scale([scale_factor, scale_factor, 1])
union(){
    annulus(ring_od, ring_id, plate_t);
    horizontal_clevis();
    vertical_clevis();
}