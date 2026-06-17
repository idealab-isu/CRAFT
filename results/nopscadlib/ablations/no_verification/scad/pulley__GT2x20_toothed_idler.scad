// Timing pulley: 20 teeth, 12.22mm pitch diameter
// One connected solid (union) with bore subtracted.

$fn = 200;

// --- Required specs ---
tooth_count = 20;
pitch_diameter_mm = 12.22;
pitch_radius_mm = pitch_diameter_mm/2;

// --- Pulley parameters ---
pulley_width_mm = 7;
bore_diameter_mm = 5;

flange_diameter_mm = 16;
flange_thickness_mm = 1.5;

tolerances_mm = 0.2;
overlap_mm = 0.25;

// Tooth geometry (simple rectangular teeth centered on pitch circle)
tooth_radial_height_mm = 0.9;     // outward from pitch circle
tooth_root_depth_mm = 0.6;        // inward from pitch circle (valleys)
tooth_tangential_width_mm = 1.2;  // tooth width around circumference

// Derived radii
root_radius_mm  = pitch_radius_mm - tooth_root_depth_mm;
outer_radius_mm = pitch_radius_mm + tooth_radial_height_mm;

// Keep root radius positive
root_r = max(0.1, root_radius_mm);

// Total height including flanges
total_h = pulley_width_mm + 2*flange_thickness_mm;

// Tooth placement: ensure inner edge is inside root cylinder for connectivity
tooth_len = tooth_radial_height_mm + tooth_root_depth_mm;
tooth_center_r = root_r + tooth_len/2 - overlap_mm;

module pulley_solid() {
    union() {
        // Root cylinder (tooth valleys)
        cylinder(r=root_r, h=pulley_width_mm, center=true);

        // Teeth (radial array), overlapped into root cylinder
        for (i = [0:tooth_count-1]) {
            rotate([0, 0, i*360/tooth_count])
                translate([tooth_center_r, 0, 0])
                    cube([tooth_len,
                          tooth_tangential_width_mm,
                          pulley_width_mm + 2*overlap_mm],
                         center=true);
        }

        // Flanges (top and bottom), overlapped into body
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

module pulley() {
    difference() {
        pulley_solid();

        // Bore through entire part (with tolerance)
        cylinder(r=(bore_diameter_mm + 2*tolerances_mm)/2,
                 h=total_h + 4*overlap_mm,
                 center=true);
    }
}

pulley();