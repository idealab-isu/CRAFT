$fn=96;

shaft_d = 8.0;
base_l = 55.0;
base_w = 42.0;

base_h = 8.0;
pedestal_l = 34.0;
pedestal_w = 30.0;
pedestal_h = 18.0;

bore_center_z = base_h + pedestal_h*0.62;
bore_d = shaft_d + 0.4;
bore_len = base_w + 2.0;

cap_outer_d = 26.0;
cap_len = pedestal_w + 6.0;

mount_hole_d = 6.5;
mount_hole_x = 19.0;
mount_hole_y = 14.0;

set_screw_d = 3.2;
set_screw_len = 18.0;
set_screw_z = bore_center_z + 6.0;

module rounded_block(l,w,h,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(l/2-r), sy*(w/2-r), 0])
                cylinder(h=h, r=r);
        }
    }
}

module base(){
    rounded_block(base_l, base_w, base_h, 4.0);
}

module pedestal(){
    translate([0,0,base_h])
        rounded_block(pedestal_l, pedestal_w, pedestal_h, 3.0);
}

module cap_body(){
    translate([0,0,bore_center_z])
        rotate([90,0,0])
            cylinder(h=cap_len, d=cap_outer_d, center=true);
}

module mount_holes(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_x, sy*mount_hole_y, -1])
            cylinder(h=base_h+2, d=mount_hole_d);
    }
}

module bore(){
    translate([0,0,bore_center_z])
        rotate([90,0,0])
            cylinder(h=bore_len, d=bore_d, center=true);
}

module relief_cut(){
    translate([0,0,bore_center_z])
        rotate([90,0,0])
            cylinder(h=cap_len+2, d=cap_outer_d-6.0, center=true);
}

module set_screw_hole(){
    translate([0,0,set_screw_z])
        rotate([0,90,0])
            cylinder(h=set_screw_len, d=set_screw_d, center=true);
}

difference(){
    union(){
        base();
        pedestal();
        cap_body();
    }
    mount_holes();
    bore();
    relief_cut();
    set_screw_hole();
}