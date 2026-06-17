$fn = 180;

// --- Required targets ---
tooth_count = 80;
pitch_diameter_mm = 50.42;

// --- Derived belt pitch from tooth count + pitch diameter (consistent) ---
pitch_circumference_mm = PI * pitch_diameter_mm;
derived_belt_pitch_mm = pitch_circumference_mm / tooth_count;

// --- Geometry parameters ---
pulley_width_mm = 12;

tooth_radial_height_mm = 1.2;
tooth_tangential_width_factor = 0.55;
tooth_overlap_mm = 0.8;

// Ensure teeth actually protrude beyond pitch radius (so pitch diameter is meaningful)
root_radius_offset_mm = 1.0;

bore_diameter_mm = 8;

hub_diameter_mm = 24;
hub_length_mm = 18;

flange_diameter_mm = 60;
flange_thickness_mm = 1.5;

set_screw_count = 2;
set_screw_hole_diameter_mm = 3.2;
set_screw_z_offset_mm = 0;

// Must be long enough to fully cut through hub diameter
set_screw_radial_reach_mm = hub_diameter_mm + 20;

connection_overlap_mm = 0.8;

// --- Teeth ---
module teeth() {
    pitch_r = pitch_diameter_mm/2;
    root_r  = pitch_r - root_radius_offset_mm;

    tooth_len = tooth_radial_height_mm + tooth_overlap_mm;
    tooth_w   = derived_belt_pitch_mm * tooth_tangential_width_factor;

    // Place tooth so it overlaps into root cylinder by tooth_overlap_mm
    tooth_center_r = root_r + tooth_len/2 - tooth_overlap_mm;

    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i * 360/tooth_count])
            translate([tooth_center_r, 0, 0])
                cube([tooth_len, tooth_w, pulley_width_mm], center=true);
    }
}

// --- Solid pulley body (single connected union) ---
module pulley_solid() {
    pitch_r = pitch_diameter_mm/2;
    root_r  = pitch_r - root_radius_offset_mm;

    union() {
        // Root body under teeth
        cylinder(r=root_r, h=pulley_width_mm, center=true);

        // Teeth
        teeth();

        // Hub: ensure it overlaps the toothed body even if hub_length differs
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm + 2*connection_overlap_mm, center=true);

        // Flanges: connected to toothed body with overlap
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + connection_overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

module pulley() {
    // Through-feature height: guaranteed to pass through entire part
    total_h = max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm) + 6*connection_overlap_mm;

    difference() {
        pulley_solid();

        // Bore
        cylinder(r=bore_diameter_mm/2, h=total_h, center=true);

        // Set screw holes: radial, centered at set_screw_z_offset_mm
        if (set_screw_count > 0) {
            for (i = [0:set_screw_count-1]) {
                rotate([0, 0, i * 360/set_screw_count])
                    translate([0, 0, set_screw_z_offset_mm])
                        rotate([0, 90, 0])
                            cylinder(r=set_screw_hole_diameter_mm/2,
                                     h=set_screw_radial_reach_mm,
                                     center=true);
            }
        }
    }
}

pulley();