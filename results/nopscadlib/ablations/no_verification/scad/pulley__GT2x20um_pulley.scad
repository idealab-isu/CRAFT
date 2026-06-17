// Timing pulley: 20 teeth, 12.22mm pitch diameter
// Single connected solid, no extra hub/flanges. Teeth are visible in orthographic views.

$fn = 160;

// --- Required specs ---
tooth_count = 20;
pitch_diameter_mm = 12.22;
pitch_radius_mm = pitch_diameter_mm/2;

// --- Simple printable timing-tooth approximation (rectangular teeth) ---
pulley_width_mm = 7;
tooth_radial_height_mm = 1.2;        // tooth height above pitch circle
tooth_tangential_width_mm = 1.1;     // tooth thickness around circumference
root_clearance_mm = 0.6;             // body radius below pitch circle
bore_diameter_mm = 5;

// Connectivity/robustness
overlap_mm = 0.25;                   // small overlap to guarantee union/difference connectivity

// Derived radii
root_radius_mm = pitch_radius_mm - root_clearance_mm;   // base cylinder radius
outer_radius_mm = pitch_radius_mm + tooth_radial_height_mm;

// --- Modules ---
module pulley_solid() {
    difference() {
        union() {
            // Base body (root cylinder)
            cylinder(h=pulley_width_mm, r=root_radius_mm, center=true);

            // Teeth: protrude outward from pitch circle, overlap into body for connectivity
            for (i = [0:tooth_count-1]) {
                rotate([0, 0, i * 360/tooth_count])
                    translate([pitch_radius_mm + tooth_radial_height_mm/2 - overlap_mm/2, 0, 0])
                        cube([tooth_radial_height_mm + overlap_mm, tooth_tangential_width_mm, pulley_width_mm], center=true);
            }
        }

        // Bore through entire pulley (slightly longer to ensure clean cut)
        cylinder(h=pulley_width_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);
    }
}

pulley_solid();