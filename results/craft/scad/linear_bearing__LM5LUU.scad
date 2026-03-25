// Parameters
bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
outer_diameter_mm = 10.0; //[5.0:20.0:0.1]
length_mm = 28.0; //[14.0:56.0:0.5]
bore_radius_mm = 2.5; //[1.25:5.0:0.05]
outer_radius_mm = 5.0; //[2.5:10.0:0.05]
casing_wall_thickness_mm = 1.0; //[0.5:2.0:0.1]
seal_thickness_mm = 1.5; //[0.8:3.0:0.1]
seal_outer_radius_mm = 4.0; //[3.0:5.0:0.1]
seal_inner_clearance_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
bore_extra_length_mm = 2.0; //[1.0:6.0:0.5]
screw_shank_radius_mm = 1.5; //[1.0:2.5:0.1]
screw_length_mm = 12.0; //[6.0:24.0:0.5]
screw_head_radius_mm = 3.0; //[2.0:5.0:0.1]
screw_head_height_mm = 2.5; //[1.5:5.0:0.1]
washer_radius_mm = 3.5; //[2.5:6.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.0:0.1]
washer_hole_radius_mm = 1.7; //[1.1:3.0:0.1]
screw_mount_pad_thickness_mm = 2.0; //[1.0:4.0:0.1]
screw_mount_pad_width_mm = 6.0; //[3.0:12.0:0.5]
screw_mount_pad_height_mm = 6.0; //[3.0:12.0:0.5]

// LM5LUU Linear Bearing (single connected solid)
module linear_bearing() {
  color([0.85, 0.85, 0.8])
  difference() {
    // UNION all exterior bearing features first, then cut the bore once
    union() {
      // Outer casing
      cylinder(r=outer_radius_mm, h=length_mm, center=true);

      // End seals (slightly overlapping into the casing)
      difference() {
        translate([0, 0, -length_mm/2 + seal_thickness_mm/2 + overlap_mm/2])
          cylinder(r=seal_outer_radius_mm, h=seal_thickness_mm + overlap_mm, center=true);
        translate([0, 0, -length_mm/2 + seal_thickness_mm/2 + overlap_mm/2])
          cylinder(r=bore_radius_mm + seal_inner_clearance_mm, h=seal_thickness_mm + 2*overlap_mm, center=true);
      }

      difference() {
        translate([0, 0,  length_mm/2 - seal_thickness_mm/2 - overlap_mm/2])
          cylinder(r=seal_outer_radius_mm, h=seal_thickness_mm + overlap_mm, center=true);
        translate([0, 0,  length_mm/2 - seal_thickness_mm/2 - overlap_mm/2])
          cylinder(r=bore_radius_mm + seal_inner_clearance_mm, h=seal_thickness_mm + 2*overlap_mm, center=true);
      }
    }

    // Bore through hole (cuts casing + seals)
    cylinder(r=bore_radius_mm, h=length_mm + bore_extra_length_mm, center=true);
  }
}

// Screw and Washer (kept as solid parts; washer hole is cut)
module screw_and_washer() {
  color("DimGray")
  union() {
    // Screw shank (axis along Y)
    rotate([90, 0, 0])
      cylinder(r=screw_shank_radius_mm, h=screw_length_mm, center=true);

    // Screw head (cylindrical head)
    translate([0, screw_length_mm/2 - screw_head_height_mm/2, 0])
      rotate([90, 0, 0])
      cylinder(r=screw_head_radius_mm, h=screw_head_height_mm, center=true);

    // Washer (with hole)
    difference() {
      translate([0, -screw_length_mm/2 + washer_thickness_mm/2, 0])
        rotate([90, 0, 0])
        cylinder(r=washer_radius_mm, h=washer_thickness_mm, center=true);

      translate([0, -screw_length_mm/2 + washer_thickness_mm/2, 0])
        rotate([90, 0, 0])
        cylinder(r=washer_hole_radius_mm, h=washer_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly (ALL parts physically connected + single union)
module assembly() {
  // Ensure the pad intersects the bearing OD by overlap_mm.
  // Bearing extends in Y: [-outer_radius_mm, +outer_radius_mm]
  // Pad extends in Y: [pad_center_y - t/2, pad_center_y + t/2]
  // Set pad inner face at (outer_radius_mm - overlap_mm)
  pad_center_y = (outer_radius_mm - overlap_mm) + screw_mount_pad_thickness_mm/2;

  // Ensure the washer outer face intersects the pad outer face by overlap_mm.
  // Washer outer face (most negative Y of washer) is at: screw_center_y - screw_length_mm/2
  // Pad outer face is at: pad_center_y + t/2
  // Make washer outer face slightly inside pad: washer_outer_face = pad_outer_face - overlap_mm
  screw_center_y = (pad_center_y + screw_mount_pad_thickness_mm/2 - overlap_mm) + screw_length_mm/2;

  // Add a small "boss" that bridges pad -> bearing to guarantee a robust connection
  // even if parameters change (still overlaps both by overlap_mm).
  boss_y = outer_radius_mm - overlap_mm/2; // centered so it intersects bearing and pad
  boss_thickness_y = overlap_mm * 2;       // spans across the interface
  boss_w = screw_mount_pad_width_mm;
  boss_h = screw_mount_pad_height_mm;

  union() {
    // REQUIRED PART: linear bearing (present)
    linear_bearing();

    // Mount pad (connected to bearing)
    translate([0, pad_center_y, 0])
      color("Silver")
      cube([screw_mount_pad_width_mm, screw_mount_pad_thickness_mm, screw_mount_pad_height_mm], center=true);

    // Bridge/boss to guarantee physical attachment between bearing and pad
    translate([0, boss_y, 0])
      color("Silver")
      cube([boss_w, boss_thickness_y, boss_h], center=true);

    // Bolt/shaft + head + washer (connected to pad with overlap)
    translate([0, screw_center_y, 0])
      screw_and_washer();
  }
}

assembly();