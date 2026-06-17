$fn = 220;

// Timing pulley (GT2-like approximation)
// Target: 16 teeth, 9.65mm pitch diameter
teeth        = 16;
pitch_d      = 9.65;                 // mm (pitch diameter)
pitch_r      = pitch_d/2;

pulley_width  = 10;                  // mm
hub_thickness = 0;                   // mm (set >0 for hub)
bore_d        = 5;                   // mm

// Tooth geometry (timing-pulley-ish approximation)
// Pitch diameter is enforced by placing the tooth centerline on pitch_r.
tooth_height      = 0.85;            // radial height above pitch circle (mm)
tooth_root_depth  = 0.55;            // radial depth below pitch circle (mm)
tooth_fill        = 0.48;            // fraction of tooth pitch occupied at pitch circle (0..1)
fillet_r          = 0.18;            // mm

outer_r = pitch_r + tooth_height;
root_r  = max(0.2, pitch_r - tooth_root_depth);

// Tooth angular thickness at pitch circle
tooth_ang = (360/teeth) * tooth_fill;
half_ang  = tooth_ang/2;

// 2D tooth centered on +X axis; its centerline lies on pitch_r.
// This avoids the "extra tooth" look caused by teeth starting at 0° edge alignment.
module tooth2d() {
    tip_ang = half_ang * 0.78;

    hull() {
        // root corners
        rotate(-half_ang) translate([root_r, 0]) circle(r=fillet_r);
        rotate( half_ang) translate([root_r, 0]) circle(r=fillet_r);

        // tip corners (slightly narrower)
        rotate(-tip_ang)  translate([outer_r, 0]) circle(r=fillet_r);
        rotate( tip_ang)  translate([outer_r, 0]) circle(r=fillet_r);
    }
}

module pulley() {
    difference() {
        union() {
            // Root cylinder (body)
            cylinder(h=pulley_width, r=root_r, center=false);

            // Teeth: rotate about origin; tooth profile already spans root_r..outer_r.
            // Phase shift by half a tooth so orthographic views show exactly 16 teeth.
            for (i = [0:teeth-1]) {
                rotate([0,0,(i + 0.5)*360/teeth])
                    linear_extrude(height=pulley_width, center=false, convexity=10)
                        tooth2d();
            }

            // Optional hub (connected with slight overlap)
            if (hub_thickness > 0) {
                overlap = 0.2;
                translate([0,0,-hub_thickness + overlap])
                    cylinder(h=hub_thickness + overlap, r=root_r*1.2, center=false);
            }
        }

        // Bore (through), extended to guarantee clean subtraction
        extra = 2;
        translate([0,0,-extra/2])
            cylinder(h=pulley_width + hub_thickness + extra, r=bore_d/2, center=false);
    }
}

pulley();