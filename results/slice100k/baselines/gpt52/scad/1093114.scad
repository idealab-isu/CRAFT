$fn=96;

size_xy = 47.8;
size_z  = 14.3;

th = 6.0;                 // main plate thickness
boss_h = size_z - th;     // protrusion height
boss_r = 3.0;

arm_len = 20.0;           // from center to arm tip
arm_w   = 12.0;           // outer arm width
tip_r   = 7.0;            // outer tip rounding radius

cut_w   = 6.6;            // inner cutout width
cut_tip_r = 4.2;          // inner cutout tip rounding
cut_len = 15.0;           // inner cutout length

junction_x = 16.0;
junction_y = 10.0;

hub_r = 8.0;

module capsule2d(len, r){
    hull(){
        translate([-len/2,0]) circle(r=r);
        translate([ len/2,0]) circle(r=r);
    }
}

module teardrop2d(len, w, tip_r){
    // rounded loop/teardrop-like: capsule with slightly larger tip
    union(){
        capsule2d(len=len - 2*tip_r, r=w/2);
        translate([len/2 - tip_r,0]) circle(r=tip_r);
    }
}

module arm2d(){
    // Outer arm: capsule-like with rounded tip
    translate([arm_len/2,0])
        capsule2d(len=arm_len, r=arm_w/2);
}

module arm_cut2d(){
    // Inner cutout: smaller capsule, leaving a loop-like arm
    translate([arm_len/2 + 1.0,0])
        capsule2d(len=cut_len, r=cut_w/2);
}

module cross2d(){
    union(){
        // central junction
        square([junction_x, junction_y], center=true);
        // central rounded hub
        circle(r=hub_r);
        // four arms
        for(a=[0:90:270])
            rotate(a) arm2d();
    }
}

module cutouts2d(){
    union(){
        for(a=[0:90:270])
            rotate(a) arm_cut2d();
    }
}

module main_plate(){
    linear_extrude(height=th, center=true)
        difference(){
            cross2d();
            cutouts2d();
        }
}

module boss(){
    translate([0,0, th/2 + boss_h/2])
        cylinder(h=boss_h, r=boss_r, center=true);
}

union(){
    main_plate();
    boss();
}