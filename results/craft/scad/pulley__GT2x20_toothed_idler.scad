// Parameters
tooth_count = 20; //[10:80:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = pitch_diameter_mm/2;
pulley_width_mm = 10; //[5:30:1]
bore_diameter_mm = 5; //[2:12:0.1]
hub_diameter_mm = 16; //[8:32:0.1]
hub_length_mm = 12; //[6:30:1]
flange_diameter_mm = 18; //[10:40:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
set_screw_count = 0; //[0:4:1]
set_screw_hole_diameter_mm = 3; //[1.5:6:0.1]
set_screw_z_mm = 6; //[0:30:0.1]
tooth_depth_mm = 1.2; //[0.6:2.4:0.05]
tooth_width_mm = 1.2; //[0.6:2.4:0.05]
tooth_root_clearance_mm = 0.3; //[0.1:0.8:0.05]
tooth_overlap_mm = 0.6; //[0.2:2:0.05]
hub_to_teeth_overlap_mm = 1; //[0.5:2:0.1]

$fn = 180;

// Teeth are modeled as CUTS (grooves) into an outer cylinder so they are always visible.
// Pitch diameter is enforced by setting the pitch circle at pitch_radius_mm.
module tooth_grooves() {
    pitch_r = pitch_radius_mm;

    // Outer radius (tooth tips) and root radius (groove bottom)
    outer_r = pitch_r + tooth_depth_mm/2;
    root_r  = pitch_r - tooth_depth_mm/2;

    // Groove radial depth (from outer surface inward)
    groove_depth = max(0.05, outer_r - root_r);

    // Make grooves slightly wider than tooth_width to ensure visibility after boolean ops
    groove_w = max(0.2, tooth_width_mm);

    // Groove length extends inward past root to guarantee full cut
    groove_len = groove_depth + tooth_overlap_mm;

    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i * 360 / tooth_count])
            // Place groove so its outer face starts at outer_r and cuts inward
            translate([outer_r - groove_len/2 + 0.01, 0, 0])
                cube([groove_len, groove_w, pulley_width_mm + 0.2], center=true);
    }
}

module pulley_solid() {
    pitch_r = pitch_radius_mm;

    // Enforce pitch diameter by defining tooth tip radius around pitch circle
    outer_r = pitch_r + tooth_depth_mm/2;

    union() {
        // Toothed body: outer cylinder minus grooves (still one connected solid)
        difference() {
            cylinder(r=outer_r, h=pulley_width_mm, center=true);
            tooth_grooves();
        }

        // Hub overlaps into toothed body to ensure connectivity
        cylinder(r=hub_diameter_mm/2,
                 h=hub_length_mm,
                 center=true);

        // Flanges overlap into pulley body
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - tooth_overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + tooth_overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

module pulley() {
    difference() {
        pulley_solid();

        // Bore through entire part
        total_h = max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm) + 2;
        cylinder(r=bore_diameter_mm/2, h=total_h, center=true);

        // Optional set screw holes (radial), placed through hub
        if (set_screw_count > 0) {
            for (k = [0:set_screw_count-1]) {
                rotate([0, 0, k * 360 / set_screw_count])
                    translate([hub_diameter_mm/2 - set_screw_hole_diameter_mm/2, 0,
                               set_screw_z_mm - hub_length_mm/2])
                        rotate([0, 90, 0])
                            cylinder(r=set_screw_hole_diameter_mm/2,
                                     h=hub_diameter_mm + 2,
                                     center=true);
            }
        }
    }
}

pulley();