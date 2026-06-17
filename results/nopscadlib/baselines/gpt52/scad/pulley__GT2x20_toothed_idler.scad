$fn=128;

teeth = 20;
pitch_d = 12.22;
pitch_r = pitch_d/2;

pulley_width = 10;
hub_d = 16;
hub_r = hub_d/2;

bore_d = 5;
bore_r = bore_d/2;

flange_d = 18;
flange_r = flange_d/2;
flange_th = 1.2;

tooth_height = 1.2;
tooth_tip_r = pitch_r + tooth_height;
tooth_root_r = pitch_r - 0.6;

tooth_arc_factor = 0.55;
tooth_ang = 360/teeth;
tooth_arc = tooth_ang * tooth_arc_factor;

module tooth2d(r_root, r_tip, ang_span){
    polygon(points=[
        [r_root*cos(-ang_span/2), r_root*sin(-ang_span/2)],
        [r_tip*cos(-ang_span/2),  r_tip*sin(-ang_span/2)],
        [r_tip*cos( ang_span/2),  r_tip*sin( ang_span/2)],
        [r_root*cos( ang_span/2), r_root*sin( ang_span/2)]
    ]);
}

module teeth_ring(){
    for(i=[0:teeth-1]){
        rotate([0,0,i*tooth_ang])
            linear_extrude(height=pulley_width, center=true, convexity=10)
                tooth2d(tooth_root_r, tooth_tip_r, tooth_arc);
    }
}

module body(){
    union(){
        cylinder(h=pulley_width, r=pitch_r, center=true, $fn=128);
        teeth_ring();
        translate([0,0, pulley_width/2 + flange_th/2])
            cylinder(h=flange_th, r=flange_r, center=true, $fn=128);
        translate([0,0,-pulley_width/2 - flange_th/2])
            cylinder(h=flange_th, r=flange_r, center=true, $fn=128);
        cylinder(h=pulley_width + 2*flange_th, r=hub_r, center=true, $fn=128);
    }
}

difference(){
    body();
    cylinder(h=pulley_width + 2*flange_th + 2, r=bore_r, center=true, $fn=128);
}