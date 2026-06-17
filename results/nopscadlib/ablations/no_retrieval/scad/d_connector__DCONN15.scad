// Parameters
body_width = 30; //[15:60:1]
body_height = 12; //[6:24:1]
body_depth = 18; //[9:36:1]
shell_thickness = 1.2; //[0.6:2.4:0.1]
face_recess_depth = 1.5; //[0.8:3:0.1]
flange_width = 40; //[20:80:1]
flange_height = 14; //[7:28:1]
flange_thickness = 2; //[1:4:0.1]
mount_hole_diameter = 3.2; //[1.6:6.4:0.1]
mount_hole_spacing = 33; //[16.5:66:0.5]
pin_rows = 2; //[1:3:1]
pins_per_row = 5; //[3:15:1]
pin_pitch_x = 2.77; //[1.5:5.5:0.01]
pin_pitch_y = 2.84; //[1.5:6:0.01]
pin_diameter = 1; //[0.5:2:0.05]
pin_length = 3; //[1.5:8:0.1]
overlap = 1; //[0.5:2:0.1]
shell_corner_radius = 3; //[1.5:6:0.1]
lip_height = 0.8; //[0.4:2:0.1]
lip_thickness = 0.8; //[0.4:2:0.1]
key_width = 4; //[2:8:0.1]
key_height = 2; //[1:4:0.1]
key_depth = 1.2; //[0.6:3:0.1]
jackscrew_diameter = 5; //[3:8:0.1]
jackscrew_length = 6; //[3:12:0.1]
strain_relief_diameter = 12; //[6:24:0.5]
strain_relief_length = 10; //[5:25:0.5]
pin_chamfer_scale = 0.75; //[0.5:0.95:0.01]
shell_chamfer_scale = 0.92; //[0.85:0.98:0.01]

// Base Shapes
module connector_body() {
  color("DimGray")
  translate([0, 0, 0])
    cube([body_width, body_height, body_depth], center=true);
}

module d_shaped_shell_outer() {
  color("Silver")
  translate([0, 0, 0])
    linear_extrude(height=body_depth, center=true)
      offset(r=shell_corner_radius)
        square([body_width, body_height], center=true);
}

module d_shaped_shell_inner() {
  translate([0, 0, 0])
    linear_extrude(height=body_depth + 2*overlap, center=true)
      offset(r=shell_corner_radius)
        square([body_width - 2*shell_thickness, body_height - 2*shell_thickness], center=true);
}

module mating_face_recess_cut() {
  translate([0, 0, body_depth/2 - face_recess_depth/2])
    cube([body_width - 2*shell_thickness, body_height - 2*shell_thickness, face_recess_depth + 2*overlap], center=true);
}

module mounting_flange_blank() {
  color("Silver")
  translate([0, 0, body_depth/2 - flange_thickness/2 + overlap])
    cube([flange_width, flange_height, flange_thickness], center=true);
}

module mount_hole_left() {
  translate([-mount_hole_spacing/2, 0, body_depth/2 - flange_thickness/2 + overlap])
    cylinder(r=mount_hole_diameter/2, h=flange_thickness + 2*overlap, center=true);
}

module mount_hole_right() {
  translate([mount_hole_spacing/2, 0, body_depth/2 - flange_thickness/2 + overlap])
    cylinder(r=mount_hole_diameter/2, h=flange_thickness + 2*overlap, center=true);
}

module jackscrew_left() {
  color("Black")
  translate([-mount_hole_spacing/2, 0, body_depth/2 + jackscrew_length/2 - overlap])
    cylinder(r=jackscrew_diameter/2, h=jackscrew_length, center=true);
}

module jackscrew_right() {
  color("Black")
  translate([mount_hole_spacing/2, 0, body_depth/2 + jackscrew_length/2 - overlap])
    cylinder(r=jackscrew_diameter/2, h=jackscrew_length, center=true);
}

module rear_strain_relief() {
  color("Black")
  translate([0, 0, -body_depth/2 - strain_relief_length/2 + overlap])
    cylinder(r=strain_relief_diameter/2, h=strain_relief_length, center=true);
}

module pin(position) {
  translate(position)
    cylinder(r=pin_diameter/2, h=pin_length, center=true);
}

module pin_tip(position) {
  translate(position)
    scale([pin_chamfer_scale, pin_chamfer_scale, 1])
      cylinder(r1=pin_diameter/2, r2=0, h=pin_diameter, center=true);
}

module shell_lip_outer() {
  color("Silver")
  translate([0, 0, body_depth/2 - lip_height/2])
    linear_extrude(height=lip_height, center=true)
      offset(r=shell_corner_radius)
        square([body_width, body_height], center=true);
}

module shell_lip_inner_cut() {
  translate([0, 0, body_depth/2 - lip_height/2])
    linear_extrude(height=lip_height + 2*overlap, center=true)
      offset(r=shell_corner_radius)
        square([body_width - 2*lip_thickness, body_height - 2*lip_thickness], center=true);
}

module shell_lip_chamfer_tool() {
  translate([0, 0, body_depth/2 - lip_height/2])
    linear_extrude(height=lip_height, center=true)
      offset(r=shell_corner_radius)
        square([body_width, body_height], center=true);
}

module keying_details_cut() {
  translate([0, -(body_height/2 - shell_thickness - key_height/2), body_depth/2 - key_depth/2])
    cube([key_width, key_height, key_depth + 2*overlap], center=true);
}

// Operations
module d_shaped_shell() {
  difference() {
    d_shaped_shell_outer();
    d_shaped_shell_inner();
  }
}

module mating_face() {
  difference() {
    connector_body();
    mating_face_recess_cut();
    keying_details_cut();
  }
}

module mounting_holes() {
  union() {
    mount_hole_left();
    mount_hole_right();
  }
}

module mounting_flange() {
  difference() {
    mounting_flange_blank();
    mounting_holes();
  }
}

module pin_array() {
  union() {
    pin([-2*pin_pitch_x, pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
    pin([-pin_pitch_x, pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
    pin([0, pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
    pin([pin_pitch_x, pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
    pin([2*pin_pitch_x, pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
    pin([-2*pin_pitch_x + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
    pin([-pin_pitch_x + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
    pin([0 + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
    pin([pin_pitch_x + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
    pin([2*pin_pitch_x + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length/2 - overlap]);
  }
}

module pin_chamfers() {
  union() {
    pin_tip([-2*pin_pitch_x, pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
    pin_tip([-pin_pitch_x, pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
    pin_tip([0, pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
    pin_tip([pin_pitch_x, pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
    pin_tip([2*pin_pitch_x, pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
    pin_tip([-2*pin_pitch_x + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
    pin_tip([-pin_pitch_x + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
    pin_tip([0 + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
    pin_tip([pin_pitch_x + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
    pin_tip([2*pin_pitch_x + pin_pitch_x/2, -pin_pitch_y/2, body_depth/2 + pin_length - pin_diameter/2 - overlap]);
  }
}

module shell_lip_ring() {
  difference() {
    shell_lip_outer();
    shell_lip_inner_cut();
  }
}

module shell_lip_chamfers() {
  difference() {
    shell_lip_ring();
    scale([shell_chamfer_scale, shell_chamfer_scale, 1])
      shell_lip_chamfer_tool();
  }
}

module jackscrews() {
  union() {
    jackscrew_left();
    jackscrew_right();
  }
}

module connector_body_with_shell() {
  union() {
    mating_face();
    d_shaped_shell();
  }
}

module connector_body_with_flange() {
  union() {
    connector_body_with_shell();
    mounting_flange();
  }
}

module connector_body_with_lip() {
  union() {
    connector_body_with_flange();
    shell_lip_chamfers();
  }
}

module connector_body_with_pins() {
  union() {
    connector_body_with_lip();
    pin_array();
    pin_chamfers();
  }
}

module connector_body_with_hardware() {
  union() {
    connector_body_with_pins();
    jackscrews();
  }
}

module complete_model() {
  union() {
    connector_body_with_hardware();
    rear_strain_relief();
  }
}

// Final Output
complete_model();