$fn=128;

teeth = 20;
pitch_d = 12.22;
pitch_r = pitch_d/2;

pulley_width = 10;
hub_d = 16;
bore_d = 5;

tooth_height = 1.2;
tooth_tip_arc = 0.55;
tooth_root_arc = 0.35;

module tooth2d(pitch_r, tooth_h, tip_r, root_r, ang_span){
    r_root = pitch_r - tooth_h*0.65;
    r_tip  = pitch_r + tooth_h*0.35;

    intersection(){
        rotate(0)
        polygon(points=[
            [0,0],
            [r_tip*cos(-ang_span/2), r_tip*sin(-ang_span/2)],
            [r_tip*cos( ang_span/2), r_tip*sin( ang_span/2)]
        ]);

        union(){
            translate([pitch_r,0]) circle(r=tip_r, $fn=64);
            translate([r_root,0]) circle(r=root_r, $fn=64);
        }
    }
}

module pulley_body(){
    union(){
        cylinder(d=hub_d, h=pulley_width, center=true, $fn=128);
    }
}

module teeth_ring(){
    ang = 360/teeth;
    ang_span = ang*0.62;

    for(i=[0:teeth-1]){
        rotate([0,0,i*ang])
            linear_extrude(height=pulley_width, center=true, convexity=10)
                tooth2d(pitch_r, tooth_height, tooth_tip_arc, tooth_root_arc, ang_span);
    }
}

difference(){
    union(){
        pulley_body();
        teeth_ring();
    }
    cylinder(d=bore_d, h=pulley_width+2, center=true, $fn=96);
}