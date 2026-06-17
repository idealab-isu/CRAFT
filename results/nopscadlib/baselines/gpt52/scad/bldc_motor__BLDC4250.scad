$fn=96;

stator_d = 42.5;
motor_h = 48.0;

housing_wall = 1.6;
housing_d = stator_d + 2*housing_wall + 2.0;  // slight clearance around stator
housing_h = motor_h;

endcap_th = 2.0;
front_boss_d = 18.0;
front_boss_h = 2.0;

shaft_d = 5.0;
shaft_len_front = 18.0;
shaft_len_back = 6.0;

mount_hole_d = 3.0;
mount_circle_d = 32.0;
mount_hole_depth = 4.0;

wire_exit_w = 8.0;
wire_exit_h = 4.0;
wire_exit_depth = 6.0;

stator_h = motor_h - 2*endcap_th;
stator_id = 24.0;

module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module bolt_holes_front(){
    for(a=[0:90:270]){
        rotate([0,0,a])
            translate([mount_circle_d/2,0,housing_h/2 - endcap_th/2])
                cylinder(d=mount_hole_d, h=mount_hole_depth, center=true);
    }
}

module motor_body(){
    difference(){
        union(){
            cylinder(d=housing_d, h=housing_h, center=true);
            translate([0,0,housing_h/2 - endcap_th/2])
                cylinder(d=housing_d+0.6, h=endcap_th, center=true);
            translate([0,0,-housing_h/2 + endcap_th/2])
                cylinder(d=housing_d+0.6, h=endcap_th, center=true);
            translate([0,0,housing_h/2 + front_boss_h/2 - endcap_th])
                cylinder(d=front_boss_d, h=front_boss_h, center=true);
        }

        translate([0,0,0])
            cylinder(d=housing_d-2*housing_wall, h=housing_h-2*endcap_th+0.2, center=true);

        bolt_holes_front();

        translate([housing_d/2 - housing_wall/2, 0, -housing_h/2 + 10])
            rotate([0,90,0])
                cube([wire_exit_depth, wire_exit_w, wire_exit_h], center=true);
    }
}

module stator(){
    translate([0,0,0])
        ring(stator_d, stator_id, stator_h);
}

module rotor(){
    rotor_d = stator_id - 1.0;
    rotor_h = stator_h - 2.0;
    translate([0,0,0])
        cylinder(d=rotor_d, h=rotor_h, center=true);
}

module shaft(){
    union(){
        translate([0,0,housing_h/2 + shaft_len_front/2 - endcap_th])
            cylinder(d=shaft_d, h=shaft_len_front, center=true);
        translate([0,0,-housing_h/2 - shaft_len_back/2 + endcap_th])
            cylinder(d=shaft_d, h=shaft_len_back, center=true);
    }
}

module bearings(){
    bearing_od = 10.0;
    bearing_id = shaft_d + 0.4;
    bearing_th = 4.0;

    translate([0,0,housing_h/2 - endcap_th - bearing_th/2])
        ring(bearing_od, bearing_id, bearing_th);

    translate([0,0,-housing_h/2 + endcap_th + bearing_th/2])
        ring(bearing_od, bearing_id, bearing_th);
}

union(){
    motor_body();
    stator();
    rotor();
    shaft();
    bearings();
}