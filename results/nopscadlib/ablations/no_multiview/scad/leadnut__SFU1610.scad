// Parameters
width_mm = 16; //[8:32:0.1]
height_mm = 28; //[14:56:0.1]
length_mm = 42.5; //[21.25:85:0.1]
tolerances_mm = 0.3; //[0.1:0.8:0.05]
leadscrew_diameter_mm = 8; //[4:16:0.1]
nut_pocket_diameter_mm = 14; //[8:24:0.1]
nut_pocket_depth_mm = 30; //[10:42.5:0.1]
nut_retention_diameter_mm = 18; //[10:30:0.1]
nut_retention_depth_mm = 3; //[1:8:0.1]
mount_hole_diameter_mm = 3.5; //[2:6:0.1]
mount_hole_edge_margin_mm = 3; //[1.5:8:0.1]
mount_hole_z_offset_mm = 0; //[-10:10:0.1]
chamfer_mm = 1; //[0.5:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
leadscrew_length_extra_mm = 20; //[5:60:0.5]

// Added: physical "leadscrew/nut" solid that is fused to the housing
// (slightly larger than the clearance bore so it intersects the housing by ~1mm radially)
nut_solid_diameter_mm = nut_pocket_diameter_mm - 2*tolerances_mm + 2*overlap_mm; // ensures overlap with housing
nut_solid_length_mm   = length_mm + 2*overlap_mm; // spans through housing with slight extra

// Main housing with voids
module housing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Main body
      cube([width_mm, height_mm, length_mm], center=true);

      // Nut cavity or bore (through Y)
      rotate([90, 0, 0])
        cylinder(r=(nut_pocket_diameter_mm/2) + tolerances_mm,
                 h=nut_pocket_depth_mm + 2*overlap_mm,
                 center=true, $fn=64);

      // Nut retention features (near +Z end, through Y)
      translate([0, 0, (length_mm/2) - (nut_retention_depth_mm/2) + overlap_mm])
        rotate([90, 0, 0])
        cylinder(r=(nut_retention_diameter_mm/2) + tolerances_mm,
                 h=nut_retention_depth_mm + 2*overlap_mm,
                 center=true, $fn=64);

      // Mounting holes (through Z)
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * ((width_mm/2) - mount_hole_edge_margin_mm),
                   y * ((height_mm/2) - mount_hole_edge_margin_mm),
                   mount_hole_z_offset_mm])
          cylinder(r=(mount_hole_diameter_mm/2) + tolerances_mm,
                   h=length_mm + 2*overlap_mm,
                   center=true, $fn=48);
      }

      // Lead-in chamfers (through Y)
      translate([0, 0, -(length_mm/2) + (chamfer_mm/2)])
        rotate([90, 0, 0])
        cylinder(r1=(nut_pocket_diameter_mm/2) + tolerances_mm + chamfer_mm,
                 r2=0,
                 h=chamfer_mm + overlap_mm,
                 center=true, $fn=64);

      translate([0, 0, (length_mm/2) - (chamfer_mm/2)])
        rotate([-90, 0, 0])
        cylinder(r1=(nut_pocket_diameter_mm/2) + tolerances_mm + chamfer_mm,
                 r2=0,
                 h=chamfer_mm + overlap_mm,
                 center=true, $fn=64);
    }
  }
}

// Central cylindrical leadnut/shaft-like piece (now a real, fused part)
module central_nut_solid() {
  // Oriented along Y to match the bore direction in housing()
  color("Silver")
    rotate([90, 0, 0])
      cylinder(d=nut_solid_diameter_mm,
               h=nut_solid_length_mm,
               center=true, $fn=96);
}

// Assembly: single connected solid via union(), with guaranteed overlap
module assembly() {
  union() {
    housing();
    central_nut_solid(); // intersects housing (not just passing through a clearance hole)
  }
}

assembly();