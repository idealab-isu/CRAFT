// Parameters
plate_width = 86; //[60:120]
plate_height = 86; //[60:120]
plate_thickness = 3; //[2:6]
overall_depth = 28; //[18:56]
top_width = 78; //[60:100]
top_height = 78; //[60:100]
wall_thickness = 2.5; //[1.5:5]
tolerances_clearance = 0.4; //[0.2:1.0]
pin_live_neutral_slot_length = 7; //[4:14]
pin_live_neutral_slot_width = 4.5; //[3:8]
pin_earth_slot_length = 8.5; //[5:16]
pin_earth_slot_width = 4.5; //[3:8]
pin_slot_depth = 10; //[6:20]
pin_ln_spacing_x = 22.2; //[18:28]
pin_ln_y = -11.1; //[-20:0]
pin_earth_y = 11.1; //[0:20]
mount_screw_pitch = 60.3; //[45:90]
mount_screw_clear_diameter = 3.5; //[2.5:5.5]
mount_counterbore_top_diameter = 7.5; //[5.5:12]
mount_counterbore_top_depth = 2; //[1:5]
mount_counterbore_rear_diameter = 6.5; //[0:12]
rear_cavity_depth = 22; //[12:50]
rear_cavity_margin = 10; //[6:18]
earth_connection_hole_diameter = 3.5; //[2.5:6]
earth_connection_hole_y = 25; //[10:35]
overlap = 1; //[0.5:2]

// Derived helpers
body_depth = overall_depth - plate_thickness + overlap;          // depth of rear body block
body_center_z = -plate_thickness/2 - body_depth/2 + overlap;     // ensures overlap into faceplate
front_z = plate_thickness/2;                                     // front face z
back_z  = -plate_thickness/2 - (overall_depth - plate_thickness);// back face z (approx)

// Mains Socket - solid geometry (single connected solid)
module mains_socket_solid() {
  union() {
    // Faceplate
    cube([plate_width, plate_height, plate_thickness], center=true);

    // Socket Body (overlaps faceplate by 'overlap')
    translate([0, 0, body_center_z])
      cube([top_width, top_height, body_depth], center=true);

    // FIX: Add small circular "boss/washer" features around screw holes
    // These were previously appearing as floating green/white circles in orthographic views.
    // Make them physically attached by overlapping into the faceplate by 1-2mm.
    boss_od = mount_counterbore_top_diameter; // keep design consistent with counterbore
    boss_h  = 2;                              // small visible ring height
    boss_z  = front_z - boss_h/2 + overlap;   // pushes boss into faceplate by 'overlap'

    for (sy = [mount_screw_pitch/2, -mount_screw_pitch/2]) {
      translate([0, sy, boss_z])
        cylinder(d=boss_od, h=boss_h, center=true, $fn=64);
    }
  }
}

// Mains Socket Holes - subtractive geometry
module mains_socket_holes() {
  union() {
    // Pin Apertures (ensure they cut through faceplate with overlap)
    translate([-pin_ln_spacing_x/2, pin_ln_y, front_z - (pin_slot_depth + overlap)/2 + overlap])
      cube([pin_live_neutral_slot_length + tolerances_clearance,
            pin_live_neutral_slot_width + tolerances_clearance,
            pin_slot_depth + overlap], center=true);

    translate([ pin_ln_spacing_x/2, pin_ln_y, front_z - (pin_slot_depth + overlap)/2 + overlap])
      cube([pin_live_neutral_slot_length + tolerances_clearance,
            pin_live_neutral_slot_width + tolerances_clearance,
            pin_slot_depth + overlap], center=true);

    translate([0, pin_earth_y, front_z - (pin_slot_depth + overlap)/2 + overlap])
      cube([pin_earth_slot_width + tolerances_clearance,
            pin_earth_slot_length + tolerances_clearance,
            pin_slot_depth + overlap], center=true);

    // Rear Cavity (inside body)
    // Keep it centered within the rear body volume and ensure it intersects by overlap.
    translate([0, 0, body_center_z - (body_depth - rear_cavity_depth)/2])
      cube([top_width - 2*wall_thickness,
            top_height - 2*wall_thickness,
            rear_cavity_depth + overlap], center=true);

    // Mounting Screw Holes (through all)
    for (sy = [mount_screw_pitch/2, -mount_screw_pitch/2]) {
      translate([0, sy, (front_z + back_z)/2])
        cylinder(d=mount_screw_clear_diameter + tolerances_clearance,
                 h=overall_depth + 4*overlap, center=true, $fn=64);
    }

    // Mounting Counterbores (front)
    for (sy = [mount_screw_pitch/2, -mount_screw_pitch/2]) {
      translate([0, sy, front_z - (mount_counterbore_top_depth + overlap)/2 + overlap])
        cylinder(d=mount_counterbore_top_diameter,
                 h=mount_counterbore_top_depth + overlap, center=true, $fn=64);
    }

    // Rear counterbore / clearance (rear)
    for (sy = [mount_screw_pitch/2, -mount_screw_pitch/2]) {
      translate([0, sy, body_center_z])
        cylinder(d=mount_counterbore_rear_diameter,
                 h=body_depth + 2*overlap, center=true, $fn=64);
    }

    // Earth Connection Hole (through all)
    translate([0, earth_connection_hole_y, (front_z + back_z)/2])
      cylinder(d=earth_connection_hole_diameter + tolerances_clearance,
               h=overall_depth + 4*overlap, center=true, $fn=64);
  }
}

// Assembly (single solid with holes)
module assembly() {
  difference() {
    mains_socket_solid();
    mains_socket_holes();
  }
}

assembly();