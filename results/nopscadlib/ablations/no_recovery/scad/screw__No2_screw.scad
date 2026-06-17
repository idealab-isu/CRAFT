// Parameters
shaft_diameter = 2.2; //[1.1:4.4:0.1]
shaft_radius = 1.1; //[0.55:2.2:0.05]
length = 10; //[5:20:0.5]
head_diameter = 4.2; //[2.1:8.4:0.1]
head_radius = 2.1; //[1.05:4.2:0.05]
head_height = 1.7; //[0.85:3.4:0.05]
threaded = 0; //[0:1:1]
drive_recess = 0; //[0:1:1]
overlap = 0.8; //[0.5:2:0.1]
recess_radius = 1.2; //[0.6:2.0:0.05]
recess_depth = 0.9; //[0.4:1.4:0.05]
recess_slot_width = 0.6; //[0.3:1.2:0.05]
thread_placeholder_radius = 1.25; //[0.8:2.2:0.05]

// Screw components
module screw_shaft() {
  translate([0, 0, -head_height/2 - (length - head_height)/2 + overlap/2])
    cylinder(r=shaft_radius, h=length - head_height, center=true);
}

module pan_head() {
  translate([0, 0, 0])
    cylinder(r=head_radius, h=head_height, center=true);
}

module drive_recess_slot_x() {
  translate([0, 0, head_height/2 - (recess_depth + overlap)/2])
    cube([2*recess_radius, recess_slot_width, recess_depth + overlap], center=true);
}

module drive_recess_slot_y() {
  translate([0, 0, head_height/2 - (recess_depth + overlap)/2])
    cube([recess_slot_width, 2*recess_radius, recess_depth + overlap], center=true);
}

module thread_optional() {
  translate([0, 0, -head_height/2 - (length - head_height)/2 + overlap/2])
    cylinder(r=thread_placeholder_radius, h=length - head_height, center=true);
}

// Mandatory components
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=shaft_radius + 1.8, h=overlap, center=true);
      translate([0, 0, -overlap/2])
        cylinder(r=shaft_radius, h=overlap, center=true);
    }
  }
}

module screw_and_washer() {
  color([0.75, 0.75, 0.77]) {
    union() {
      translate([0, 0, head_height/2 - overlap/2])
        cylinder(r=shaft_radius + 1, h=overlap, center=true);
      translate([0, 0, head_height/2])
        cylinder(r=shaft_radius, h=overlap, center=true);
    }
  }
}

module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, -length/2 + overlap/2])
      cylinder(r=shaft_radius + 2, h=overlap, center=true);
  }
}

// Assembly
module assembly() {
  union() {
    if (drive_recess) {
      difference() {
        union() {
          pan_head();
          screw_shaft();
        }
        union() {
          drive_recess_slot_x();
          drive_recess_slot_y();
        }
      }
    } else {
      union() {
        pan_head();
        screw_shaft();
      }
    }
    if (threaded) {
      thread_optional();
    }
    pcb_spacer();
    screw_and_washer();
    buzzer();
  }
}

assembly();