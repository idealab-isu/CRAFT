// Parameters
outer_diameter_mm = 12; //[6:24:0.1]
length_mm = 10; //[5:20:0.1]
screw_diameter_mm = 5; //[2.5:10:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
tolerance_mm = 0.1; //[0.05:0.3:0.01]
inner_thread_minor_diameter_mm = 4.2; //[3.5:5:0.05]
lead_in_chamfer_mm = 0.5; //[0.2:2:0.1]
outer_feature_style = 1; //[0:2:1]
knurl_count = 24; //[12:48:1]
knurl_rib_depth_mm = 0.6; //[0.3:1.2:0.05]
knurl_rib_width_mm = 1.2; //[0.6:2.4:0.05]
knurl_rib_length_mm = 9; //[4.5:18:0.1]
rib_overlap_mm = 0.8; //[0.5:2:0.1]
bore_extra_height_mm = 2; //[1:6:0.5]

// Heat-set insert body
module heat_set_insert_body() {
  color("Gold") {
    cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
  }
}

// Internal thread bore
module internal_thread_bore_M5() {
  cylinder(r=(inner_thread_minor_diameter_mm + tolerance_mm)/2, h=length_mm + bore_extra_height_mm, center=true, $fn=64);
}

// Lead-in chamfer
module lead_in_chamfer() {
  translate([0, 0, length_mm/2 - lead_in_chamfer_mm/2])
    cylinder(r1=(inner_thread_minor_diameter_mm + tolerance_mm)/2 + lead_in_chamfer_mm, r2=(inner_thread_minor_diameter_mm + tolerance_mm)/2, h=lead_in_chamfer_mm, center=true, $fn=64);
}

// Knurl rib prototype
module outer_knurl_rib_proto() {
  translate([outer_diameter_mm/2 + (knurl_rib_depth_mm + rib_overlap_mm)/2 - rib_overlap_mm, 0, 0])
    cube([knurl_rib_depth_mm + rib_overlap_mm, knurl_rib_width_mm, knurl_rib_length_mm], center=true);
}

// Knurl ribs
module outer_knurl_or_ribs() {
  for (i = [0:knurl_count-1]) {
    rotate([0, 0, i*360/knurl_count])
      outer_knurl_rib_proto();
  }
}

// Complete insert with knurls
module insert() {
  union() {
    heat_set_insert_body();
    outer_knurl_or_ribs();
  }
}

// Threaded insert with bore and chamfer
module threaded_insert() {
  difference() {
    insert();
    internal_thread_bore_M5();
    lead_in_chamfer();
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();