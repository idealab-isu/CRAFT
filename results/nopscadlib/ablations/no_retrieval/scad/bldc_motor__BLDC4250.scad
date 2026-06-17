$fn = 128;

// =====================
// Parameters (mm)
// =====================
stator_d = 42.5;                 // requested stator diameter (used as motor OD here)
motor_h  = 48.0;                 // requested overall can height (excluding shaft)

can_wall_t = 1.0;
endcap_h   = 2.0;

stator_h = 40.0;
stator_clearance = 0.5;

overlap = 0.6;                   // small intentional overlap to guarantee connectivity

// Shaft (front only, typical BLDC)
shaft_d = 5.0;
shaft_len_front = 15.0;

// Front boss (bearing seat / face boss)
front_boss_d = 16.0;
front_boss_h = 2.5;

// Rear boss (small rear bearing seat)
rear_boss_d = 12.0;
rear_boss_h = 1.8;

// Mounting holes on front face
mount_hole_d = 3.0;
mount_hole_pcd = 32.0;
mount_hole_depth = 3.0;

// Rear vent holes
vent_hole_d = 3.0;
vent_hole_depth = 2.0;
vent_hole_pcd = 24.0;

// Side wire exit (connected)
wire_exit_w = 8.0;
wire_exit_t = 4.0;
wire_exit_h = 6.0;
wire_exit_z = -12.0;

// Side "sensor/connector" bump (connected) to make side profile recognizable
side_bump_w = 10.0;
side_bump_t = 3.0;
side_bump_h = 10.0;
side_bump_z = 6.0;

// Label band
label_band_h = 12.0;
label_band_t = 0.4;

// Edge chamfers
chamfer_h = 1.0;
chamfer_rad_reduction = 1.0;

// =====================
// Derived
// =====================
can_r = stator_d/2;                              // motor outer radius (matches requested diameter)
stator_r = can_r - can_wall_t - stator_clearance;

stator_h_eff = min(stator_h, motor_h - 2*endcap_h - 2*overlap);

// Z positions (motor centered at origin)
z_front_face =  motor_h/2;
z_rear_face  = -motor_h/2;

// Shaft: starts at front face and extends forward
shaft_center_z = z_front_face + shaft_len_front/2 - overlap/2;

// Bosses: sit on faces and overlap into can
front_boss_center_z = z_front_face + front_boss_h/2 - overlap;
rear_boss_center_z  = z_rear_face  - rear_boss_h/2  + overlap;

// =====================
// Base Shapes
// =====================
module motor_body_can() {
    cylinder(h=motor_h, r=can_r, center=true);
}

module endcap_front() {
    // Slightly overlaps into can
    translate([0,0, z_front_face - endcap_h/2 + overlap])
        cylinder(h=endcap_h + 2*overlap, r=can_r, center=true);
}

module endcap_rear() {
    translate([0,0, z_rear_face + endcap_h/2 - overlap])
        cylinder(h=endcap_h + 2*overlap, r=can_r, center=true);
}

module stator_core_placeholder() {
    // Internal cylinder (kept inside; overlaps can volume so it's one solid)
    cylinder(h=stator_h_eff, r=stator_r, center=true);
}

module shaft_front() {
    translate([0,0, shaft_center_z])
        cylinder(h=shaft_len_front, r=shaft_d/2, center=true);
}

module front_boss() {
    translate([0,0, front_boss_center_z])
        cylinder(h=front_boss_h, r=front_boss_d/2, center=true);
}

module rear_boss() {
    translate([0,0, rear_boss_center_z])
        cylinder(h=rear_boss_h, r=rear_boss_d/2, center=true);
}

module wire_leads_exit() {
    // Side protrusion connected to can with overlap
    translate([can_r + wire_exit_t/2 - overlap, 0, wire_exit_z])
        cube([wire_exit_t, wire_exit_w, wire_exit_h], center=true);
}

module side_bump() {
    // Another side feature to make left/right orthographic views show side profile
    translate([can_r + side_bump_t/2 - overlap, 0, side_bump_z])
        cube([side_bump_t, side_bump_w, side_bump_h], center=true);
}

module label_band() {
    // Slightly proud band around can; intersects can so it's one solid
    cylinder(h=label_band_h, r=can_r + label_band_t, center=true);
}

// =====================
// Holes (subtractive)
// =====================
module mounting_holes_front() {
    // 4 holes on front endcap face (drill into motor)
    for (a = [0:90:270]) {
        rotate([0,0,a])
            translate([mount_hole_pcd/2, 0, z_front_face - mount_hole_depth/2 + overlap])
                cylinder(h=mount_hole_depth + 2*overlap, r=mount_hole_d/2, center=true);
    }
}

module vent_holes_rear() {
    // 3 holes on rear endcap face
    for (a = [0:120:240]) {
        rotate([0,0,a])
            translate([vent_hole_pcd/2, 0, z_rear_face + vent_hole_depth/2 - overlap])
                cylinder(h=vent_hole_depth + 2*overlap, r=vent_hole_d/2, center=true);
    }
}

// =====================
// Chamfers (additive rings)
// =====================
module chamfer_ring_front() {
    translate([0,0, z_front_face - chamfer_h/2 + overlap])
        difference() {
            cylinder(h=chamfer_h + 2*overlap, r1=can_r, r2=can_r - chamfer_rad_reduction, center=true);
            cylinder(h=chamfer_h + 4*overlap, r=can_r - chamfer_rad_reduction, center=true);
        }
}

module chamfer_ring_rear() {
    translate([0,0, z_rear_face + chamfer_h/2 - overlap])
        difference() {
            cylinder(h=chamfer_h + 2*overlap, r1=can_r - chamfer_rad_reduction, r2=can_r, center=true);
            cylinder(h=chamfer_h + 4*overlap, r=can_r - chamfer_rad_reduction, center=true);
        }
}

// =====================
// Complete Model (ONE connected solid)
// =====================
module complete_motor_model() {
    difference() {
        union() {
            // Main can and endcaps (connected via overlap)
            motor_body_can();
            endcap_front();
            endcap_rear();

            // External recognizable BLDC features
            front_boss();
            rear_boss();
            shaft_front();

            // Side features so left/right orthographic views show side profile
            wire_leads_exit();
            side_bump();

            // Cosmetic band and edge details
            label_band();
            chamfer_ring_front();
            chamfer_ring_rear();

            // Internal placeholder (still connected by overlap with can volume)
            stator_core_placeholder();
        }

        // Subtractive features
        mounting_holes_front();
        vent_holes_rear();
    }
}

// Final Output
complete_motor_model();