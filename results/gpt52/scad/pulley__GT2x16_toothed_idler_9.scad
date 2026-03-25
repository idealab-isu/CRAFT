$fn=128;

teeth = 16;
pitch_d = 9.75;
pitch_r = pitch_d/2;

pulley_h = 12;
bore_d = 5;

tooth_add = 0.6;
tooth_depth = 0.7;
tooth_tip_w = 0.9;
tooth_root_w = 1.6;

root_r = pitch_r - tooth_depth;
outer_r = pitch_r + tooth_add;

module tooth2d() {
    polygon(points=[
        [root_r, -tooth_root_w/2],
        [root_r,  tooth_root_w/2],
        [outer_r,  tooth_tip_w/2],
        [outer_r, -tooth_tip_w/2]
    ]);
}

module pulley_body() {
    union() {
        cylinder(h=pulley_h, r=root_r, center=true);
        for(i=[0:teeth-1]) {
            rotate([0,0, i*360/teeth])
                linear_extrude(height=pulley_h, center=true)
                    tooth2d();
        }
    }
}

difference() {
    pulley_body();
    cylinder(h=pulley_h+2, d=bore_d, center=true, $fn=96);
}