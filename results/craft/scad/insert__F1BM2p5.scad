// Parameters
screw_nominal_diameter_mm = 2.5; //[1.25:5:0.05]
internal_thread_pitch_mm = 0.45; //[0.2:1:0.01]
outer_diameter_mm = 5.8; //[2.9:11.6:0.1]
length_mm = 4.6; //[2.3:9.2:0.1]
lead_in_chamfer_mm = 0.3; //[0.1:1:0.05]
internal_thread_minor_diameter_mm = 2.1; //[1.2:3:0.05]
internal_hole_clearance_mm = 0.1; //[0:0.3:0.01]
ridge_count = 10; //[6:24:1]
ridge_depth_mm = 0.35; //[0.15:0.8:0.05]
ridge_width_mm = 0.6; //[0.3:1.2:0.05]
ridge_overlap_mm = 0.8; //[0.5:2:0.1]
ridge_end_margin_mm = 0.4; //[0.2:1.2:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Module for the heat-set insert body
module heat_set_insert_body() {
  color("Gold") {
    cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
  }
}

// Module for the internal thread representation
module internal_thread_for_M2_5() {
  color("Silver") {
    cylinder(r=internal_thread_minor_diameter_mm/2 + internal_hole_clearance_mm, 
             h=length_mm + 2*eps_mm, center=true, $fn=64);
  }
}

// Module for the lead-in chamfer
module lead_in_chamfer() {
  color("Gold") {
    translate([0, 0, -length_mm/2 + lead_in_chamfer_mm/2])
      cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - lead_in_chamfer_mm, 
               h=lead_in_chamfer_mm, center=true, $fn=64);
  }
}

// Module for a single ridge
module outer_ridge_proto() {
  translate([outer_diameter_mm/2 + (ridge_depth_mm + ridge_overlap_mm)/2 - ridge_overlap_mm, 0, 0])
    cube([ridge_depth_mm + ridge_overlap_mm, ridge_width_mm, length_mm - 2*ridge_end_margin_mm], center=true);
}

// Module for all ridges
module outer_knurl_or_ridges_for_heat_set_retention() {
  for (i = [0:ridge_count-1]) {
    rotate([0, 0, i*360/ridge_count]) outer_ridge_proto();
  }
}

// Module for the complete insert
module insert() {
  union() {
    heat_set_insert_body();
    outer_knurl_or_ridges_for_heat_set_retention();
    lead_in_chamfer();
  }
}

// Module for the threaded insert
module threaded_insert() {
  difference() {
    insert();
    internal_thread_for_M2_5();
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();