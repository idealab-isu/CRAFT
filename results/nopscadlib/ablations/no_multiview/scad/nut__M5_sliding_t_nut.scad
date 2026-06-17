// Parameters
screw_thread_diameter_mm = 5; //[2.5:10:0.1]
screw_thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
across_flats_mm = 6; //[3:12:0.1]
thickness_mm = 3.7; //[1.85:7.4:0.1]
thread_engagement_mm = 3.7; //[1.85:7.4:0.1]
hole_minor_diameter_mm = 4.2; //[3.5:4.8:0.05]
hole_clearance_if_unthreaded_mm = 5.5; //[5:6.5:0.1]
edge_chamfer_mm = 0.3; //[0.1:0.8:0.05]
corner_fillet_mm = 0.2; //[0:1:0.05]
t_slot_nominal_width_mm = 10; //[5:20:0.5]
t_slot_neck_width_mm = 6; //[3:12:0.5]
t_slot_depth_mm = 6; //[3:12:0.5]
t_slot_wing_width_mm = 2; //[1:4:0.1]
t_slot_wing_thickness_mm = 1.6; //[0.8:3.2:0.1]
insertion_lead_in_length_mm = 1; //[0.5:3:0.1]
overlap_mm = 0.8; //[0.2:2:0.1]
body_length_mm = 12; //[6:24:0.5]
body_width_mm = 5.8; //[3:12:0.1]
wing_length_mm = 10; //[5:20:0.5]
thread_relief_diameter_mm = 6; //[5:10:0.1]
thread_relief_depth_mm = 0.6; //[0.2:2:0.1]
hex_prism_height_mm = 2.2; //[1:4.4:0.1]

// Extra overlap to guarantee attachment of the small corner wedge/tab features
attach_overlap_mm = 1.2; // (1-2mm) guaranteed intersection

// Hexagonal prism calculation
module hex_profile() {
  rotate([0, 0, 30]) {
    cylinder(r=(across_flats_mm/2)/cos(30), h=hex_prism_height_mm, center=true, $fn=6);
  }
}

// Small side clip/tab pieces (one on each side) - FIXED to be physically attached.
// These are placed on the OUTER sides of the wings (±Y) and overlap into the wing by attach_overlap_mm.
// Also spans full thickness so it cannot float above/below after chamfers.
module side_clips() {
  clip_len_x = 1.8;                         // small along X
  clip_w_y   = t_slot_wing_width_mm;        // matches wing width
  clip_h_z   = thickness_mm;                // span full thickness to avoid Z-floating

  // Put clips near the ends of the wings, but still within wing length.
  // Ensure intersection with wing by pushing inward in X by attach_overlap_mm.
  x_pos = wing_length_mm/2 - clip_len_x/2 - attach_overlap_mm;

  // Place on the OUTER face of each wing and overlap into the wing by attach_overlap_mm.
  // Wing center is at ±(body_width/2 + wing_w/2 - overlap).
  // Outer face of wing is at that center ± wing_w/2.
  wing_center_y = body_width_mm/2 + t_slot_wing_width_mm/2 - overlap_mm;
  y_pos = wing_center_y + t_slot_wing_width_mm/2 - attach_overlap_mm;

  for (sx = [-1, 1])
    for (sy = [-1, 1])
      translate([sx*x_pos, sy*y_pos, 0])
        cube([clip_len_x, clip_w_y, clip_h_z], center=true);
}

// T-slot nut with wings
module t_slot_nut() {
  union() {
    // Center body
    cube([body_length_mm, body_width_mm, thickness_mm], center=true);

    // Wings (ensure overlap into body)
    translate([0, -(body_width_mm/2 + t_slot_wing_width_mm/2 - overlap_mm), 0])
      cube([wing_length_mm, t_slot_wing_width_mm, t_slot_wing_thickness_mm], center=true);

    translate([0,  (body_width_mm/2 + t_slot_wing_width_mm/2 - overlap_mm), 0])
      cube([wing_length_mm, t_slot_wing_width_mm, t_slot_wing_thickness_mm], center=true);

    // Side clip/tab pieces (now guaranteed attached with 1-2mm overlap into wings)
    side_clips();

    // Hex profile (ensure overlap into body)
    translate([0, 0, (thickness_mm/2 - hex_prism_height_mm/2 + overlap_mm)])
      hex_profile();
  }
}

// Final nut with chamfers and holes
module nut_and_washer() {
  difference() {
    t_slot_nut();

    // Lead-in chamfers (cut from ends)
    translate([ body_length_mm/2 - insertion_lead_in_length_mm/2 + overlap_mm, 0, 0])
      rotate([0, 45, 0])
      cube([insertion_lead_in_length_mm, body_width_mm + 2*t_slot_wing_width_mm + 4*overlap_mm, thickness_mm + 4*overlap_mm], center=true);

    translate([-body_length_mm/2 + insertion_lead_in_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, -45, 0])
      cube([insertion_lead_in_length_mm, body_width_mm + 2*t_slot_wing_width_mm + 4*overlap_mm, thickness_mm + 4*overlap_mm], center=true);

    // Top/bottom edge chamfers
    translate([0, 0,  thickness_mm/2 - (edge_chamfer_mm + overlap_mm)/2 + overlap_mm])
      rotate([45, 0, 0])
      cube([body_length_mm + 4*overlap_mm, body_width_mm + 2*t_slot_wing_width_mm + 4*overlap_mm, edge_chamfer_mm + 2*overlap_mm], center=true);

    translate([0, 0, -thickness_mm/2 + (edge_chamfer_mm + overlap_mm)/2 - overlap_mm])
      rotate([-45, 0, 0])
      cube([body_length_mm + 4*overlap_mm, body_width_mm + 2*t_slot_wing_width_mm + 4*overlap_mm, edge_chamfer_mm + 2*overlap_mm], center=true);

    // Threaded hole
    cylinder(r=hole_minor_diameter_mm/2, h=thickness_mm + 4*overlap_mm, center=true);

    // Thread relief/counterbore top
    translate([0, 0,  thickness_mm/2 - (thread_relief_depth_mm)/2])
      cylinder(r=thread_relief_diameter_mm/2, h=thread_relief_depth_mm + 2*overlap_mm, center=true);

    // Thread relief/counterbore bottom
    translate([0, 0, -thickness_mm/2 + (thread_relief_depth_mm)/2])
      cylinder(r=thread_relief_diameter_mm/2, h=thread_relief_depth_mm + 2*overlap_mm, center=true);
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();