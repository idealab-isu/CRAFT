// Parameters
thread_nominal_diameter_mm = 6; //[3:12:0.1]
thread_pitch_mm = 1; //[0.5:2:0.1]
across_flats_mm = 10; //[6:20:0.1]
thickness_mm = 3.2; //[1.6:6.4:0.1]
tolerance_mm = 0.2; //[0.05:0.5:0.05]
chamfer_mm = 0.3; //[0.1:1:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
washer_outer_diameter_mm = 12; //[8:24:0.1]
washer_thickness_mm = 1; //[0.5:2.5:0.1]

// Hex Nut Body
module hex_nut_body() {
  color("DimGray") {
    cylinder(h=thickness_mm, r=(across_flats_mm/2)/cos(30), center=true, $fn=6);
  }
}

// Central Thread Hole
module central_thread_hole() {
  cylinder(h=thickness_mm + 2*overlap_mm, r=(thread_nominal_diameter_mm + tolerance_mm)/2, center=true);
}

// Edge Chamfer
module edge_chamfer_top() {
  translate([0, 0, (thickness_mm/2) - (chamfer_mm/2)])
    rotate([180, 0, 0])
    cylinder(h=chamfer_mm, r1=(thread_nominal_diameter_mm + tolerance_mm)/2 + chamfer_mm, r2=0, center=true);
}

module edge_chamfer_bottom() {
  translate([0, 0, (-thickness_mm/2) + (chamfer_mm/2)])
    cylinder(h=chamfer_mm, r1=(thread_nominal_diameter_mm + tolerance_mm)/2 + chamfer_mm, r2=0, center=true);
}

// Washer Outer
module washer_outer() {
  color("Silver") {
    translate([0, 0, (-thickness_mm/2) - (washer_thickness_mm/2) + overlap_mm])
      cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
  }
}

// Washer Inner Hole
module washer_inner_hole() {
  translate([0, 0, (-thickness_mm/2) - (washer_thickness_mm/2) + overlap_mm])
    cylinder(h=washer_thickness_mm + 2*overlap_mm, r=(thread_nominal_diameter_mm + tolerance_mm)/2, center=true);
}

// Washer Ring
module washer_ring() {
  difference() {
    washer_outer();
    washer_inner_hole();
  }
}

// Nut and Washer
module nut_and_washer() {
  union() {
    hex_nut_body();
    washer_ring();
  }
}

// Nut Hole and Lead-in
module nut_hole_and_lead_in() {
  union() {
    central_thread_hole();
    edge_chamfer_top();
    edge_chamfer_bottom();
  }
}

// Final Nut
module final_nut() {
  difference() {
    nut_and_washer();
    nut_hole_and_lead_in();
  }
}

// Assembly
module assembly() {
  final_nut();
}

assembly();