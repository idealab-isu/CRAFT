$fn = 96;

// Parameters (approx. Lichuan 80mm frame servo form factor)
motor_frame_size_mm = 80; //[40:160:1]
body_width_mm = 80; //[40:160:1]
body_height_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]

faceplate_thickness_mm = 8; //[4:16:1]
flange_outer_diameter_mm = 90; //[60:140:1]
mount_hole_pitch_mm = 70; //[40:120:1]
mount_hole_diameter_mm = 6; //[3:12:0.5]
mount_hole_depth_mm = 12; //[6:30:1]

shaft_diameter_mm = 19; //[8:40:0.5]
shaft_length_mm = 35; //[10:80:1]
shaft_flat_depth_mm = 1.5; //[0.5:4:0.1]
shaft_flat_length_mm = 25; //[8:60:1]

rear_boss_diameter_mm = 30; //[15:70:1]
rear_boss_length_mm = 18; //[8:50:1]

overlap_mm = 1; //[0.5:2:0.1]

// Added detail parameters
corner_r_mm = 4; //[0:10:0.5]
front_register_d_mm = 60; //[30:90:1]
front_register_h_mm = 3; //[1:8:0.5]

tie_rod_boss_d_mm = 10; //[6:16:0.5]
tie_rod_boss_h_mm = 3; //[1:8:0.5]
tie_rod_pitch_mm = 70; //[40:120:1]

connector_w_mm = 22; //[10:40:1]
connector_h_mm = 14; //[6:30:1]
connector_l_mm = 18; //[8:40:1]
connector_offset_y_mm = 22; //[0:35:1]
connector_offset_z_from_rear_mm = 22; //[10:60:1]

rib_depth_mm = 2; //[0:6:0.5]
rib_w_mm = 10; //[4:20:1]
rib_z_margin_mm = 18; //[8:40:1]

// More servo-like features
flange_tab_w_mm = 18;   //[8:30:1]
flange_tab_l_mm = 12;   //[6:25:1]
flange_tab_r_mm = 3;    //[0:8:0.5]

terminal_box_w_mm = 34; //[18:60:1]
terminal_box_h_mm = 26; //[12:50:1]
terminal_box_l_mm = 22; //[10:60:1]
terminal_box_offset_y_mm = 18; //[0:35:1]
terminal_box_offset_z_from_rear_mm = 30; //[10:70:1]

cable_gland_d1_mm = 14; //[8:24:1]
cable_gland_d2_mm = 10; //[6:20:1]
cable_gland_l1_mm = 10; //[6:25:1]
cable_gland_l2_mm = 8;  //[4:20:1]

// Helpers
module rounded_box(size=[10,10,10], r=2, center=true) {
  minkowski() {
    cube([max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)], center=center);
    sphere(r=r);
  }
}

module servo_motor() {
  color([0.15, 0.2, 0.35])
  union() {

    // --- Main body (square/rectangular servo housing) ---
    rounded_box([body_width_mm, body_height_mm, body_length_mm], r=corner_r_mm, center=true);

    // --- Side ribs (connected) ---
    rib_len = body_length_mm - 2*rib_z_margin_mm;
    for (sx = [-1, 1]) {
      translate([sx*(body_width_mm/2 + rib_depth_mm/2 - overlap_mm), 0, 0])
        rounded_box([rib_depth_mm, rib_w_mm, rib_len], r=min(1.5, rib_depth_mm/2), center=true);
    }

    // --- Front flange (circular) with mounting holes ---
    front_flange_z = body_length_mm/2 + faceplate_thickness_mm/2 - overlap_mm;
    translate([0, 0, front_flange_z])
      difference() {
        cylinder(r=flange_outer_diameter_mm/2, h=faceplate_thickness_mm, center=true);

        hole_h = max(faceplate_thickness_mm + 2*overlap_mm, mount_hole_depth_mm);
        for (x = [-1, 1], y = [-1, 1])
          translate([x * mount_hole_pitch_mm/2, y * mount_hole_pitch_mm/2, 0])
            cylinder(r=mount_hole_diameter_mm/2, h=hole_h, center=true);
      }

    // --- Flange tabs (square-ish corners typical of servo front) ---
    // Tabs are connected to the flange by overlapping into it.
    tab_z = front_flange_z;
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x*(mount_hole_pitch_mm/2), y*(mount_hole_pitch_mm/2), tab_z])
        rounded_box([flange_tab_w_mm, flange_tab_l_mm, faceplate_thickness_mm], r=flange_tab_r_mm, center=true);
    }

    // --- Front register / pilot (connected) ---
    front_register_z = body_length_mm/2 + faceplate_thickness_mm + front_register_h_mm/2 - overlap_mm;
    translate([0, 0, front_register_z])
      cylinder(r=front_register_d_mm/2, h=front_register_h_mm, center=true);

    // --- Tie-rod bosses (connected) ---
    tie_boss_z = body_length_mm/2 + faceplate_thickness_mm/2 - overlap_mm;
    for (x = [-1, 1], y = [-1, 1])
      translate([x * tie_rod_pitch_mm/2, y * tie_rod_pitch_mm/2, tie_boss_z])
        cylinder(r=tie_rod_boss_d_mm/2, h=tie_rod_boss_h_mm, center=true);

    // --- Output shaft with flat (connected) ---
    shaft_z = body_length_mm/2 + faceplate_thickness_mm + front_register_h_mm + shaft_length_mm/2 - overlap_mm;
    translate([0, 0, shaft_z])
      difference() {
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

        // D-flat: remove slab from +X side
        flat_cut_x = (shaft_diameter_mm/2) - shaft_flat_depth_mm;
        translate([flat_cut_x + shaft_diameter_mm, 0, 0])
          cube([2*shaft_diameter_mm, shaft_diameter_mm*2, shaft_flat_length_mm], center=true);
      }

    // --- Rear boss (connected) ---
    rear_boss_z = -body_length_mm/2 - rear_boss_length_mm/2 + overlap_mm;
    translate([0, 0, rear_boss_z])
      cylinder(r=rear_boss_diameter_mm/2, h=rear_boss_length_mm, center=true);

    // --- Terminal box (electrical connector housing), connected to body side ---
    // Place on right side (+X), near rear (-Z), offset in +Y.
    tbox_x = body_width_mm/2 + terminal_box_l_mm/2 - overlap_mm;
    tbox_y = terminal_box_offset_y_mm;
    tbox_z = -body_length_mm/2 + terminal_box_offset_z_from_rear_mm;
    translate([tbox_x, tbox_y, tbox_z])
      rounded_box([terminal_box_l_mm, terminal_box_w_mm, terminal_box_h_mm], r=2.5, center=true);

    // --- Cable gland (two-step cylinder), connected to terminal box outer face ---
    gland_x = tbox_x + terminal_box_l_mm/2 + cable_gland_l1_mm/2 - overlap_mm;
    gland_y = tbox_y;
    gland_z = tbox_z;
    translate([gland_x, gland_y, gland_z])
      rotate([0, 90, 0])
        union() {
          cylinder(d=cable_gland_d1_mm, h=cable_gland_l1_mm, center=true);
          translate([0, 0, (cable_gland_l1_mm/2 + cable_gland_l2_mm/2 - overlap_mm)])
            cylinder(d=cable_gland_d2_mm, h=cable_gland_l2_mm, center=true);
        }

    // --- Small auxiliary connector (optional), connected and kept within servo-like placement ---
    conn_x_center = (body_width_mm/2 + connector_l_mm/2 - overlap_mm);
    conn_y_center = -connector_offset_y_mm;
    conn_z_center = -body_length_mm/2 + connector_offset_z_from_rear_mm;
    translate([conn_x_center, conn_y_center, conn_z_center])
      rounded_box([connector_l_mm, connector_w_mm, connector_h_mm], r=2, center=true);

    // Strain-relief bump connected to auxiliary connector
    sr_l = max(6, connector_l_mm*0.45);
    sr_w = max(8, connector_w_mm*0.7);
    sr_h = max(6, connector_h_mm*0.6);
    translate([conn_x_center + (connector_l_mm/2 + sr_l/2 - overlap_mm), conn_y_center, conn_z_center])
      rounded_box([sr_l, sr_w, sr_h], r=2, center=true);
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();