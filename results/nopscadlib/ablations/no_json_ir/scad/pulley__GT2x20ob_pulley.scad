// Timing pulley: 20 teeth, 12.22mm pitch diameter
// One connected solid, discrete outward teeth, pitch diameter enforced at tooth centerline.

$fn = 180;

// Parameters
teeth = 20;
pitch_diameter = 12.22;          // mm (tooth centerline circle)
belt_width = 6;                  // toothed section width (mm)

bore_diameter = 5;               // center bore (mm)

hub_diameter = 10;               // hub OD (mm)
hub_length = 10;                 // hub length (mm)

flange_thickness = 1;            // mm
flange_diameter = pitch_diameter + 4; // mm

tooth_height = 1.5;              // radial height (mm)
tooth_width = 1.2;               // tangential width at pitch circle (mm)

set_screw_diameter = 2;          // mm
set_screw_z = 0;                 // through hub mid-height

// Small overlaps to guarantee connectivity (no floating parts)
z_overlap = 0.2;
radial_overlap = 0.2;

// Derived
pitch_r = pitch_diameter/2;
tooth_pitch = PI * pitch_diameter / teeth;          // arc length per tooth at pitch circle
tooth_w = min(tooth_width, tooth_pitch * 0.75);     // keep gaps visible

// Tooth is centered on pitch circle; its radial thickness is tooth_height.
// Therefore: pitch_r = root_r + tooth_height/2  => root_r = pitch_r - tooth_height/2
root_r = pitch_r - tooth_height/2;
outer_r = root_r + tooth_height;

pulley_total_h = belt_width + 2*flange_thickness;

// Place hub so it overlaps into the pulley body (one connected solid)
hub_z0 = -pulley_total_h/2 + hub_length/2 - z_overlap;

module toothed_ring() {
    union() {
        // Root cylinder (slightly taller to overlap into flanges)
        cylinder(h=belt_width + 2*z_overlap, r=root_r, center=true);

        // Teeth: centered on pitch circle, protrude outward and overlap into root
        for (i = [0:teeth-1]) {
            rotate([0,0,i*360/teeth])
                translate([pitch_r - radial_overlap, 0, 0])
                    cube([tooth_height + 2*radial_overlap, tooth_w, belt_width + 2*z_overlap], center=true);
        }
    }
}

module flanges() {
    if (flange_thickness > 0) {
        // Top flange (overlap into toothed section)
        translate([0,0, belt_width/2 + flange_thickness/2 - z_overlap/2])
            cylinder(h=flange_thickness + z_overlap, d=flange_diameter, center=true);

        // Bottom flange (overlap into toothed section)
        translate([0,0,-belt_width/2 - flange_thickness/2 + z_overlap/2])
            cylinder(h=flange_thickness + z_overlap, d=flange_diameter, center=true);
    }
}

module hub() {
    translate([0,0,hub_z0])
        cylinder(h=hub_length + 2*z_overlap, d=hub_diameter, center=true);
}

module pulley() {
    difference() {
        union() {
            toothed_ring();
            flanges();
            hub();
        }

        // Bore through entire part
        cylinder(h=pulley_total_h + hub_length + 4, d=bore_diameter, center=true);

        // Set screw holes through hub (two opposed), positioned by formulas
        for (a = [0,180]) {
            rotate([0,0,a])
                translate([hub_diameter/2 - set_screw_diameter/2, 0, hub_z0 + set_screw_z])
                    rotate([90,0,0])
                        cylinder(h=hub_diameter + 4, d=set_screw_diameter, center=true);
        }
    }
}

pulley();