$fn=128;

teeth = 16;
pitch_d = 12.16;          // mm
pitch_r = pitch_d/2;

pulley_width = 10;        // mm
hub_d = 18;               // mm
hub_width = 12;           // mm

bore_d = 5;               // mm

tooth_height = 1.2;       // mm (radial)
tooth_tip_width = 1.2;    // mm (tangential at tip)
tooth_root_width = 2.0;   // mm (tangential at root)

root_r = pitch_r - tooth_height*0.55;
tip_r  = pitch_r + tooth_height*0.45;

module tooth2d() {
    polygon(points=[
        [root_r, -tooth_root_width/2],
        [root_r,  tooth_root_width/2],
        [tip_r,   tooth_tip_width/2],
        [tip_r,  -tooth_tip_width/2]
    ]);
}

module pulley_teeth() {
    for(i=[0:teeth-1]) {
        rotate(i*360/teeth)
            linear_extrude(height=pulley_width, center=true, convexity=10)
                tooth2d();
    }
}

module pulley_body() {
    union() {
        cylinder(d=2*root_r, h=pulley_width, center=true);
        pulley_teeth();
        cylinder(d=hub_d, h=hub_width, center=true);
    }
}

difference() {
    pulley_body();
    cylinder(d=bore_d, h=hub_width+2, center=true);
}