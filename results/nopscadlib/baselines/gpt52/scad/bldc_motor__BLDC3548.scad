$fn=96;

stator_d = 35.0;
motor_h = 45.0;

module bolt_circle_holes(bcd, hole_d, h, n=4, z0=0){
    for(i=[0:n-1]){
        rotate([0,0,360/n*i])
            translate([bcd/2,0,z0])
                cylinder(d=hole_d, h=h, center=false);
    }
}

module motor_can(d, h, wall=1.2){
    difference(){
        cylinder(d=d, h=h, center=true);
        cylinder(d=d-2*wall, h=h-2*wall, center=true);
    }
}

module endcap(d, t){
    cylinder(d=d, h=t, center=true);
}

module shaft(d, h){
    cylinder(d=d, h=h, center=true);
}

module mounting_base(d, t, bcd, hole_d){
    difference(){
        cylinder(d=d, h=t, center=true);
        translate([0,0,-t/2-0.01])
            bolt_circle_holes(bcd=bcd, hole_d=hole_d, h=t+0.02, n=4, z0=0);
        translate([0,0,-t/2-0.01])
            cylinder(d=8.0, h=t+0.02, center=false);
    }
}

module stator_core(d, h){
    cylinder(d=d, h=h, center=true);
}

module stator_teeth(d_inner, d_outer, h, n=12, tooth_w=3.0){
    for(i=[0:n-1]){
        rotate([0,0,360/n*i])
            translate([(d_inner/2 + d_outer/2)/2,0,0])
                cube([ (d_outer-d_inner)/2, tooth_w, h ], center=true);
    }
}

module motor(){
    can_d = stator_d + 6.0;
    can_h = motor_h;
    can_wall = 1.2;

    endcap_t = 2.5;
    base_t = 3.0;

    shaft_d = 5.0;
    shaft_above = 18.0;
    shaft_below = 6.0;

    stator_h = motor_h - (endcap_t*2);
    stator_inner_d = stator_d - 10.0;

    union(){
        motor_can(d=can_d, h=can_h, wall=can_wall);

        translate([0,0, can_h/2 - endcap_t/2])
            endcap(d=can_d, t=endcap_t);

        translate([0,0,-can_h/2 + endcap_t/2])
            endcap(d=can_d, t=endcap_t);

        translate([0,0,-can_h/2 + base_t/2])
            mounting_base(d=can_d, t=base_t, bcd=25.0, hole_d=3.2);

        translate([0,0, (shaft_above - shaft_below)/2 ])
            shaft(d=shaft_d, h=can_h + shaft_above + shaft_below);

        difference(){
            union(){
                stator_core(d=stator_d, h=stator_h);
                stator_teeth(d_inner=stator_inner_d, d_outer=stator_d, h=stator_h, n=12, tooth_w=3.0);
            }
            cylinder(d=stator_inner_d, h=stator_h+0.2, center=true);
        }
    }
}

motor();