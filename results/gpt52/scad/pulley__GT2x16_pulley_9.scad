$fn=128;

teeth = 16;
pitch_d = 9.65;
pitch_r = pitch_d/2;

pulley_w = 10;
hub_d = 14;
hub_w = 12;

bore_d = 5;

tooth_height = 1.2;
tooth_tip_w = 1.0;
tooth_root_w = 2.0;

root_r = pitch_r - tooth_height*0.55;
tip_r  = pitch_r + tooth_height*0.45;

module tooth2d(tip_w, root_w, h) {
    polygon(points=[
        [-root_w/2, 0],
        [ root_w/2, 0],
        [ tip_w/2,  h],
        [-tip_w/2,  h]
    ]);
}

module teeth_ring(teeth, root_r, tip_r, tip_w, root_w, w) {
    for(i=[0:teeth-1]) {
        rotate([0,0, i*360/teeth])
            translate([root_r,0,0])
                linear_extrude(height=w, center=true, convexity=10)
                    tooth2d(tip_w, root_w, tip_r-root_r);
    }
}

module pulley_body() {
    union() {
        cylinder(d=2*root_r, h=pulley_w, center=true);
        teeth_ring(teeth, root_r, tip_r, tooth_tip_w, tooth_root_w, pulley_w);
        cylinder(d=hub_d, h=hub_w, center=true);
    }
}

difference() {
    pulley_body();
    cylinder(d=bore_d, h=hub_w+2, center=true);
}