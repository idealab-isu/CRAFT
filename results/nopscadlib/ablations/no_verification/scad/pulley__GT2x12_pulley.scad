// Parameters
tooth_count = 12; //[6:24:1]
pitch_diameter_mm = 7.15; //[3.6:14.3:0.01]
pulley_width_mm = 10; //[5:20:1]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 12; //[6:24:0.1]
hub_length_mm = 14; //[7:28:1]
flange_diameter_mm = 16; //[8:32:0.1]
flange_thickness_mm = 1.5; //[0.8:3:0.1]
enable_flanges = 1; //[0:1:1]
belt_pitch_mm = 2; //[1:5:0.01]
tooth_profile_type = 2; //[0:2:1]
tooth_radial_height_mm = 0.9; //[0.4:1.8:0.05]
tooth_root_clearance_mm = 0.4; //[0.1:1.0:0.05]
tooth_tangential_width_factor = 0.55; //[0.35:0.8:0.01]
tooth_overlap_mm = 0.6; //[0.2:1.5:0.05]
set_screw_count = 1; //[0:2:1]
set_screw_hole_diameter_mm = 3; //[1.5:6:0.1]
set_screw_z_mm = 0; //[-20:20:0.5]
connection_overlap_mm = 0.8; //[0.5:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

$fn = 180;

// Derived radii (ensure teeth are visible and pitch diameter is respected)
pitch_r = pitch_diameter_mm/2;
root_r  = max(0.01, pitch_r - tooth_root_clearance_mm);
outer_r = pitch_r + tooth_radial_height_mm;

// Tooth sizing
tooth_pitch_arc = PI * pitch_diameter_mm / tooth_count;
tooth_w = max(0.25, tooth_pitch_arc * tooth_tangential_width_factor);
tooth_len = tooth_radial_height_mm + tooth_overlap_mm;

// Tooth: trapezoid-ish (2D) extruded to pulley width, placed so it overlaps into root cylinder
module tooth() {
    tip_w = max(0.20, tooth_w * 0.55);
    base_w = tooth_w;

    translate([root_r - tooth_overlap_mm, 0, -pulley_width_mm/2])
        linear_extrude(height=pulley_width_mm)
            polygon(points=[
                [0,          -base_w/2],
                [tooth_len,  -tip_w/2],
                [tooth_len,   tip_w/2],
                [0,           base_w/2]
            ]);
}

// Pulley assembly as ONE connected solid with bore subtracted
module timing_pulley() {
    difference() {
        union() {
            // Root cylinder for teeth to attach to (centered)
            cylinder(r=root_r, h=pulley_width_mm, center=true);

            // Teeth (12 teeth) - protrude outward from root_r to outer_r
            for (i = [0:tooth_count-1])
                rotate([0, 0, i*360/tooth_count])
                    tooth();

            // Hub (centered) - overlaps into pulley body to ensure connectivity
            cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

            // Flanges connected to pulley body with overlap
            if (enable_flanges) {
                translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm])
                    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

                translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + connection_overlap_mm])
                    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
            }
        }

        // Center bore (through hub)
        cylinder(r=bore_diameter_mm/2, h=hub_length_mm + 2*eps_mm, center=true);

        // Optional set screw holes (radial)
        if (set_screw_count > 0) {
            for (j = [0:set_screw_count-1]) {
                rotate([0, 0, j*180])
                    translate([0, 0, set_screw_z_mm])
                        rotate([0, 90, 0])
                            cylinder(r=set_screw_hole_diameter_mm/2,
                                     h=hub_diameter_mm + 2*eps_mm,
                                     center=true);
            }
        }
    }
}

timing_pulley();