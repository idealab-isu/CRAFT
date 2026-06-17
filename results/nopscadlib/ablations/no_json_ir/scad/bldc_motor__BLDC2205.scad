$fn = 128;

// Brushless DC motor (single connected solid)
// Constraint: stator OD = 28.0mm, stator height = 17.25mm
stator_od = 28.0;
stator_h  = 17.25;

// Stator geometry
bore_d        = 8.0;     // center bore
yoke_th       = 2.2;     // back iron thickness
tooth_len     = 3.2;     // radial tooth length into bore
tooth_w       = 2.2;     // tooth tangential width
num_teeth     = 12;
tooth_overlap = 0.6;     // overlap into yoke for connectivity

// Motor "complete" features (kept as ONE connected solid)
can_wall      = 1.2;     // outer can thickness
can_lip_h     = 0.8;     // small lips at both ends
can_lip_over  = 0.6;     // lip radial overhang beyond stator OD
endbell_th    = 1.6;     // endbell thickness (each side)
shaft_d       = 3.0;     // shaft diameter
shaft_out     = 6.0;     // shaft protrusion each side beyond endbells
mount_boss_d  = 6.0;     // mounting boss diameter
mount_boss_h  = 1.2;     // mounting boss height (outside endbell)
mount_pcd     = 19.0;    // mounting hole pattern diameter
mount_hole_d  = 3.0;     // mounting hole diameter
num_mount     = 4;

// Small chamfers for stator yoke silhouette
chamfer_h = 0.6;
chamfer_inset = 0.6;

// Derived radii
stator_r   = stator_od/2;
bore_r     = bore_d/2;
yoke_r_in  = stator_r - yoke_th;

// Tooth placement radius (center of tooth block)
tooth_center_r = yoke_r_in - tooth_len/2 + tooth_overlap;

// Ensure teeth don't intrude into bore
tooth_inner_r = tooth_center_r - tooth_len/2;
tooth_len_eff = (tooth_inner_r < bore_r + 0.2)
    ? (tooth_len - ((bore_r + 0.2) - tooth_inner_r))
    : tooth_len;

tooth_center_r_eff = yoke_r_in - tooth_len_eff/2 + tooth_overlap;

// Motor overall stack (centered at Z=0)
motor_h = stator_h + 2*endbell_th;

// Can dimensions (covers stator + endbells)
can_od = stator_od + 2*can_wall;
can_id = stator_od; // inner diameter matches stator OD for a snug "cover"

// Lips (slight overhang)
lip_od = stator_od + 2*can_lip_over;
lip_id = can_id;

// Shaft length through motor + protrusions
shaft_h = motor_h + 2*shaft_out;

// Z positions (formulas, no arbitrary offsets)
z_endbell_top =  motor_h/2 - endbell_th/2;
z_endbell_bot = -motor_h/2 + endbell_th/2;
z_lip_top     =  motor_h/2 - can_lip_h/2;
z_lip_bot     = -motor_h/2 + can_lip_h/2;

module chamfered_ring(od, id, h, ch_h, inset) {
    mid_h = max(0, h - 2*ch_h);
    union() {
        translate([0,0,-h/2 + ch_h/2])
            difference() {
                cylinder(d1=od, d2=od-2*inset, h=ch_h, center=true);
                cylinder(d1=id, d2=id+2*inset, h=ch_h+0.02, center=true);
            }

        if (mid_h > 0)
            difference() {
                cylinder(d=od-2*inset, h=mid_h, center=true);
                cylinder(d=id+2*inset, h=mid_h+0.02, center=true);
            }

        translate([0,0, h/2 - ch_h/2])
            difference() {
                cylinder(d1=od-2*inset, d2=od, h=ch_h, center=true);
                cylinder(d1=id+2*inset, d2=id, h=ch_h+0.02, center=true);
            }
    }
}

module stator_teeth() {
    for (i = [0:num_teeth-1]) {
        rotate([0,0,i*360/num_teeth])
            translate([tooth_center_r_eff, 0, 0])
                cube([tooth_len_eff, tooth_w, stator_h], center=true);
    }
}

module stator_core() {
    // ONE connected solid: yoke ring + teeth, with bore removed
    difference() {
        union() {
            chamfered_ring(
                od = stator_od,
                id = 2*yoke_r_in,
                h  = stator_h,
                ch_h = chamfer_h,
                inset = chamfer_inset
            );
            stator_teeth();
        }
        cylinder(r=bore_r, h=stator_h + 0.5, center=true);
    }
}

module motor_can_shell() {
    // Outer can wall spanning full motor height, plus small lips at both ends
    union() {
        // main can wall
        difference() {
            cylinder(d=can_od, h=motor_h, center=true);
            cylinder(d=can_id, h=motor_h + 0.5, center=true);
        }

        // top lip
        translate([0,0,z_lip_top])
            difference() {
                cylinder(d=lip_od, h=can_lip_h, center=true);
                cylinder(d=lip_id, h=can_lip_h + 0.5, center=true);
            }

        // bottom lip
        translate([0,0,z_lip_bot])
            difference() {
                cylinder(d=lip_od, h=can_lip_h, center=true);
                cylinder(d=lip_id, h=can_lip_h + 0.5, center=true);
            }
    }
}

module endbells_and_mounts() {
    // Two endbells (discs) that close the can and provide mounting bosses.
    // Holes are subtracted later in the final difference() so everything stays connected.
    union() {
        // top endbell
        translate([0,0,z_endbell_top])
            cylinder(d=can_od, h=endbell_th, center=true);

        // bottom endbell
        translate([0,0,z_endbell_bot])
            cylinder(d=can_od, h=endbell_th, center=true);

        // mounting bosses on bottom endbell (outside)
        // Connected by overlapping into the endbell thickness.
        for (i = [0:num_mount-1]) {
            rotate([0,0,i*360/num_mount])
                translate([mount_pcd/2, 0, -motor_h/2 - mount_boss_h/2 + 0.2])
                    cylinder(d=mount_boss_d, h=mount_boss_h + 0.4, center=true);
        }
    }
}

module shaft_solid() {
    // Shaft passes through bore and protrudes both sides; connected to endbells via overlap.
    cylinder(d=shaft_d, h=shaft_h, center=true);
}

module brushless_dc_motor_one_solid() {
    // Build as a single connected solid, then subtract holes/voids.
    difference() {
        union() {
            // Stator (exact requested dimensions)
            stator_core();

            // Can + endbells (connected to stator by overlap via can inner diameter)
            motor_can_shell();
            endbells_and_mounts();

            // Shaft (connected through endbells)
            shaft_solid();
        }

        // Mounting holes through bottom endbell + bosses (do not disconnect the model)
        for (i = [0:num_mount-1]) {
            rotate([0,0,i*360/num_mount])
                translate([mount_pcd/2, 0, -motor_h/2 - mount_boss_h/2 + 0.2])
                    cylinder(d=mount_hole_d, h=endbell_th + mount_boss_h + 2.0, center=true);
        }

        // Optional: small clearance recess inside can to hint rotor space (kept shallow so it doesn't
        // break connectivity; it only removes material from inside the can wall region).
        // This also helps top/bottom views show internal structure.
        cylinder(d=stator_od - 2.0, h=stator_h*0.6, center=true);
    }
}

brushless_dc_motor_one_solid();