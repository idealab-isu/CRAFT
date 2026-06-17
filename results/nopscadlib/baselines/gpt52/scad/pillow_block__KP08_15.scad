$fn=96;

shaft_d = 8.0;
base_x = 55.0;
base_y = 42.0;

base_th = 8.0;

ped_x = 34.0;
ped_y = 30.0;
ped_h = 18.0;

boss_d = 28.0;
boss_len = ped_y;

bearing_od = 22.0;
bearing_len = 7.0;

clearance = 0.25;
shaft_clear_d = shaft_d + 2*clearance;

mount_hole_d = 6.5;
mount_hole_x = 40.0;
mount_hole_y = 26.0;

edge_r = 3.0;

module rounded_plate(x,y,h,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(h=h, r=r);
    }
}

module base_block(){
    rounded_plate(base_x, base_y, base_th, edge_r);
}

module pedestal(){
    translate([0,0,base_th])
        rounded_plate(ped_x, ped_y, ped_h, 2.5);
}

module boss(){
    translate([0,0,base_th + ped_h/2])
        rotate([90,0,0])
            cylinder(h=boss_len, d=boss_d, center=true);
}

module mount_holes(){
    for (sx=[-1,1], sy=[-1,1])
        translate([sx*mount_hole_x/2, sy*mount_hole_y/2, -0.5])
            cylinder(h=base_th+1.0, d=mount_hole_d);
}

module bearing_bore(){
    translate([0,0,base_th + ped_h/2])
        rotate([90,0,0])
            cylinder(h=boss_len+2.0, d=bearing_od + 0.4, center=true);
}

module bearing_seat(){
    translate([0,0,base_th + ped_h/2])
        rotate([90,0,0])
            cylinder(h=bearing_len, d=bearing_od + 0.2, center=true);
}

module shaft_bore(){
    translate([0,0,base_th + ped_h/2])
        rotate([90,0,0])
            cylinder(h=boss_len+4.0, d=shaft_clear_d, center=true);
}

module relief_slot(){
    slot_w = 2.0;
    slot_h = boss_d*0.9;
    translate([0, boss_len/2 - 1.0, base_th + ped_h/2])
        rotate([90,0,0])
            translate([0,0,0])
                cube([slot_w, slot_h, 3.0], center=true);
}

difference(){
    union(){
        base_block();
        pedestal();
        boss();
    }
    mount_holes();
    bearing_bore();
    bearing_seat();
    shaft_bore();
    relief_slot();
}