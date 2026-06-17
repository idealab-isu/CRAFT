$fn = 220;

// Requirements
tooth_count = 20;
pitch_diameter_mm = 12.22;

// Belt/pulley sizing (GT2-like, simplified tooth blocks)
belt_pitch_mm = 2;
belt_width_mm = 6;

// Derived pitch radius (must match requirement)
pitch_radius_mm = pitch_diameter_mm/2;

// Tooth geometry (make teeth clearly visible)
tooth_radial_height_mm = 1.2;      // protrusion beyond pitch circle
tooth_tangential_width_mm = 1.35;  // width around circumference
tooth_overlap_mm = 0.9;            // overlap into root cylinder for connectivity

// Root diameter chosen so tooth inner edge is inside the root cylinder
root_radius_mm = pitch_radius_mm - tooth_overlap_mm;
root_diameter_mm = 2*root_radius_mm;

hub_diameter_mm = 16;
hub_length_mm = 10;

flange_diameter_mm = 18;
flange_thickness_mm = 1.5;

bore_diameter_mm = 5;

eps_mm = 0.25;

// Tooth placement: inner edge at (pitch_radius - overlap), outer edge at (pitch_radius + height)
tooth_radial_len_mm = tooth_radial_height_mm + tooth_overlap_mm;
tooth_center_r_mm = pitch_radius_mm + (tooth_radial_height_mm - tooth_overlap_mm)/2;

module pulley_solid() {
    union() {
        // Root/body under teeth (exactly supports tooth overlap)
        cylinder(r=root_radius_mm, h=belt_width_mm, center=true);

        // Hub (centered, overlaps root)
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Flanges (connected with slight overlap)
        translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - eps_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0, 0, -belt_width_mm/2 - flange_thickness_mm/2 + eps_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        // Teeth (radial array, protruding outward, overlapping into root)
        for (i = [0:tooth_count-1]) {
            rotate([0, 0, i*360/tooth_count])
                translate([tooth_center_r_mm, 0, 0])
                    cube([tooth_radial_len_mm, tooth_tangential_width_mm, belt_width_mm], center=true);
        }
    }
}

module assembly() {
    difference() {
        pulley_solid();
        // Bore through entire part (ensure full cut)
        cylinder(
            r=bore_diameter_mm/2,
            h=hub_length_mm + 2*(belt_width_mm + 2*flange_thickness_mm) + 20,
            center=true
        );
    }
}

assembly();