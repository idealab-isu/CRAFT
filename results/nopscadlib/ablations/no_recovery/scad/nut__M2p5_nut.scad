// Parameters
thread_nominal_diameter_mm = 2.5; //[1.25:5:0.01]
thread_pitch_mm = 0.45; //[0.2:0.9:0.01]
across_flats_mm = 5.8; //[2.9:11.6:0.01]
thickness_mm = 2.2; //[1.1:4.4:0.01]
hole_minor_diameter_mm = 2.05; //[1.2:3.2:0.01]
tolerance_mm = 0.1; //[0:0.3:0.01]
top_chamfer_mm = 0.2; //[0:0.6:0.01]
bottom_chamfer_mm = 0.2; //[0:0.6:0.01]
chamfer_radial_mm = 0.25; //[0.05:0.8:0.01]
edge_overlap_mm = 0.8; //[0.5:2:0.01]
washer_outer_diameter_mm = 6.5; //[4:13:0.01]
washer_thickness_mm = 0.6; //[0.3:1.2:0.01]
washer_hole_diameter_mm = 2.7; //[2.2:3.5:0.01]

// Hex Nut - complete geometry
module hex_nut() {
  color("DimGray") {
    difference() {
      // Hexagonal body
      cylinder(h=thickness_mm, r=across_flats_mm/(2*cos(30)), center=true, $fn=6);
      // Central thread hole
      translate([0, 0, 0])
        cylinder(h=thickness_mm + 2*edge_overlap_mm, r=(hole_minor_diameter_mm + tolerance_mm)/2, center=true);
      // Top edge break
      translate([0, 0, thickness_mm/2 - top_chamfer_mm/2 + edge_overlap_mm/2])
        difference() {
          cylinder(h=top_chamfer_mm, r=across_flats_mm/(2*cos(30)) + edge_overlap_mm, center=true);
          cylinder(h=top_chamfer_mm + 2*edge_overlap_mm, r=across_flats_mm/(2*cos(30)) - chamfer_radial_mm, center=true);
        }
      // Bottom edge break
      translate([0, 0, -thickness_mm/2 + bottom_chamfer_mm/2 - edge_overlap_mm/2])
        difference() {
          cylinder(h=bottom_chamfer_mm, r=across_flats_mm/(2*cos(30)) + edge_overlap_mm, center=true);
          cylinder(h=bottom_chamfer_mm + 2*edge_overlap_mm, r=across_flats_mm/(2*cos(30)) - chamfer_radial_mm, center=true);
        }
    }
  }
}

// Washer - complete geometry
module washer() {
  color("Silver") {
    difference() {
      // Outer washer
      translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - edge_overlap_mm)])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      // Washer hole
      translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - edge_overlap_mm)])
        cylinder(h=washer_thickness_mm + 2*edge_overlap_mm, r=washer_hole_diameter_mm/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  hex_nut();
  washer();
}

assembly();