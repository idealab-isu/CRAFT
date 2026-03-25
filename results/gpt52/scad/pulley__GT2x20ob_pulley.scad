$fn=128;

teeth = 20;
pitch_d = 12.22;          // mm
pitch_r = pitch_d/2;

pulley_width = 10;        // mm
hub_d = 16;               // mm
bore_d = 5;               // mm

tooth_height = 1.2;       // mm (radial)
tooth_tip_width = 1.2;    // mm (tangential at tip)
tooth_root_width = 0.6;   // mm (tangential at root)
root_relief = 0.4;        // mm (radial relief below pitch circle)

outer_r = pitch_r + tooth_height;
root_r  = max(0.1, pitch_r - root_relief);

module tooth2d(r_base, r_tip, w_base, w_tip){
    polygon(points=[
        [r_base, -w_base/2],
        [r_tip,  -w_tip/2],
        [r_tip,   w_tip/2],
        [r_base,  w_base/2]
    ]);
}

module teeth_ring(){
    for(i=[0:teeth-1]){
        rotate(i*360/teeth)
            linear_extrude(height=pulley_width, center=true, convexity=10)
                tooth2d(root_r, outer_r, tooth_root_width, tooth_tip_width);
    }
}

module pulley_body(){
    union(){
        cylinder(h=pulley_width, r=root_r, center=true);
        teeth_ring();
        cylinder(h=pulley_width, d=hub_d, center=true);
    }
}

difference(){
    pulley_body();
    cylinder(h=pulley_width+2, d=bore_d, center=true);
}