$fn=64;

L = 0.2;
W = 0.1;
H = 0.1;

module rounded_rect_2d(l, w, r){
    r2 = min(r, min(l,w)/2);
    hull(){
        translate([ l/2 - r2,  w/2 - r2]) circle(r=r2);
        translate([-l/2 + r2,  w/2 - r2]) circle(r=r2);
        translate([ l/2 - r2, -w/2 + r2]) circle(r=r2);
        translate([-l/2 + r2, -w/2 + r2]) circle(r=r2);
    }
}

module base_plate(){
    base_t = 0.02;
    r = 0.02;
    translate([0,0,-H/2 + base_t/2])
        linear_extrude(height=base_t)
            rounded_rect_2d(L, W, r);
}

module rib(){
    base_t = 0.02;
    rib_w = 0.02;
    rib_h = 0.03;
    rib_l = 0.12;
    translate([-0.02, 0, -H/2 + base_t + rib_h/2])
        cube([rib_l, rib_w, rib_h], center=true);
}

module bosses(){
    base_t = 0.02;
    boss_l = 0.02;
    boss_w = 0.02;
    boss_h = 0.02;
    x0 = 0.02;
    z0 = -H/2 + base_t + boss_h/2;
    yoff = 0.02;
    translate([x0,  yoff, z0]) cube([boss_l, boss_w, boss_h], center=true);
    translate([x0, -yoff, z0]) cube([boss_l, boss_w, boss_h], center=true);
}

module hook_arm(){
    base_t = 0.02;
    rib_h = 0.03;
    zc = -H/2 + base_t + rib_h + 0.02;

    arm_r = 0.03;
    arm_th = 0.02;
    arm_w = 0.02;

    x_center = 0.05;
    y_center = 0.0;

    // Curved strap segment (partial torus)
    translate([x_center, y_center, zc])
        rotate([90,0,0])
            rotate_extrude(angle=210, convexity=10)
                translate([arm_r,0,0])
                    square([arm_th, arm_w], center=true);

    // Short rectangular tip with flat end face
    tip_l = 0.03;
    tip_w = 0.02;
    tip_h = 0.02;

    // Place tip near end of arc (approx at 210 degrees)
    ang = 210;
    x_tip = x_center + arm_r*cos(ang);
    z_tip = zc + arm_r*sin(ang);
    // Tangent direction in XZ plane
    rot_y = -(ang + 90);

    translate([x_tip, 0, z_tip])
        rotate([0, rot_y, 0])
            translate([tip_l/2, 0, 0])
                cube([tip_l, tip_w, tip_h], center=true);
}

module bracket(){
    union(){
        base_plate();
        rib();
        bosses();
        hook_arm();
    }
}

bracket();