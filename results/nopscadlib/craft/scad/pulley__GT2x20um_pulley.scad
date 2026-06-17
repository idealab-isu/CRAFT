// Timing pulley: 20 teeth, pitch diameter 12.22mm
// Model is one connected solid; teeth are visible and countable.

tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = pitch_diameter_mm/2;

pulley_width_mm = 10; //[5:30:1]
bore_diameter_mm = 5; //[2:12:0.1]

hub_diameter_mm = 16; //[10:32:0.1]
hub_length_mm = 14; //[7:28:1]

flange_diameter_mm = 18; //[12:36:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]

tooth_radial_height_mm = 1.2; //[0.6:2.4:0.05]
tooth_root_depth_mm = 0.6; //[0.3:1.5:0.05]
tooth_tangential_width_mm = 1.2; //[0.6:2.4:0.05]
tooth_tip_round_radius_mm = 0.35; //[0.2:1.0:0.05]

tooth_overlap_mm = 0.8; //[0.3:2:0.1]
connection_overlap_mm = 1; //[0.5:2:0.1]

$fn = 180;

// Derived
tooth_pitch_angle = 360/tooth_count;
root_radius_mm = pitch_radius_mm - tooth_root_depth_mm;
tooth_outer_radius_mm = pitch_radius_mm + tooth_radial_height_mm;

// Ensure teeth are not hidden by hub (hub must be <= root radius)
hub_radius_mm = min(hub_diameter_mm/2, root_radius_mm - 0.2);
hub_diameter_mm_eff = 2*hub_radius_mm;

// Tooth geometry helpers
tooth_len_mm = tooth_radial_height_mm + tooth_overlap_mm;
tooth_center_r_mm = root_radius_mm + tooth_len_mm/2 - tooth_overlap_mm;

// Pulley body (root cylinder + hub + flanges), all connected via overlaps
module pulley_body() {
    union() {
        // Root cylinder (under teeth)
        cylinder(r=root_radius_mm, h=pulley_width_mm, center=true);

        // Hub (centered, overlaps root cylinder)
        cylinder(r=hub_radius_mm, h=hub_length_mm, center=true);

        // Flanges (overlap into toothed section)
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + connection_overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

// One tooth: radial block + rounded tip, protruding beyond pitch radius
module one_tooth() {
    union() {
        // Tooth block: overlaps into root cylinder by tooth_overlap_mm
        translate([tooth_center_r_mm, 0, 0])
            cube([tooth_len_mm, tooth_tangential_width_mm, pulley_width_mm], center=true);

        // Rounded tip at outer radius
        translate([tooth_outer_radius_mm - tooth_tip_round_radius_mm, 0, 0])
            cylinder(r=tooth_tip_round_radius_mm, h=pulley_width_mm, center=true);
    }
}

// Teeth array
module teeth() {
    for (i = [0:tooth_count-1])
        rotate([0, 0, i*tooth_pitch_angle])
            one_tooth();
}

// Assembly: one connected solid with bore removed
module assembly() {
    difference() {
        union() {
            pulley_body();
            teeth();
        }

        // Central bore: long enough to cut through hub + flanges with margin
        cylinder(
            r=bore_diameter_mm/2,
            h=max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm) + 4*connection_overlap_mm,
            center=true
        );
    }
}

assembly();