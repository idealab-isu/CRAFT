$fn=128;

teeth = 16;
pitch_d = 9.75;
pitch_r = pitch_d/2;

pulley_width = 10;
hub_d = 12;
bore_d = 5;

tooth_height = 1.2;
tooth_tip_width = 1.2;
tooth_root_width = 2.0;

root_r = pitch_r - tooth_height/2;
tip_r  = pitch_r + tooth_height/2;

module tooth2d() {
    polygon(points=[
        [root_r, -tooth_root_width/2],
        [tip_r,  -tooth_tip_width/2],
        [tip_r,   tooth_tip_width/2],
        [root_r,  tooth_root_width/2]
    ]);
}

module teeth_ring() {
    for(i=[0:teeth-1]) {
        rotate([0,0, i*360/teeth])
            linear_extrude(height=pulley_width, center=true, convexity=10)
                tooth2d();
    }
}

module body() {
    cylinder(d=hub_d, h=pulley_width, center=true);
}

module pulley() {
    difference() {
        union() {
            body();
            teeth_ring();
        }
        cylinder(d=bore_d, h=pulley_width+2, center=true);
    }
}

pulley();