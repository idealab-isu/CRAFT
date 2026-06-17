// Timing pulley: 20 teeth, 12.22mm pitch diameter
// Single connected solid (union), with bore removed (difference)

$fn = 220;

// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pulley_width_mm = 10; //[5:30:1]

tooth_radial_height_mm = 0.75; //[0.4:1.5:0.01]
tooth_root_clearance_mm = 0.35; //[0.1:0.8:0.01]
tooth_tangential_width_factor = 0.55; //[0.35:0.8:0.01]
tooth_overlap_mm = 0.6; //[0.2:1.5:0.01]

hub_diameter_mm = 18; //[9:36:0.1]
hub_length_mm = 14; //[7:28:1]

bore_diameter_mm = 5; //[2:12:0.01]
bore_clearance_mm = 0.2; //[0:0.6:0.01]

flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 22; //[12:44:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]

overlap_mm = 0.8; //[0.3:2:0.1]

// Derived
pitch_r = pitch_diameter_mm/2;
tooth_pitch_mm = PI * pitch_diameter_mm / tooth_count;
tooth_w = tooth_pitch_mm * tooth_tangential_width_factor;

// Tooth geometry (radial)
tooth_len = tooth_radial_height_mm + tooth_overlap_mm;

// Rim under teeth: keep it below pitch circle so teeth are visible in silhouette
root_r = pitch_r - tooth_root_clearance_mm;
rim_r  = max(0.1, root_r - tooth_overlap_mm);   // smaller than pitch_r so teeth protrude clearly
outer_r = pitch_r + tooth_radial_height_mm;

// Place tooth so its inner face overlaps into rim by tooth_overlap_mm and outer face reaches outer_r
tooth_center_r = rim_r + tooth_len/2 - tooth_overlap_mm;

module teeth() {
    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
            translate([tooth_center_r, 0, 0])
                cube([tooth_len, tooth_w, pulley_width_mm], center=true);
    }
}

module pulley_solid() {
    union() {
        // Rim core (under teeth)
        cylinder(r=rim_r, h=pulley_width_mm, center=true);

        // Teeth (20, clearly protruding)
        teeth();

        // Hub (centered, overlaps rim/teeth region to ensure one connected solid)
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Flanges (connected with calculated overlap)
        if (flange_enabled) {
            translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
                cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
            translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
                cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        }
    }
}

difference() {
    pulley_solid();

    // Bore (through all)
    cylinder(
        r=(bore_diameter_mm + bore_clearance_mm)/2,
        h=hub_length_mm + 2*flange_thickness_mm + pulley_width_mm + 2,
        center=true
    );
}