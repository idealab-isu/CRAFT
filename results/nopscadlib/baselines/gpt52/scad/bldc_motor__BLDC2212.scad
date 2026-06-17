$fn=96;

stator_d = 28.0;
motor_h = 27.0;

module bolt_circle_holes(bcd, hole_d, h, n, z0=0){
    for(i=[0:n-1]){
        a = 360*i/n;
        translate([ (bcd/2)*cos(a), (bcd/2)*sin(a), z0 ])
            cylinder(d=hole_d, h=h, center=false);
    }
}

module motor_can(od, h, wall){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=od-2*wall, h=h+0.6, center=true);
    }
}

module endcap(od, h){
    cylinder(d=od, h=h, center=true);
}

module shaft(d, h){
    cylinder(d=d, h=h, center=true);
}

module stator_core(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.6, center=true);
    }
}

module stator_teeth(od, id, h, n, tooth_w, tooth_depth){
    for(i=[0:n-1]){
        a = 360*i/n;
        rotate([0,0,a])
            translate([ (id/2) + tooth_depth/2, 0, 0 ])
                cube([tooth_depth, tooth_w, h], center=true);
    }
}

module motor(){
    can_od = stator_d + 4.0;
    can_wall = 0.8;
    endcap_h = 2.0;
    stator_h = motor_h - 2*endcap_h;
    stator_id = 12.0;
    tooth_count = 12;
    tooth_w = 3.0;
    tooth_depth = (stator_d - stator_id)/2 * 0.55;

    shaft_d = 3.0;
    shaft_len = motor_h + 12.0;

    mount_bcd = 19.0;
    mount_hole_d = 2.2;

    union(){
        // Outer can
        motor_can(can_od, motor_h, can_wall);

        // Endcaps
        translate([0,0, (motor_h/2) - (endcap_h/2)])
            endcap(can_od, endcap_h);
        translate([0,0, -(motor_h/2) + (endcap_h/2)])
            endcap(can_od, endcap_h);

        // Stator core + teeth
        translate([0,0,0])
        union(){
            stator_core(stator_d, stator_id, stator_h);
            stator_teeth(stator_d, stator_id, stator_h, tooth_count, tooth_w, tooth_depth);
        }

        // Shaft
        translate([0,0,0])
            shaft(shaft_d, shaft_len);
    }
}

difference(){
    motor();

    // Mounting holes through front endcap
    endcap_h = 2.0;
    can_od = stator_d + 4.0;
    translate([0,0, (motor_h/2) - endcap_h])
        bolt_circle_holes(19.0, 2.2, endcap_h*2 + 0.6, 4, 0);

    // Center bore through front endcap for shaft clearance
    translate([0,0, (motor_h/2) - endcap_h])
        cylinder(d=6.0, h=endcap_h*2 + 0.6, center=false);
}