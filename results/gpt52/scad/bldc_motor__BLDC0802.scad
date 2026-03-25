$fn=96;

stator_d = 11.5;
stator_h = 9.5;

can_wall = 0.6;
can_clear = 0.25;
can_d = stator_d + 2*(can_clear + can_wall);
can_h = stator_h + 2.0;

base_th = 1.2;

shaft_d = 2.0;
shaft_len = 12.0;

front_boss_d = 6.0;
front_boss_h = 1.2;

mount_hole_d = 1.6;
mount_hole_r = 4.0;
mount_hole_count = 4;

wire_d = 1.2;
wire_len = 10.0;
wire_spacing = 1.8;

module stator_core(d, h){
    difference(){
        cylinder(d=d, h=h, center=true);
        cylinder(d=shaft_d+0.6, h=h+0.4, center=true);
    }
}

module stator_teeth(d, h, tooth_count=12, tooth_w=1.0, tooth_rad=0.9){
    for(i=[0:tooth_count-1]){
        rotate([0,0,360/tooth_count*i])
            translate([d/2 - tooth_rad*0.6, 0, 0])
                cylinder(d=tooth_w, h=h, center=true);
    }
}

module rotor_can(od, h, wall){
    difference(){
        cylinder(d=od, h=h, center=true);
        translate([0,0,-0.2])
            cylinder(d=od-2*wall, h=h+0.6, center=true);
    }
}

module base_plate(d, th){
    cylinder(d=d, h=th, center=true);
}

module mount_holes(r, hole_d, th, count=4){
    for(i=[0:count-1]){
        rotate([0,0,360/count*i])
            translate([r,0,0])
                cylinder(d=hole_d, h=th+0.6, center=true);
    }
}

module shaft(d, len){
    translate([0,0,(len/2)])
        cylinder(d=d, h=len, center=true);
}

module wires(d, len, spacing){
    for(s=[-1,0,1]){
        translate([-(d*0.6), s*spacing, -(can_h/2 + len/2)])
            rotate([90,0,0])
                cylinder(d=d, h=len, center=true);
    }
}

module motor(){
    union(){
        difference(){
            union(){
                translate([0,0,-(can_h/2 - base_th/2)])
                    base_plate(d=can_d, th=base_th);

                translate([0,0,base_th/2])
                    rotor_can(od=can_d, h=can_h, wall=can_wall);

                translate([0,0,can_h/2 + front_boss_h/2])
                    cylinder(d=front_boss_d, h=front_boss_h, center=true);

                shaft(d=shaft_d, len=shaft_len);
            }
            translate([0,0,-(can_h/2 - base_th/2)])
                mount_holes(r=mount_hole_r, hole_d=mount_hole_d, th=base_th, count=mount_hole_count);
        }

        translate([0,0,base_th/2])
            union(){
                stator_core(d=stator_d, h=stator_h);
                stator_teeth(d=stator_d, h=stator_h, tooth_count=12, tooth_w=1.0, tooth_rad=0.9);
            }

        wires(d=wire_d, len=wire_len, spacing=wire_spacing);
    }
}

motor();