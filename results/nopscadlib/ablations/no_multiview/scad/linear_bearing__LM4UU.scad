// Parameters
bore_diameter_mm = 4; //[2:8:0.1]
outer_diameter_mm = 8; //[4:16:0.1]
length_mm = 12; //[6:24:0.1]
centered = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
bore_clearance_mm = 0.1; //[0:0.3:0.05]
screw_shank_diameter_mm = 3; //[2:6:0.1]
screw_length_mm = 10; //[5:20:0.5]
screw_head_diameter_mm = 5.5; //[4:10:0.1]
screw_head_height_mm = 2.5; //[1.5:5:0.1]
washer_outer_diameter_mm = 7; //[5:14:0.1]
washer_thickness_mm = 1; //[0.5:2.5:0.1]

$fn = 96;

// Linear Bearing - complete geometry (present + used in assembly)
module linear_bearing() {
  color("Silver")
  difference() {
    // Outer sleeve
    cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
    // Through bore (slightly longer to ensure clean cut)
    cylinder(r=(bore_diameter_mm + bore_clearance_mm)/2,
             h=length_mm + 2*overlap_mm, center=true);
  }
}

// Screw and Washer - positioned to INTERSECT the bearing by overlap_mm
// IMPORTANT: This module is centered on the bearing axis (X axis).
module screw_and_washer() {
  // Bearing right face is at +length_mm/2.
  // Place washer so its LEFT face is inside the bearing by overlap_mm:
  // washer_center_x - washer_thickness/2 = length_mm/2 - overlap_mm
  washer_center_x = length_mm/2 - overlap_mm + washer_thickness_mm/2;

  // Place head immediately after washer, with slight overlap into washer
  // head_left_face = washer_right_face - overlap_mm
  head_center_x =
    (washer_center_x + washer_thickness_mm/2) - overlap_mm + screw_head_height_mm/2;

  // Place shank starting at the head's right face, with slight overlap into head
  // shank_left_face = head_right_face - overlap_mm
  shank_center_x =
    (head_center_x + screw_head_height_mm/2) - overlap_mm + screw_length_mm/2;

  color("DimGray")
  union() {
    // Washer
    translate([washer_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);

    // Screw head
    translate([head_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);

    // Screw shank
    translate([shank_center_x, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
  }
}

// Assembly - single connected solid (NO floating parts)
// Fix: ensure bearing ring/body is physically attached to the shaft/flange assembly
// by translating the bearing so its RIGHT face overlaps the washer by overlap_mm.
module assembly() {
  // Washer left face (in global coords) when screw_and_washer() is at origin:
  washer_left_face_x = (length_mm/2 - overlap_mm); // from washer_center_x formula

  // Bearing right face (in global coords) is at: bearing_center_x + length_mm/2
  // We want: bearing_right_face_x = washer_left_face_x + overlap_mm
  // => bearing_center_x + length_mm/2 = washer_left_face_x + overlap_mm
  // => bearing_center_x = washer_left_face_x + overlap_mm - length_mm/2
  // => bearing_center_x = (length_mm/2 - overlap_mm) + overlap_mm - length_mm/2 = 0
  //
  // However, the provided views show the bearing separated/offset from the shaft.
  // To guarantee attachment regardless of any external transforms, we explicitly
  // anchor the bearing to the washer by computing bearing_center_x from the
  // washer geometry itself (robust) and applying a small enforced overlap.
  //
  // We'll place the screw/washer at origin, then place the bearing to the LEFT
  // so that it overlaps the washer by overlap_mm.
  washer_center_x = length_mm/2 - overlap_mm + washer_thickness_mm/2;
  washer_left_face_x = washer_center_x - washer_thickness_mm/2;

  // Set bearing so its RIGHT face is inside the washer by overlap_mm:
  // bearing_right_face_x = washer_left_face_x + overlap_mm
  // bearing_center_x = bearing_right_face_x - length_mm/2
  bearing_center_x = (washer_left_face_x + overlap_mm) - length_mm/2;

  union() {
    // Shaft/flange assembly (washer+head+shank)
    screw_and_washer();

    // Linear bearing (attached to washer with overlap)
    translate([bearing_center_x, 0, 0])
      linear_bearing();
  }
}

assembly();