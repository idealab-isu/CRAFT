$fn=128;

teeth = 16;
pitch_d = 9.75;          // mm
pitch_r = pitch_d/2;

pulley_w = 10;           // mm
hub_d = 14;              // mm
bore_d = 5;              // mm

tooth_height = 1.2;      // mm (radial)
tooth_tip_width = 1.2;   // mm (tangential at tip)
tooth_root_width = 2.0;  // mm (tangential at root)

root_r = pitch_r - tooth_height*0.55;
tip_r  = pitch_r + tooth_height*0.65;

module tooth2d() {
    polygon(points=[
        [root_r, -tooth_root_width/2],
        [root_r,  tooth_root_width/2],
        [tip_r,   tooth_tip_width/2],
        [tip_r,  -tooth_tip_width/2]
    ]);
}

module teeth_ring() {
    for(i=[0:teeth-1]) {
        rotate(i*360/teeth)
            linear_extrude(height=pulley_w, center=true, convexity=10)
                tooth2d();
    }
}

module body() {
    cylinder(d=hub_d, h=pulley_w, center=true);
}

difference() {
    union() {
        body();
        teeth_ring();
    }
    cylinder(d=bore_d, h=pulley_w+2, center=true);
}