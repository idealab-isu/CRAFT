// Parameters
screw_nominal_diameter_mm = 2.5; //[1.25:5:0.05]
outer_diameter_mm = 4; //[2:8:0.05]
length_mm = 4.6; //[2.3:9.2:0.05]
internal_thread_pitch_mm = 0.45; //[0.2:0.9:0.01]
internal_minor_diameter_mm = 2.05; //[1.2:3.2:0.01]
internal_major_diameter_mm = 2.5; //[1.5:4:0.01]
outer_feature_depth_mm = 0.25; //[0.1:0.6:0.01]
outer_feature_pitch_mm = 0.6; //[0.3:1.2:0.01]
entry_chamfer_mm = 0.3; //[0.1:0.8:0.01]
tip_chamfer_mm = 0.2; //[0.1:0.8:0.01]
model_tolerance_mm = 0.05; //[0.01:0.2:0.01]
outer_radius_mm = 2; //[1:4:0.01]
bore_radius_mm = 1.025; //[0.6:1.6:0.005]
rib_radial_thickness_mm = 0.25; //[0.1:0.6:0.01]
rib_axial_height_mm = 0.35; //[0.2:0.8:0.01]
rib_count = 6; //[3:12:1]
rib_span_length_mm = 3.6; //[1.8:7.2:0.05]
rib_spacing_mm = 0.72; //[0.3:1.5:0.01]

// Heat-set insert body
module heat_set_insert_body() {
  color("Gold") {
    cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
  }
}

// Internal thread bore
module internal_thread_for_M2_5() {
  color("Silver") {
    cylinder(r=internal_minor_diameter_mm/2, h=length_mm + 2*model_tolerance_mm, center=true, $fn=64);
  }
}

// Chamfers
module installation_entry_chamfer() {
  color("Gold") {
    translate([0, 0, length_mm/2 - entry_chamfer_mm/2])
      cylinder(r1=outer_diameter_mm/2, r2=0, h=entry_chamfer_mm, center=true, $fn=64);
  }
}

module lead_in_chamfer() {
  color("Gold") {
    translate([0, 0, -length_mm/2 + tip_chamfer_mm/2])
      cylinder(r1=outer_diameter_mm/2, r2=0, h=tip_chamfer_mm, center=true, $fn=64);
  }
}

// Outer ribs
module outer_rib(position) {
  color("Gold") {
    translate([0, 0, position])
      cylinder(r=outer_diameter_mm/2 + outer_feature_depth_mm, h=rib_axial_height_mm, center=true, $fn=64);
  }
}

module outer_knurl_or_ribs_for_heat_set_retention() {
  for (i = [0:rib_count-1]) {
    outer_rib(-length_mm/2 + tip_chamfer_mm + model_tolerance_mm + i*rib_spacing_mm);
  }
}

// Complete insert
module insert() {
  difference() {
    union() {
      heat_set_insert_body();
      outer_knurl_or_ribs_for_heat_set_retention();
    }
    installation_entry_chamfer();
    lead_in_chamfer();
  }
}

// Threaded insert with internal bore
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