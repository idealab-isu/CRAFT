$fn=96;

bbox_x = 92.7;
bbox_y = 67.7;
bbox_z = 10.8;

plate_t = 4.0;
boss_h = bbox_z - plate_t;

center_plate_x = 28.0;
center_plate_y = 18.0;

arm_w = 12.0;

lug_od = 16.0;
hole_d = 5.2;

lug_center_x = bbox_x/2 - lug_od/2;
lug_center_y = bbox_y/2 - lug_od/2;

module lug_with_hole(od, h, hole_d){
    difference(){
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.2]) cylinder(d=hole_d, h=h+0.4, center=false);
    }
}

module arm_to_lug(xc, yc, w, t){
    hull(){
        translate([0,0,0]) cube([w,w,t], center=true);
        translate([xc,yc,0]) cube([w,w,t], center=true);
    }
}

module base_plate(){
    union(){
        cube([center_plate_x, center_plate_y, plate_t], center=true);

        arm_to_lug( lug_center_x,  lug_center_y, arm_w, plate_t);
        arm_to_lug(-lug_center_x,  lug_center_y, arm_w, plate_t);
        arm_to_lug(-lug_center_x, -lug_center_y, arm_w, plate_t);
        arm_to_lug( lug_center_x, -lug_center_y, arm_w, plate_t);
    }
}

module bosses(){
    translate([0,0,plate_t/2])
    union(){
        translate([ lug_center_x,  lug_center_y, 0]) lug_with_hole(lug_od, boss_h, hole_d);
        translate([-lug_center_x,  lug_center_y, 0]) lug_with_hole(lug_od, boss_h, hole_d);
        translate([-lug_center_x, -lug_center_y, 0]) lug_with_hole(lug_od, boss_h, hole_d);
        translate([ lug_center_x, -lug_center_y, 0]) lug_with_hole(lug_od, boss_h, hole_d);
    }
}

union(){
    base_plate();
    bosses();
}