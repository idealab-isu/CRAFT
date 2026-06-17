$fn = 180;

// Timing pulley (simplified GT2-like tooth form)
// User specs:
teeth = 20;
pitch_diameter = 12.22;   // mm

// Assumptions / defaults (can be edited):
pitch = PI * pitch_diameter / teeth;  // derived from pitch diameter & tooth count
pulley_width = 10;        // mm
bore_diameter = 5;        // mm
hub_diameter = 0;         // 0 = no hub
hub_width = 0;            // mm

// Tooth geometry (simplified trapezoid approximation):
tooth_height = 0.75;      // mm (radial)
tooth_top_width = 0.60;   // mm (at outer radius)
tooth_root_width = 1.20;  // mm (at pitch radius)

// Body thickness below pitch circle (to give a root cylinder):
root_extra = 0.80;        // mm (radial below pitch radius)

// Small clearance to avoid coincident faces:
eps = 0.01;

module timing_pulley(teeth, pitch_diameter, width, bore_d, hub_d=0, hub_w=0) {
    pitch_r = pitch_diameter/2;
    root_r  = max(0.1, pitch_r - root_extra);
    outer_r = pitch_r + tooth_height;

    difference() {
        union() {
            // Root cylinder
            cylinder(h=width, r=root_r);

            // Teeth
            for (i = [0:teeth-1]) {
                rotate([0,0, i*360/teeth])
                    translate([pitch_r, 0, 0])
                        tooth(width, tooth_root_width, tooth_top_width, tooth_height);
            }

            // Optional hub
            if (hub_d > 0 && hub_w > 0) {
                translate([0,0,(width-hub_w)/2])
                    cylinder(h=hub_w, r=hub_d/2);
            }
        }

        // Bore
        translate([0,0,-eps])
            cylinder(h=width + 2*eps, r=bore_d/2);
    }
}

module tooth(width, w_root, w_top, h) {
    // Trapezoid in XY, extruded along Z
    linear_extrude(height=width, center=false, convexity=10)
        polygon(points=[
            [0, -w_root/2],
            [0,  w_root/2],
            [h,  w_top/2],
            [h, -w_top/2]
        ]);
}

timing_pulley(teeth=teeth, pitch_diameter=pitch_diameter, width=pulley_width, bore_d=bore_diameter, hub_d=hub_diameter, hub_w=hub_width);