// Parameters
bore_diameter_mm = 6; //[3:12:0.1]
outer_diameter_mm = 12; //[6:24:0.1]
length_mm = 35; //[18:70:0.5]
wall_thickness_mm = 3; //[1.5:6:0.1]
end_chamfer_mm = 0.5; //[0:2:0.1]
connect_overlap_mm = 1; //[0.5:2:0.1]
screw_shank_diameter_mm = 3; //[2:6:0.1]
screw_length_mm = 10; //[5:25:0.5]
screw_head_diameter_mm = 6; //[4:12:0.1]
screw_head_height_mm = 2.5; //[1.5:6:0.1]
washer_outer_diameter_mm = 7; //[5:16:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]

// Linear Bearing - complete geometry
module linear_bearing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer casing
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

      // Inner bore
      cylinder(h=length_mm + 2*connect_overlap_mm, r=bore_diameter_mm/2, center=true);

      // End chamfers
      translate([0, 0, length_mm/2 - (end_chamfer_mm + connect_overlap_mm)/2])
        cylinder(h=end_chamfer_mm + connect_overlap_mm,
                 r1=bore_diameter_mm/2 + end_chamfer_mm, r2=bore_diameter_mm/2, center=true);

      translate([0, 0, -length_mm/2 + (end_chamfer_mm + connect_overlap_mm)/2])
        cylinder(h=end_chamfer_mm + connect_overlap_mm,
                 r1=bore_diameter_mm/2 + end_chamfer_mm, r2=bore_diameter_mm/2, center=true);
    }
  }
}

// Screw and Washer - complete geometry, positioned to OVERLAP the bearing by connect_overlap_mm
module screw_and_washer() {
  // Coordinate system:
  // Bearing is centered at origin, axis along Z.
  // Screw axis is along +X (via rotate([0,90,0])).
  // Ensure physical connection by pushing washer/screw into the bearing by connect_overlap_mm.
  //
  // Bearing outer surface is at x = outer_diameter_mm/2.
  // Washer spans along X by washer_thickness_mm (centered), so its inner face is at:
  //   x = washer_center_x - washer_thickness_mm/2
  // We want that inner face to be inside the bearing by connect_overlap_mm:
  //   washer_center_x - washer_thickness_mm/2 = outer_diameter_mm/2 - connect_overlap_mm
  // => washer_center_x = outer_diameter_mm/2 + washer_thickness_mm/2 - connect_overlap_mm

  washer_center_x = outer_diameter_mm/2 + washer_thickness_mm/2 - connect_overlap_mm;

  // Place screw shank so it overlaps the washer by connect_overlap_mm (guaranteed fusion)
  // Washer outer face is at x = washer_center_x + washer_thickness_mm/2
  // Shank spans along X by screw_length_mm (centered), so its left face is at:
  //   x = shank_center_x - screw_length_mm/2
  // Want: shank_left_face = washer_outer_face - connect_overlap_mm
  // => shank_center_x = washer_outer_face - connect_overlap_mm + screw_length_mm/2
  shank_center_x = (washer_center_x + washer_thickness_mm/2) - connect_overlap_mm + screw_length_mm/2;

  // Place screw head so it overlaps the washer by connect_overlap_mm (guaranteed fusion)
  // Head spans along X by screw_head_height_mm (centered), so its right face is at:
  //   x = head_center_x + screw_head_height_mm/2
  // Want: head_right_face = washer_inner_face + connect_overlap_mm
  // washer_inner_face = washer_center_x - washer_thickness_mm/2
  // => head_center_x = washer_inner_face + connect_overlap_mm - screw_head_height_mm/2
  head_center_x = (washer_center_x - washer_thickness_mm/2) + connect_overlap_mm - screw_head_height_mm/2;

  color([0.4, 0.4, 0.43]) {
    union() {
      // Washer
      difference() {
        translate([washer_center_x, 0, 0])
          rotate([0, 90, 0])
          cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);

        translate([washer_center_x, 0, 0])
          rotate([0, 90, 0])
          cylinder(h=washer_thickness_mm + 2*connect_overlap_mm, r=screw_shank_diameter_mm/2, center=true);
      }

      // Screw shank (overlaps washer by connect_overlap_mm)
      translate([shank_center_x, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true);

      // Screw head (overlaps washer by connect_overlap_mm)
      translate([head_center_x, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=screw_head_height_mm, r=screw_head_diameter_mm/2, center=true);
    }
  }
}

// Assembly - single connected solid via union()
module assembly() {
  union() {
    linear_bearing();
    screw_and_washer();
  }
}

assembly();