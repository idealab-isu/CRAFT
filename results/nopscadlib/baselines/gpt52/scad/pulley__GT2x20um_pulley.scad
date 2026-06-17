$fn=128;

teeth = 20;
pitch_d = 12.22;
pitch_r = pitch_d/2;

pulley_width = 10;
hub_d = 16;
hub_r = hub_d/2;

bore_d = 5;
bore_r = bore_d/2;

tooth_height = 1.2;
tooth_tip_width = 1.2;
tooth_root_width = 2.0;

root_r = pitch_r - tooth_height*0.55;
tip_r  = pitch_r + tooth_height*0.45;

module tooth2d(root_w, tip_w, r0, r1){
    polygon(points=[
        [-root_w/2, r0],
        [ root_w/2, r0],
        [ tip_w/2,  r1],
        [-tip_w/2,  r1]
    ]);
}

module pulley_body(){
    union(){
        cylinder(h=pulley_width, r=root_r, center=true);
        cylinder(h=pulley_width, r=hub_r, center=true);
    }
}

module teeth_ring(){
    for(i=[0:teeth-1]){
        rotate([0,0, i*360/teeth])
            linear_extrude(height=pulley_width, center=true)
                tooth2d(tooth_root_width, tooth_tip_width, root_r, tip_r);
    }
}

difference(){
    union(){
        pulley_body();
        teeth_ring();
    }
    cylinder(h=pulley_width+2, r=bore_r, center=true);
}