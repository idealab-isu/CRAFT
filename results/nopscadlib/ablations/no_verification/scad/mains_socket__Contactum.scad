$fn = 64;

// Parameters
plate_w = 86; //[60:172]
plate_h = 86; //[60:172]
plate_t = 3; //[2:6]
body_w = 75; //[50:150]
body_h = 75; //[50:150]
body_d = 35; //[20:70]
wall_t = 2.5; //[1.5:5]
cavity_clearance = 1; //[0.5:2]
overlap = 1; //[0.5:2]
pin_hole_depth = 8; //[5:16]
pin_pitch_x = 22.2; //[18:30]
pin_offset_y = 11.1; //[8:16]
ln_hole_w = 7; //[5:10]
ln_hole_h = 4.5; //[3:7]
earth_hole_w = 4.5; //[3:7]
earth_hole_h = 8.5; //[6:12]
mount_screw_pitch_y = 60.3; //[45:120]
mount_screw_d = 3.5; //[2.5:5]
mount_screw_head_d = 7; //[5:12]
mount_screw_head_depth = 1.5; //[1:4]
earth_terminal_hole_d = 4; //[3:6]
earth_terminal_washer_d = 10; //[7:16]
earth_inset = 8; //[5:16]

// Derived / helpers
eps = 0.01;
front_z = plate_t/2;
back_z  = -(plate_t/2 + body_d/2 - overlap); // body overlaps into plate by "overlap"
total_h = plate_t + body_d + 2*overlap;

// Rounded rectangle (2D)
module rrect2d(w,h,r){
  r2 = min(r, min(w,h)/2);
  hull(){
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(w/2-r2), sy*(h/2-r2)]) circle(r=r2);
  }
}

// Slot with rounded ends (3D) oriented along Y
module slot3d(len_y, wid_x, h_z){
  // len_y is overall length along Y, wid_x overall width along X
  // Uses hull of two cylinders to create rounded ends
  hull(){
    translate([0,  (len_y/2 - wid_x/2), 0]) cylinder(r=wid_x/2, h=h_z, center=true);
    translate([0, -(len_y/2 - wid_x/2), 0]) cylinder(r=wid_x/2, h=h_z, center=true);
  }
}

// Slot with rounded ends (3D) oriented along X
module slot3d_x(len_x, wid_y, h_z){
  hull(){
    translate([ (len_x/2 - wid_y/2), 0, 0]) cylinder(r=wid_y/2, h=h_z, center=true);
    translate([-(len_x/2 - wid_y/2), 0, 0]) cylinder(r=wid_y/2, h=h_z, center=true);
  }
}

// Main solid (one connected piece)
module mains_socket_solid(){
  union(){
    // Faceplate with slight edge radius
    translate([0,0,front_z])
      linear_extrude(height=plate_t, center=true)
        rrect2d(plate_w, plate_h, 2);

    // Socket body (back box) connected with overlap
    translate([0,0,back_z])
      cube([body_w, body_h, body_d], center=true);

    // Earth terminal washer/boss on faceplate (raised ring)
    // Keep it connected to faceplate by overlapping slightly into plate
    translate([-plate_w/2 + earth_inset, -plate_h/2 + earth_inset, front_z - (plate_t/2) + (mount_screw_head_depth/2)])
      cylinder(r=earth_terminal_washer_d/2, h=mount_screw_head_depth + overlap, center=true);
  }
}

// All cutouts (holes/slots/cavity)
module mains_socket_cutouts(){
  union(){
    // --- BS1363 style apertures (old unswitched) ---
    // Live/Neutral vertical slots
    // Cut through plate and a bit into body for visible depth
    cut_h = plate_t + pin_hole_depth + 2*overlap;
    cut_z = front_z - (pin_hole_depth/2); // starts at face and goes inward

    translate([-pin_pitch_x/2, -pin_offset_y, cut_z])
      slot3d(len_y=ln_hole_h, wid_x=ln_hole_w, h_z=cut_h);

    translate([ pin_pitch_x/2, -pin_offset_y, cut_z])
      slot3d(len_y=ln_hole_h, wid_x=ln_hole_w, h_z=cut_h);

    // Earth slot (taller)
    translate([0, pin_offset_y, cut_z])
      slot3d(len_y=earth_hole_h, wid_x=earth_hole_w, h_z=cut_h);

    // Subtle recess around apertures (old face detail)
    recess_depth = 0.8;
    recess_z = front_z - (recess_depth/2) + eps;
    translate([0, 0, recess_z])
      linear_extrude(height=recess_depth + eps, center=true)
        rrect2d(plate_w*0.62, plate_h*0.42, 2);

    // --- Mounting screw holes + counterbores ---
    // Through hole
    for (sy=[-1,1]){
      translate([0, sy*mount_screw_pitch_y/2, 0])
        cylinder(r=mount_screw_d/2, h=total_h, center=true);

      // Counterbore from front
      translate([0, sy*mount_screw_pitch_y/2, front_z - (mount_screw_head_depth/2) + eps])
        cylinder(r=mount_screw_head_d/2, h=mount_screw_head_depth + overlap, center=true);
    }

    // --- Earth terminal hole (through) ---
    translate([-plate_w/2 + earth_inset, -plate_h/2 + earth_inset, 0])
      cylinder(r=earth_terminal_hole_d/2, h=total_h, center=true);

    // --- Back cavity (hollow box) ---
    // Keep a back wall thickness of wall_t; open from the front is NOT desired,
    // so cavity starts behind the plate and leaves a back wall.
    inner_w = body_w - 2*wall_t;
    inner_h = body_h - 2*wall_t;
    inner_d = body_d - wall_t + cavity_clearance;

    // Position cavity centered in body, but shifted so it doesn't break the front plate
    // Leave a front wall equal to wall_t behind the plate overlap region.
    // Body spans z: back_z ± body_d/2. Front face of body is at:
    body_front_z = back_z + body_d/2;
    // Start cavity slightly behind body front face:
    cavity_front_z = body_front_z - wall_t;
    // Cavity center z:
    cavity_center_z = cavity_front_z - inner_d/2;

    translate([0,0,cavity_center_z])
      cube([inner_w, inner_h, inner_d], center=true);
  }
}

// Assembly
difference(){
  mains_socket_solid();
  mains_socket_cutouts();
}