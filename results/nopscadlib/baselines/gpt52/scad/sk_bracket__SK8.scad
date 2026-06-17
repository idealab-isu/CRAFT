$fn=64;

rod_d = 8.0;
rod_r = rod_d/2;

bracket_h = 20.0;

base_len = 40.0;
base_w   = 20.0;
base_t   = 6.0;

wall_t = 6.0;
cap_t  = 6.0;

clamp_outer_d = rod_d + 2*wall_t;   // 20mm
clamp_outer_r = clamp_outer_d/2;

clamp_center_z = base_t + (bracket_h - base_t)/2;

slot_w = 2.0;
bolt_d = 5.0;
bolt_head_d = 9.0;
bolt_head_h = 3.0;

module base_plate(){
    translate([-base_len/2, -base_w/2, 0])
        cube([base_len, base_w, base_t], center=false);
}

module clamp_body(){
    // Outer clamp cylinder
    translate([0, 0, clamp_center_z])
        cylinder(h=bracket_h, r=clamp_outer_r, center=true);
}

module rod_bore(){
    translate([0, 0, clamp_center_z])
        cylinder(h=bracket_h + 2, r=rod_r + 0.2, center=true);
}

module clamp_slot(){
    // Slot from front face through to rod bore
    translate([0, clamp_outer_r/2, clamp_center_z])
        cube([clamp_outer_d + 2, clamp_outer_r + 2, bracket_h + 2], center=true);
}

module bolt_hole(){
    // Cross-bolt through clamp (along Y)
    translate([0, 0, clamp_center_z])
        rotate([90,0,0])
            cylinder(h=clamp_outer_d + 10, r=bolt_d/2, center=true);
}

module bolt_head_recesses(){
    // Recess on both sides for bolt head/nut
    translate([0, 0, clamp_center_z])
        rotate([90,0,0]) {
            translate([0,0,(clamp_outer_d/2) - bolt_head_h/2])
                cylinder(h=bolt_head_h+0.2, r=bolt_head_d/2, center=true);
            translate([0,0,-(clamp_outer_d/2) + bolt_head_h/2])
                cylinder(h=bolt_head_h+0.2, r=bolt_head_d/2, center=true);
        }
}

module base_mount_holes(){
    // Two mounting holes in base plate
    hole_d = 5.0;
    x_off = 14.0;
    y_off = 0.0;
    for (sx=[-1,1]) {
        translate([sx*x_off, y_off, base_t/2])
            cylinder(h=base_t+2, r=hole_d/2, center=true);
    }
}

difference(){
    union(){
        base_plate();
        // Support web between base and clamp
        hull(){
            translate([0,0,base_t])
                cylinder(h=0.1, r=clamp_outer_r, center=false);
            translate([0,0,base_t/2])
                cube([base_len*0.6, base_w*0.9, 0.1], center=true);
        }
        clamp_body();
    }
    rod_bore();
    clamp_slot();
    bolt_hole();
    bolt_head_recesses();
    base_mount_holes();
}