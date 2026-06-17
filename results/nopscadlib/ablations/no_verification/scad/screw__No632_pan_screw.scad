$fn = 96;

// Target dimensions (mm)
shaft_diameter_mm = 3.5;
length_under_head_mm = 10;
head_diameter_mm = 6.9;
head_height_mm = 2.5;

// Simple pan-head shaping + optional recess
under_head_transition_height_mm = 0.8;
head_top_round_mm = 0.6;          // small dome on top of pan head
tip_chamfer_height_mm = 0.8;      // small chamfer at tip

include_drive_recess_cut = 1;     // 0/1
drive_recess_diameter_mm = 3.2;
drive_recess_depth_mm = 1.2;

eps = 0.02;

module pan_head_screw() {
    r_shaft = shaft_diameter_mm/2;
    r_head  = head_diameter_mm/2;

    // Z layout: head sits on top of shaft
    z_head_center = length_under_head_mm + head_height_mm/2;
    z_trans_center = length_under_head_mm + under_head_transition_height_mm/2;
    z_shaft_center = length_under_head_mm/2;

    difference() {
        union() {
            // Shaft (under head length = 10mm)
            translate([0,0,z_shaft_center])
                cylinder(h=length_under_head_mm, r=r_shaft, center=true);

            // Under-head transition (slight flare into head)
            translate([0,0,z_trans_center])
                cylinder(h=under_head_transition_height_mm,
                         r1=r_shaft, r2=r_head, center=true);

            // Pan head main cylinder
            translate([0,0,z_head_center])
                cylinder(h=head_height_mm, r=r_head, center=true);

            // Slight dome on top of head (kept within head diameter)
            translate([0,0,length_under_head_mm + head_height_mm - head_top_round_mm])
                scale([1,1,head_top_round_mm/(r_head)])
                    sphere(r=r_head);

            // Small chamfer at tip (still total under-head length remains 10mm)
            translate([0,0,tip_chamfer_height_mm/2])
                cylinder(h=tip_chamfer_height_mm, r1=0.6*r_shaft, r2=r_shaft, center=true);
        }

        // Drive recess (simple cylindrical recess)
        if (include_drive_recess_cut) {
            z_recess_center = length_under_head_mm + head_height_mm - drive_recess_depth_mm/2;
            translate([0,0,z_recess_center])
                cylinder(h=drive_recess_depth_mm + eps, r=drive_recess_diameter_mm/2, center=true);
        }
    }
}

pan_head_screw();