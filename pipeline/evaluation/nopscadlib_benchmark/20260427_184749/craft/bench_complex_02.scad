// Parameters
primary_dimension = 5; //[2.5:10:0.1]
outer_diameter = 19; //[9.5:38:0.1]
overall_length = 25; //[12.5:50:0.1]
motor_bore_diameter = 5.1; //[2.55:10.2:0.01]
leadscrew_bore_diameter = 8.1; //[4.05:16.2:0.01]
motor_bore_depth = 12; //[6:24:0.1]
leadscrew_bore_depth = 12; //[6:24:0.1]
center_gap = 1; //[0.5:2:0.1]
flexure_length = 10; //[5:20:0.1]
flexure_slot_count = 6; //[3:12:1]
flexure_slot_width = 1.2; //[0.6:2.4:0.05]
flexure_slot_depth = 6.5; //[3.25:13:0.1]
clamp_slit_width = 1.2; //[0.6:2.4:0.05]
clamp_slit_length = 10; //[5:20:0.1]
clamp_screw_hole_diameter = 3.2; //[1.6:6.4:0.05]
clamp_screw_head_clearance_diameter = 6.2; //[3.1:12.4:0.05]
clamp_screw_head_clearance_depth = 3; //[1.5:6:0.05]
chamfer_size = 0.5; //[0.25:1:0.05]
overlap = 0.8; //[0.5:2:0.1]

// Base Shapes
module coupler_body() {
  cylinder(r=outer_diameter/2, h=overall_length, center=true);
}

module motor_shaft_bore_5mm() {
  translate([0, 0, -overall_length/2 + (motor_bore_depth + overlap)/2])
    cylinder(r=motor_bore_diameter/2, h=motor_bore_depth + overlap, center=true);
}

module leadscrew_bore_8mm() {
  translate([0, 0, overall_length/2 - (leadscrew_bore_depth + overlap)/2])
    cylinder(r=leadscrew_bore_diameter/2, h=leadscrew_bore_depth + overlap, center=true);
}

module center_stop_or_gap() {
  cylinder(r=leadscrew_bore_diameter/2, h=center_gap, center=true);
}

module motor_bore_lead_in_chamfer() {
  translate([0, 0, -overall_length/2 + chamfer_size/2])
    rotate([180, 0, 0])
    cylinder(r1=motor_bore_diameter/2 + chamfer_size, r2=motor_bore_diameter/2, h=chamfer_size, center=true);
}

module leadscrew_bore_lead_in_chamfer() {
  translate([0, 0, overall_length/2 - chamfer_size/2])
    cylinder(r1=leadscrew_bore_diameter/2 + chamfer_size, r2=leadscrew_bore_diameter/2, h=chamfer_size, center=true);
}

module shaft_clamp_slits() {
  translate([0, 0, -overall_length/2 + (clamp_slit_length + overlap)/2])
    cube([outer_diameter + overlap, clamp_slit_width, clamp_slit_length + overlap], center=true);
}

module shaft_clamp_slits_2() {
  translate([0, 0, overall_length/2 - (clamp_slit_length + overlap)/2])
    cube([outer_diameter + overlap, clamp_slit_width, clamp_slit_length + overlap], center=true);
}

module clamping_screw_holes_motor() {
  translate([0, 0, -overall_length/2 + clamp_slit_length/2])
    rotate([90, 0, 0])
    cylinder(r=clamp_screw_hole_diameter/2, h=outer_diameter + overlap, center=true);
}

module clamping_screw_holes_leadscrew() {
  translate([0, 0, overall_length/2 - clamp_slit_length/2])
    rotate([90, 0, 0])
    cylinder(r=clamp_screw_hole_diameter/2, h=outer_diameter + overlap, center=true);
}

module clamping_screw_head_clearance_motor() {
  translate([0, outer_diameter/2 - (clamp_screw_head_clearance_depth + overlap)/2, -overall_length/2 + clamp_slit_length/2])
    rotate([90, 0, 0])
    cylinder(r=clamp_screw_head_clearance_diameter/2, h=clamp_screw_head_clearance_depth + overlap, center=true);
}

module clamping_screw_head_clearance_leadscrew() {
  translate([0, outer_diameter/2 - (clamp_screw_head_clearance_depth + overlap)/2, overall_length/2 - clamp_slit_length/2])
    rotate([90, 0, 0])
    cylinder(r=clamp_screw_head_clearance_diameter/2, h=clamp_screw_head_clearance_depth + overlap, center=true);
}

module flexure_slot_seed() {
  translate([outer_diameter/2 - (flexure_slot_depth + overlap)/2, 0, 0])
    cube([flexure_slot_depth + overlap, flexure_slot_width, flexure_length + overlap], center=true);
}

// Operations
module bore_lead_in_chamfers() {
  union() {
    motor_bore_lead_in_chamfer();
    leadscrew_bore_lead_in_chamfer();
  }
}

module clamping_screw_holes() {
  union() {
    clamping_screw_holes_motor();
    clamping_screw_holes_leadscrew();
    clamping_screw_head_clearance_motor();
    clamping_screw_head_clearance_leadscrew();
  }
}

module flexure_section() {
  for (i = [0:flexure_slot_count-1]) {
    rotate([0, 0, i * 360/flexure_slot_count])
      flexure_slot_seed();
  }
}

module flex() {
  union() {
    flexure_section();
  }
}

module coupler_body_with_bores() {
  difference() {
    coupler_body();
    motor_shaft_bore_5mm();
    leadscrew_bore_8mm();
    center_stop_or_gap();
    bore_lead_in_chamfers();
  }
}

module coupler_body_with_clamps() {
  difference() {
    coupler_body_with_bores();
    shaft_clamp_slits();
    shaft_clamp_slits_2();
    clamping_screw_holes();
  }
}

module shaft_coupling() {
  difference() {
    coupler_body_with_clamps();
    flex();
  }
}

// Final Output
shaft_coupling();