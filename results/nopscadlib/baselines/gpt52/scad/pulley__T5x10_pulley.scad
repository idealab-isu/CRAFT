$fn=128;

teeth = 10;
pitch_d = 15.0;
pitch_r = pitch_d/2;

pulley_width = 10.0;

tooth_height = 1.2;
tooth_tip_width = 1.2;
tooth_root_width = 2.2;

clearance = 0.2;

bore_d = 5.0;

hub_d = 18.0;
hub_width = pulley_width;

flange_d = 20.0;
flange_thk = 1.0;

module tooth2d(r, h, w_root, w_tip){
    polygon(points=[
        [r, -w_root/2],
        [r,  w_root/2],
        [r+h,  w_tip/2],
        [r+h, -w_tip/2]
    ]);
}

module pulley_body(){
    union(){
        cylinder(d=hub_d, h=hub_width, center=true);
        translate([0,0, hub_width/2 + flange_thk/2]) cylinder(d=flange_d, h=flange_thk, center=true);
        translate([0,0,-hub_width/2 - flange_thk/2]) cylinder(d=flange_d, h=flange_thk, center=true);
    }
}

module teeth_ring(){
    for(i=[0:teeth-1]){
        rotate([0,0, i*360/teeth])
            linear_extrude(height=pulley_width, center=true, convexity=10)
                tooth2d(pitch_r - tooth_height/2, tooth_height, tooth_root_width, tooth_tip_width);
    }
}

difference(){
    union(){
        pulley_body();
        teeth_ring();
    }
    cylinder(d=bore_d+clearance, h=hub_width + 2*flange_thk + 2, center=true);
}