// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 9.65; //[4.825:19.3:0.01]
pulley_width_mm = 10; //[5:30:1]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 14; //[7:28:0.1]
hub_length_mm = 12; //[6:24:0.5]
flange_diameter_mm = 18; //[9:36:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.05]
tooth_tangential_width_mm = 1.6; //[0.8:3.2:0.05]
tooth_root_clearance_mm = 0.6; //[0.2:1.5:0.05]
tooth_overlap_mm = 0.8; //[0.3:2:0.05]
eps_mm = 0.05; //[0.01:0.2:0.01]

$fn = 220;

// Derived radii (pitch diameter is enforced by construction)
pitch_r = pitch_diameter_mm/2;
root_r  = pitch_r - tooth_root_clearance_mm;
outer_r = root_r + tooth_radial_height_mm;

// Tooth geometry (radial array, protruding outward, overlaps into root cylinder)
tooth_len = tooth_radial_height_mm + tooth_overlap_mm;
tooth_center_r = root_r + tooth_len/2 - tooth_overlap_mm;

// Ensure the toothed body exists even if hub is smaller (keep one connected solid)
body_r = max(root_r, hub_diameter_mm/2);

// Main pulley (single connected solid)
module timing_pulley_16T_PD965() {
    difference() {
        union() {
            // Body cylinder under teeth (at least root radius)
            cylinder(r=body_r, h=pulley_width_mm, center=true);

            // Teeth (radial array)
            for (i = [0:tooth_count-1]) {
                rotate([0, 0, i*360/tooth_count])
                    translate([tooth_center_r, 0, 0])
                        cube([tooth_len, tooth_tangential_width_mm, pulley_width_mm], center=true);
            }

            // Hub (centered, overlaps body)
            cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

            // Flanges (connected with slight overlap)
            translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm])
                cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

            translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + eps_mm])
                cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        }

        // Bore (through hole)
        cylinder(
            r=bore_diameter_mm/2,
            h=max(hub_length_mm, pulley_width_mm) + 2*flange_thickness_mm + 4,
            center=true
        );
    }
}

timing_pulley_16T_PD965();