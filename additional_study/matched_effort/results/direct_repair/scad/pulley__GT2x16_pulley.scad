$fn = 180;

// Timing pulley (simplified GT2-like tooth form)
// User spec: 16 teeth, 9.75mm pitch diameter

teeth = 16;
pitch_d = 9.75;                 // mm
pitch_r = pitch_d/2;
pitch = PI * pitch_d / teeth;   // circular pitch derived from pitch diameter & tooth count

// Pulley body parameters (reasonable defaults)
belt_width = 6;                 // mm
flange_thickness = 1.2;         // mm
flange_overhang = 1.0;          // mm
bore_d = 5.0;                   // mm

// Tooth geometry (approximate)
tooth_height = 0.75;            // mm radial height above root
root_clearance = 0.35;          // mm radial below pitch circle
tooth_tip_width = pitch * 0.35; // mm (arc chord approx)
tooth_root_width = pitch * 0.65;// mm

root_r = pitch_r - root_clearance;
outer_r = root_r + tooth_height;

pulley_r = outer_r;
flange_r = pulley_r + flange_overhang;

module tooth2d() {
    // A simple trapezoid tooth in 2D, centered on X axis, extruded later
    polygon(points=[
        [-tooth_root_width/2, root_r],
        [ tooth_root_width/2, root_r],
        [ tooth_tip_width/2,  outer_r],
        [-tooth_tip_width/2,  outer_r]
    ]);
}

module pulley() {
    difference() {
        union() {
            // Main toothed cylinder (root diameter)
            cylinder(h=belt_width, r=root_r);

            // Teeth
            for (i = [0:teeth-1]) {
                rotate([0,0, i*360/teeth])
                    linear_extrude(height=belt_width)
                        tooth2d();
            }

            // Flanges
            translate([0,0,-flange_thickness])
                cylinder(h=flange_thickness, r=flange_r);
            translate([0,0,belt_width])
                cylinder(h=flange_thickness, r=flange_r);
        }

        // Bore
        translate([0,0,-flange_thickness-0.5])
            cylinder(h=belt_width + 2*flange_thickness + 1.0, d=bore_d);
    }
}

pulley();