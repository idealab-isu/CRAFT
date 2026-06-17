// Parameters
shank_diameter = 5; //[2.5:10:0.1]
length_under_head = 10; //[5:20:0.5]
head_diameter = 10; //[6:20:0.1]
head_height = 3.95; //[2:8:0.05]
threaded = 0; //[0:1:1]
drive_type_none = 1; //[0:1:1]
tip_type_chamfer = 1; //[0:1:1]
eps_overlap = 0.8; //[0.2:2:0.1]
shank_radius = 2.5; //[1.25:5:0.1]
head_radius = 5; //[3:10:0.1]
head_crown_radius = 6; //[3:12:0.1]
head_crown_center_z = 1.5; //[−2:6:0.1]
tip_chamfer_height = 1.2; //[0.5:3:0.1]
tip_point_radius2 = 0.6; //[0:2.5:0.1]
drive_recess_radius = 3; //[1.5:4.5:0.1]
drive_recess_depth = 2; //[0.8:3.5:0.1]
drive_recess_slot_width = 1; //[0.6:2:0.1]
drive_recess_overlap_z = 0.5; //[0.2:1.5:0.1]

// Screw and Washer
module screw_and_washer() {
  color("DimGray") {
    // Shank
    translate([0, 0, -length_under_head/2])
      cylinder(h=length_under_head, r=shank_radius, center=true);

    // Tip Chamfer
    translate([0, 0, -length_under_head + tip_chamfer_height/2])
      cylinder(h=tip_chamfer_height, r1=shank_radius, r2=tip_point_radius2, center=true);

    // Head
    intersection() {
      translate([0, 0, head_height/2 - eps_overlap/2])
        cylinder(h=head_height, r=head_radius, center=true);
      translate([0, 0, head_crown_center_z])
        sphere(r=head_crown_radius, center=true);
      translate([0, 0, head_height/2 - eps_overlap/2])
        cube([2*head_diameter, 2*head_diameter, head_height + 2*eps_overlap], center=true);
    }

    // Optional Drive Recess
    if (drive_type_none == 0) {
      difference() {
        translate([0, 0, head_height - (drive_recess_depth + drive_recess_overlap_z)/2])
          cylinder(h=drive_recess_depth + drive_recess_overlap_z, r=drive_recess_radius, center=true);
        translate([0, 0, head_height - (drive_recess_depth + drive_recess_overlap_z)/2])
          union() {
            cube([2*drive_recess_radius, drive_recess_slot_width, drive_recess_depth + drive_recess_overlap_z], center=true);
            cube([drive_recess_slot_width, 2*drive_recess_radius, drive_recess_depth + drive_recess_overlap_z], center=true);
          }
      }
    }
  }
}

// PCB Spacer
module pcb_spacer() {
  color("Silver") {
    // Spacer body
    difference() {
      cylinder(h=10, r=3, center=true);
      translate([0, 0, -5])
        cylinder(h=10, r=1.2, center=true);
    }
  }
}

// Buzzer
module buzzer() {
  color("Black") {
    // Buzzer body
    cylinder(h=10, r=5, center=true);
    // Buzzer top
    translate([0, 0, 5])
      cylinder(h=2, r=4, center=true);
  }
}

// Assembly
module assembly() {
  translate([0, 0, 0]) screw_and_washer();
  translate([0, 0, 15]) pcb_spacer();
  translate([0, 0, 30]) buzzer();
}

assembly();