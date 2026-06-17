$fn=96;

od = 18.0;
len = 16.0;
screw_d = 8.0;

module knurl_ring(r=9, h=16, teeth=48, tooth_depth=0.6, tooth_w=1.2){
    difference(){
        cylinder(r=r, h=h, center=true);
        for(i=[0:teeth-1]){
            rotate([0,0, i*360/teeth])
                translate([r - tooth_depth/2, 0, 0])
                    cube([tooth_depth, tooth_w, h+0.4], center=true);
        }
    }
}

module internal_thread_approx(d=screw_d, h=len, pitch=1.25, depth=0.55){
    turns = h/pitch;
    linear_extrude(height=h, center=true, twist=turns*360, slices=max(ceil(turns*40),80), convexity=10)
        difference(){
            circle(d=d + 2*depth);
            circle(d=d);
        }
}

module heat_set_insert(od=18.0, h=16.0, screw_d=8.0){
    r = od/2;
    difference(){
        union(){
            knurl_ring(r=r, h=h, teeth=60, tooth_depth=0.7, tooth_w=1.1);
            translate([0,0, h*0.33]) cylinder(r=r*0.98, h=h*0.34, center=true);
            translate([0,0,-h*0.33]) cylinder(r=r*0.98, h=h*0.34, center=true);
        }
        internal_thread_approx(d=screw_d, h=h+0.6, pitch=1.25, depth=0.6);
        translate([0,0, h/2 - 0.6]) cylinder(d1=screw_d+2.2, d2=screw_d, h=1.2, center=false);
        translate([0,0,-h/2]) cylinder(d1=screw_d, d2=screw_d+2.2, h=1.2, center=false);
    }
}

heat_set_insert(od=od, h=len, screw_d=screw_d);