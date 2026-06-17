$fn = 160;

// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pulley_width_mm = 10; //[5:30:0.5]
tooth_radial_height_mm = 0.8; //[0.4:1.6:0.05]
tooth_tangential_width_mm = 1.2; //[0.6:2.4:0.05]
tooth_rounding_radius_mm = 0.55; //[0.25:1.2:0.01]
rim_wall_thickness_mm = 1.2; //[0.6:3:0.1]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 16; //[10:32:0.5]
hub_length_mm = 12; //[6:30:0.5]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 18; //[12:40:0.5]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
set_screw_enabled = 1; //[0:1:1]
set_screw_count = 1; //[0:2:1]
set_screw_hole_diameter_mm = 3; //[2:6:0.1]
set_screw_z_offset_mm = 0; //[-10:10:0.5]
d_flat_enabled = 0; //[0:1:1]
d_flat_depth_mm = 0.6; //[0.2:2:0.05]
tolerance_mm = 0.2; //[0:0.6:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Derived radii
pitch_r = pitch_diameter_mm/2;
outer_r = pitch_r + tooth_radial_height_mm;

// Ensure rim exists and teeth are visible (rim OD slightly under tooth tips)
rim_outer_r = max(pitch_r - 0.25*tooth_radial_height_mm, pitch_r - 0.05);
root_r = max((bore_diameter_mm + tolerance_mm)/2 + rim_wall_thickness_mm,
             rim_outer_r - tooth_radial_height_mm - rim_wall_thickness_mm);

// Tooth 2D profile (in XY), extruded along Z
module tooth_2d() {
    // Rounded rectangle tooth, radial direction is +Y
    offset(r=tooth_rounding_radius_mm)
        polygon(points=[
            [-tooth_tangential_width_mm/2, 0],
            [ tooth_tangential_width_mm/2, 0],
            [ tooth_tangential_width_mm/2, tooth_radial_height_mm],
            [-tooth_tangential_width_mm/2, tooth_radial_height_mm]
        ]);
}

// Teeth ring (connected to rim by overlap)
module teeth_ring() {
    for (i = [0:tooth_count-1]) {
        rotate([0,0,i*360/tooth_count])
            // Put tooth radial axis along +X by rotating the 2D profile
            // and place its inner face slightly inside the rim for guaranteed union.
            translate([rim_outer_r - overlap_mm, 0, 0])
                rotate([0,0,-90])
                    linear_extrude(height=pulley_width_mm, center=true, convexity=10)
                        tooth_2d();
    }
}

// Main pulley solid (hub + rim + teeth + optional flanges) minus bore and set-screw holes
module pulley_solid() {
    union() {
        // Hub (centered)
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Rim body (annulus) at pulley width
        difference() {
            cylinder(r=rim_outer_r, h=pulley_width_mm, center=true);
            cylinder(r=root_r,      h=pulley_width_mm + 2*overlap_mm, center=true);
        }

        // Teeth (protrude outward beyond rim_outer_r up to outer_r)
        teeth_ring();

        // Flanges (connected with slight overlap)
        if (flange_enabled) {
            translate([0,0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
                cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
            translate([0,0,-pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
                cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        }
    }
}

module pulley() {
    total_h = max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm*flange_enabled) + 6*overlap_mm;

    difference() {
        pulley_solid();

        // Center bore (subtract from entire part)
        union() {
            cylinder(r=(bore_diameter_mm + tolerance_mm)/2, h=total_h, center=true);

            // Optional D-flat (subtract a slab from the bore)
            if (d_flat_enabled) {
                translate([(bore_diameter_mm + tolerance_mm)/2 - d_flat_depth_mm, 0, 0])
                    cube([(bore_diameter_mm + tolerance_mm),
                          (bore_diameter_mm + tolerance_mm),
                          total_h], center=true);
            }
        }

        // Set screw holes (radial through hub)
        if (set_screw_enabled && set_screw_count > 0) {
            for (i = [0:set_screw_count-1]) {
                rotate([0,0,i*360/set_screw_count])
                    translate([0,0,set_screw_z_offset_mm])
                        rotate([0,90,0])
                            cylinder(r=set_screw_hole_diameter_mm/2,
                                     h=hub_diameter_mm + 4*overlap_mm,
                                     center=true);
            }
        }
    }
}

pulley();