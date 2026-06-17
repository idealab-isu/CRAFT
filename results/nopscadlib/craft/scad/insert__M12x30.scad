// Parameters
outer_diameter_mm = 30; //[15:60:0.5]
length_mm = 22; //[11:44:0.5]
screw_nominal_diameter_mm = 12; //[6:24:0.5]
internal_thread_pitch_mm = 1.75; //[0.75:3.5:0.05]
bore_minor_diameter_mm = 10.2; //[5.1:20.4:0.1]
thread_depth_mm = 22; //[11:44:0.5]
top_chamfer_mm = 1; //[0.5:2:0.1]
bottom_chamfer_mm = 1; //[0.5:2:0.1]
outer_edge_chamfer_mm = 0.5; //[0.25:1.5:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
bore_clearance_mm = 0.2; //[0:0.6:0.05]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Silver") {
    // Insert Body
    difference() {
      union() {
        // Main Body
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
        // Installation End Face
        translate([0, 0, -length_mm/2 + overlap_mm/2])
          cylinder(r=outer_diameter_mm/2, h=overlap_mm, center=true);
        // Outer Edge Chamfers
        translate([0, 0, length_mm/2 - (outer_edge_chamfer_mm + overlap_mm)/2])
          cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - outer_edge_chamfer_mm, h=outer_edge_chamfer_mm + overlap_mm, center=true);
        translate([0, 0, -length_mm/2 + (outer_edge_chamfer_mm + overlap_mm)/2])
          cylinder(r1=outer_diameter_mm/2 - outer_edge_chamfer_mm, r2=outer_diameter_mm/2, h=outer_edge_chamfer_mm + overlap_mm, center=true);
      }
      // Internal Threaded Bore
      cylinder(r=(bore_minor_diameter_mm + bore_clearance_mm)/2, h=thread_depth_mm + 2*overlap_mm, center=true);
      // Lead-in Chamfers
      translate([0, 0, length_mm/2 - (top_chamfer_mm + overlap_mm)/2])
        cylinder(r1=outer_diameter_mm/2, r2=(bore_minor_diameter_mm + bore_clearance_mm)/2, h=top_chamfer_mm + overlap_mm, center=true);
      translate([0, 0, -length_mm/2 + (bottom_chamfer_mm + overlap_mm)/2])
        cylinder(r1=(bore_minor_diameter_mm + bore_clearance_mm)/2, r2=outer_diameter_mm/2, h=bottom_chamfer_mm + overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();