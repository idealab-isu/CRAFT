// Lichuan -80M04030B (approximate) - connected solid model
// Axis convention: Z = motor axis (front to rear). Front face at +Z.
// One connected solid: all added features overlap slightly; holes/slots subtracted at end.

$fn = 96;

// ---------------- Parameters ----------------
body_w = 80; //[40:160:1]
body_h = 80; //[40:160:1]
body_l = 120; //[60:240:1]

// Make the housing look like a servo: rounded edges + slight front step
body_corner_r = 6; //[0:12:0.5]
front_step_t  = 4; //[0:10:0.5]
front_step_inset = 3; //[0:8:0.5]

front_face_t = 6; //[3:12:0.5]
rear_cap_t   = 8; //[4:16:0.5]

flange_w = 90; //[60:140:1]
flange_h = 90; //[60:140:1]
flange_chamfer = 2; //[0.5:6:0.5]

mount_hole_d = 6.6; //[3:13.2:0.1]
mount_hole_spacing = 65; //[40:130:0.5]

pilot_d = 55; //[30:110:0.5]
pilot_h = 2.5; //[1:6:0.1]

shaft_d = 19; //[10:38:0.5]
shaft_l = 40; //[20:80:1]
shaft_flat_depth = 1.5; //[0.5:4:0.1]
shaft_flat_len = 25; //[10:60:1]
shaft_tap_d = 6; //[3:12:0.5]
shaft_tap_depth = 15; //[5:30:1]

// Rear features
brake_d = 70; //[40:120:0.5]
brake_l = 25; //[10:60:1]

cable_stub_d = 16; //[8:32:0.5]
cable_stub_l = 25; //[10:50:1]

connector_w = 22; //[10:44:1]
connector_h = 14; //[6:28:1]
connector_l = 18; //[8:36:1]

// Side cooling fins
fin_count = 6; //[3:12:1]
fin_t = 2; //[1:4:0.5]
fin_depth = 4; //[2:10:0.5]
fin_len = 70; //[30:120:1]

// Front face details
face_recess_d = 38; //[20:70:0.5]
face_recess_t = 1.2; //[0.5:3:0.1]
key_slot_w = 6; //[2:12:0.5]
key_slot_h = 2; //[1:6:0.5]
key_slot_l = 18; //[6:30:1]

// Small overlap to guarantee connectivity
overlap = 1; //[0.5:2:0.1]

// ---------------- Helpers ----------------
module chamfered_plate_xy(w,h,t,ch){
  difference(){
    cube([w,h,t], center=true);
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(w/2 - ch/2), sy*(h/2 - ch/2), 0])
        rotate([0,0,45])
          cube([ch, ch, t + 2*overlap], center=true);
  }
}

module rounded_box(size=[10,10,10], r=2){
  // Minkowski rounded box; centered
  // Keep r reasonable vs size to avoid degeneracy
  rr = min(r, min(size[0], min(size[1], size[2]))/2 - 0.01);
  minkowski(){
    cube([size[0]-2*rr, size[1]-2*rr, size[2]-2*rr], center=true);
    sphere(r=rr);
  }
}

module motor_complete(){
  difference(){
    union(){
      // Main housing (rounded)
      color("Black")
        rounded_box([body_w, body_h, body_l], body_corner_r);

      // Front step (slightly inset) to make front view recognizable
      if (front_step_t > 0)
        color("Black")
          translate([0,0, body_l/2 - front_step_t/2 + overlap])
            rounded_box([body_w-2*front_step_inset, body_h-2*front_step_inset, front_step_t + 2*overlap],
                        max(0, body_corner_r-2));

      // Front flange / mounting face (connected)
      color("Silver")
        translate([0,0, body_l/2 + front_face_t/2 - overlap])
          chamfered_plate_xy(flange_w, flange_h, front_face_t, flange_chamfer);

      // Front pilot boss (connected)
      color("Silver")
        translate([0,0, body_l/2 + front_face_t - overlap + pilot_h/2 - overlap])
          cylinder(h=pilot_h + 2*overlap, r=pilot_d/2, center=true);

      // Output shaft (connected)
      color("Silver")
        translate([0,0, body_l/2 + front_face_t - overlap + shaft_l/2 - overlap])
          cylinder(h=shaft_l + 2*overlap, r=shaft_d/2, center=true);

      // Rear endcap (connected)
      color("Black")
        translate([0,0, -body_l/2 - rear_cap_t/2 + overlap])
          rounded_box([body_w, body_h, rear_cap_t], max(0, body_corner_r-1));

      // Rear brake bulge (connected)
      color("Black")
        translate([0,0, -body_l/2 - rear_cap_t + overlap - brake_l/2 + overlap])
          cylinder(h=brake_l + 2*overlap, r=brake_d/2, center=true);

      // Cable exit stub (connected)
      color("Black")
        translate([0,0, -body_l/2 - rear_cap_t + overlap - cable_stub_l/2 + overlap])
          cylinder(h=cable_stub_l + 2*overlap, r=cable_stub_d/2, center=true);

      // Connector block (connected to rear endcap; offset to side)
      color("Black")
        translate([ body_w/2 - connector_w/2 + overlap,
                    0,
                    -body_l/2 - rear_cap_t + overlap - connector_l/2 + overlap])
          rounded_box([connector_w, connector_h, connector_l + 2*overlap], 1.2);

      // Cooling fins (connected to right side of body)
      color("DimGray")
      for (i = [1:fin_count]){
        translate([ body_w/2 + fin_depth/2 - overlap,
                    -body_h/2 + i*(body_h/(fin_count+1)),
                    0 ])
          cube([fin_depth, fin_t, fin_len], center=true);
      }
    }

    // ---------------- Subtractions ----------------

    // Mounting holes through front face
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2,
                 body_l/2 + front_face_t/2 - overlap])
        cylinder(h=front_face_t + 6*overlap, r=mount_hole_d/2, center=true);

    // Front circular recess around pilot (visual detail)
    translate([0,0, body_l/2 + front_face_t - face_recess_t/2 - overlap])
      cylinder(h=face_recess_t + 2*overlap, r=face_recess_d/2, center=true);

    // Small key/slot on front face (visual detail)
    translate([0,0, body_l/2 + front_face_t - key_slot_h/2 - overlap])
      cube([key_slot_w, key_slot_l, key_slot_h + 2*overlap], center=true);

    // Shaft flat (D-shaft) near the tip
    translate([ shaft_d/2 - shaft_flat_depth/2, 0,
                body_l/2 + front_face_t - overlap + shaft_l - shaft_flat_len/2 - overlap])
      cube([shaft_d, shaft_d, shaft_flat_len + 2*overlap], center=true);

    // Tapped hole in shaft end
    translate([0,0,
               body_l/2 + front_face_t - overlap + shaft_l - shaft_tap_depth/2 - overlap])
      cylinder(h=shaft_tap_depth + 2*overlap, r=shaft_tap_d/2, center=true);
  }
}

// Render
motor_complete();