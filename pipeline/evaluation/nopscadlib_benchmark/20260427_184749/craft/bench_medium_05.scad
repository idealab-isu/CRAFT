// Parameters
pcb_length = 45.0; //[22.5:90.0:0.1]
pcb_width = 18.0; //[9.0:36.0:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
case_wall_thickness = 2.0; //[1.0:4.0:0.1]
base_thickness = 2.0; //[1.0:4.0:0.1]
internal_clearance_xy = 0.3; //[0.1:1.0:0.05]
internal_clearance_z = 0.4; //[0.1:1.5:0.05]
clip_thickness = 1.2; //[0.6:2.4:0.1]
clip_overhang = 0.8; //[0.4:1.6:0.1]
clip_gap = 0.4; //[0.2:1.0:0.05]
clip_lead_in_chamfer = 0.8; //[0.4:2.0:0.1]
standoff_height = 1.2; //[0.6:2.4:0.1]
standoff_diameter = 4.0; //[2.0:8.0:0.1]
usb_cutout_width = 9.0; //[4.5:18.0:0.1]
usb_cutout_height = 4.0; //[2.0:8.0:0.1]
usb_cutout_depth = 6.0; //[3.0:12.0:0.1]
usb_cutout_clearance = 0.5; //[0.2:1.5:0.05]
overlap = 1.0; //[0.5:2.0:0.1]
case_inner_length = 45.6; //[23.0:91.0:0.1]
case_inner_width = 18.6; //[9.5:37.0:0.1]
case_inner_height = 5.2; //[3.0:12.0:0.1]
case_outer_length = 49.6; //[25.0:99.0:0.1]
case_outer_width = 22.6; //[11.0:45.0:0.1]
case_outer_height = 7.2; //[4.0:16.0:0.1]

// Main Body Outer
module main_body_outer() {
  translate([0, 0, case_outer_height/2])
    cube([case_outer_length, case_outer_width, case_outer_height], center=true);
}

// PCB Bay Void
module pcb_bay_void() {
  translate([0, 0, base_thickness + case_inner_height/2])
    cube([case_inner_length, case_inner_width, case_inner_height + overlap], center=true);
}

// USB Port Cutout Void
module usb_port_cutout_void() {
  translate([case_outer_length/2 - (usb_cutout_depth + overlap)/2, 0, base_thickness + standoff_height + pcb_thickness/2 + (usb_cutout_height + 2*usb_cutout_clearance)/2])
    cube([usb_cutout_depth + overlap, usb_cutout_width + 2*usb_cutout_clearance, usb_cutout_height + 2*usb_cutout_clearance], center=true);
}

// Cable Clearance Chamfer Void
module cable_clearance_chamfer_void() {
  translate([case_outer_length/2 - (usb_cutout_depth + overlap)/2, 0, base_thickness + standoff_height + pcb_thickness/2 + (usb_cutout_height + 2*usb_cutout_clearance)/2])
    rotate([0, 45, 0])
    cube([usb_cutout_depth + overlap, usb_cutout_width + 2*usb_cutout_clearance, usb_cutout_height + 2*usb_cutout_clearance], center=true);
}

// Standoff Cylinder
module standoff_cyl() {
  translate([0, 0, base_thickness + standoff_height/2 - overlap/2])
    cylinder(h=standoff_height, r=standoff_diameter/2, center=true);
}

// End Stop Block
module end_stop_block() {
  translate([-case_inner_length/2 + case_wall_thickness/2 - overlap/2, 0, base_thickness + (standoff_height + pcb_thickness + internal_clearance_z)/2])
    cube([case_wall_thickness, case_inner_width, standoff_height + pcb_thickness + internal_clearance_z], center=true);
}

// Clip Arm
module clip_arm() {
  translate([0, 0, base_thickness + (case_inner_height - clip_lead_in_chamfer)/2])
    cube([clip_thickness, case_inner_length/5, case_inner_height - clip_lead_in_chamfer], center=true);
}

// Clip Lip
module clip_lip() {
  translate([0, 0, base_thickness + standoff_height + pcb_thickness + internal_clearance_z - clip_thickness/2])
    cube([clip_overhang, case_inner_length/5, clip_thickness], center=true);
}

// USB Reference B
module usb_ref_B() {
  translate([case_outer_length/2 - usb_cutout_depth/2, 0, base_thickness + standoff_height + pcb_thickness/2 + usb_cutout_height/2])
    cube([usb_cutout_depth, usb_cutout_width, usb_cutout_height], center=true);
}

// USB Reference uA
module usb_ref_uA() {
  translate([case_outer_length/2 - (usb_cutout_depth*0.8)/2, 0, base_thickness + standoff_height + pcb_thickness/2 + (usb_cutout_height*0.7)/2])
    cube([usb_cutout_depth*0.8, usb_cutout_width*0.8, usb_cutout_height*0.7], center=true);
}

// USB Reference Ax2
module usb_ref_Ax2() {
  translate([case_outer_length/2 - (usb_cutout_depth*1.2)/2, 0, base_thickness + standoff_height + pcb_thickness/2 + (usb_cutout_height*1.6)/2])
    cube([usb_cutout_depth*1.2, usb_cutout_width*1.4, usb_cutout_height*1.6], center=true);
}

// USB Reference C
module usb_ref_C() {
  translate([case_outer_length/2 - (usb_cutout_depth*0.9)/2, 0, base_thickness + standoff_height + pcb_thickness/2 + (usb_cutout_height*0.8)/2])
    cube([usb_cutout_depth*0.9, usb_cutout_width*0.9, usb_cutout_height*0.8], center=true);
}

// USB Reference Ax1
module usb_ref_Ax1() {
  translate([case_outer_length/2 - (usb_cutout_depth*1.1)/2, 0, base_thickness + standoff_height + pcb_thickness/2 + (usb_cutout_height*1.3)/2])
    cube([usb_cutout_depth*1.1, usb_cutout_width*1.2, usb_cutout_height*1.3], center=true);
}

// Operations
module op_pcb_bay() {
  difference() {
    main_body_outer();
    pcb_bay_void();
  }
}

module op_usb_port_cutout() {
  difference() {
    op_pcb_bay();
    usb_port_cutout_void();
  }
}

module op_cable_clearance_chamfer() {
  difference() {
    op_usb_port_cutout();
    cable_clearance_chamfer_void();
  }
}

module op_standoff_1_pos() {
  translate([-case_inner_length/2 + standoff_diameter/2 + internal_clearance_xy, -case_inner_width/2 + standoff_diameter/2 + internal_clearance_xy, 0])
    standoff_cyl();
}

module op_standoff_2_pos() {
  translate([-case_inner_length/2 + standoff_diameter/2 + internal_clearance_xy, case_inner_width/2 - standoff_diameter/2 - internal_clearance_xy, 0])
    standoff_cyl();
}

module op_standoff_3_pos() {
  translate([case_inner_length/2 - standoff_diameter/2 - internal_clearance_xy - usb_cutout_depth/2, -case_inner_width/2 + standoff_diameter/2 + internal_clearance_xy, 0])
    standoff_cyl();
}

module op_standoff_4_pos() {
  translate([case_inner_length/2 - standoff_diameter/2 - internal_clearance_xy - usb_cutout_depth/2, case_inner_width/2 - standoff_diameter/2 - internal_clearance_xy, 0])
    standoff_cyl();
}

module op_board_standoffs() {
  union() {
    op_standoff_1_pos();
    op_standoff_2_pos();
    op_standoff_3_pos();
    op_standoff_4_pos();
  }
}

module op_end_stops() {
  union() {
    end_stop_block();
    end_stop_block();
  }
}

module op_clip_arm_left_1() {
  translate([-case_inner_width/2 - clip_thickness/2 + overlap, -case_inner_length/4, 0])
    clip_arm();
}

module op_clip_lip_left_1() {
  translate([-case_inner_width/2 + clip_overhang/2 - clip_gap, -case_inner_length/4, 0])
    clip_lip();
}

module op_clip_left_1() {
  union() {
    op_clip_arm_left_1();
    op_clip_lip_left_1();
  }
}

module op_clip_arm_left_2() {
  translate([-case_inner_width/2 - clip_thickness/2 + overlap, case_inner_length/4, 0])
    clip_arm();
}

module op_clip_lip_left_2() {
  translate([-case_inner_width/2 + clip_overhang/2 - clip_gap, case_inner_length/4, 0])
    clip_lip();
}

module op_clip_left_2() {
  union() {
    op_clip_arm_left_2();
    op_clip_lip_left_2();
  }
}

module op_clip_arm_right_1() {
  translate([case_inner_width/2 + clip_thickness/2 - overlap, -case_inner_length/4, 0])
    clip_arm();
}

module op_clip_lip_right_1() {
  translate([case_inner_width/2 - clip_overhang/2 + clip_gap, -case_inner_length/4, 0])
    clip_lip();
}

module op_clip_right_1() {
  union() {
    op_clip_arm_right_1();
    op_clip_lip_right_1();
  }
}

module op_clip_arm_right_2() {
  translate([case_inner_width/2 + clip_thickness/2 - overlap, case_inner_length/4, 0])
    clip_arm();
}

module op_clip_lip_right_2() {
  translate([case_inner_width/2 - clip_overhang/2 + clip_gap, case_inner_length/4, 0])
    clip_lip();
}

module op_clip_right_2() {
  union() {
    op_clip_arm_right_2();
    op_clip_lip_right_2();
  }
}

module op_snap_fit_clips() {
  union() {
    op_clip_left_1();
    op_clip_left_2();
    op_clip_right_1();
    op_clip_right_2();
  }
}

module op_main_body() {
  union() {
    op_cable_clearance_chamfer();
    op_board_standoffs();
    op_end_stops();
    op_snap_fit_clips();
  }
}

module op_usb_reference_union() {
  union() {
    usb_ref_B();
    usb_ref_uA();
    usb_ref_Ax2();
    usb_ref_C();
    usb_ref_Ax1();
  }
}

module op_final_model() {
  union() {
    op_main_body();
    op_usb_reference_union();
  }
}

// Final Output
op_final_model();