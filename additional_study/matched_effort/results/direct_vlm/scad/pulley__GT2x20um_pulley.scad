$fn = 220;

// Timing pulley parameters
teeth    = 20;
pitch_d  = 12.22;                 // mm (pitch diameter)
pitch    = PI * pitch_d / teeth;  // circular pitch

pulley_width = 10;                // mm
bore_d       = 5;                 // mm

// Tooth geometry (simple rectangular tooth, centered on tooth angle)
tooth_height    = 1.2;            // mm radial height above root cylinder
tooth_thickness = pitch * 0.45;   // mm tangential thickness at mid-radius

// Derived radii
r_pitch = pitch_d/2;

// Place pitch circle approximately mid-tooth height so pitch diameter is meaningful
r_root  = r_pitch - tooth_height/2;
r_tip   = r_root + tooth_height;

// Ensure teeth overlap into the root cylinder so the model is one connected solid
tooth_overlap = 0.25;             // mm (radial overlap into root cylinder)

module tooth3d() {
    // A single tooth as a tangential rectangle, extruded along Z
    // Positioned so its inner face overlaps into the root cylinder.
    translate([r_root + (tooth_height/2) - tooth_overlap, 0, 0])
        cube([tooth_height + 2*tooth_overlap, tooth_thickness, pulley_width], center=true);
}

module pulley() {
    difference() {
        union() {
            // Root cylinder (body under teeth)
            cylinder(h=pulley_width, r=r_root, center=true);

            // Teeth
            for (i = [0:teeth-1])
                rotate([0, 0, i * 360 / teeth])
                    tooth3d();
        }

        // Bore
        cylinder(h=pulley_width + 2, r=bore_d/2, center=true);
    }
}

pulley();