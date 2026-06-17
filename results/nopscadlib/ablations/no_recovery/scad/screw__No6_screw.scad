// Parameters
major_diameter = 3.5; //[1.75:7:0.05]
length = 10; //[5:20:0.5]
head_diameter = 6.7; //[3.35:13.4:0.05]
head_height = 2.2; //[1.1:4.4:0.05]
threaded = 1; //[0:1:1]
thread_detail_level = 1; //[0:2:1]
drive_type = 1; //[0:1:1]
overlap = 0.8; //[0.2:2:0.1]
tip_length = 0.8; //[0.2:2:0.1]
recess_depth = 1.1; //[0.4:1.8:0.05]
recess_width = 0.9; //[0.4:1.6:0.05]
recess_radius_factor = 0.55; //[0.35:0.75:0.01]
thread_ring_pitch = 0.8; //[0.4:1.6:0.05]
thread_ring_thickness = 0.25; //[0.1:0.6:0.05]
thread_ring_radial = 0.18; //[0.05:0.4:0.01]
pcb_spacer_height = 6; //[3:12:0.5]
washer_thickness = 0.8; //[0.4:1.6:0.05]
buzzer_diameter = 12; //[6:24:0.5]

// Screw components
module screw_shank() {
  translate([0, 0, -head_height/2])
    cylinder(h=length - head_height, r=major_diameter/2, center=true);
}

module shank_tip() {
  translate([0, 0, -head_height/2 - (length - head_height)/2 + tip_length/2])
    cylinder(h=tip_length, r1=major_diameter/2, r2=0, center=true);
}

module pan_head() {
  translate([0, 0, (length - head_height)/2 - overlap/2])
    cylinder(h=head_height, r=head_diameter/2, center=true);
}

module drive_recess() {
  intersection() {
    translate([0, 0, (length - head_height)/2 - overlap/2 + head_height/2 - recess_depth/2])
      cylinder(h=recess_depth, r=(head_diameter/2)*recess_radius_factor, center=true);
    union() {
      translate([0, 0, (length - head_height)/2 - overlap/2 + head_height/2 - recess_depth/2])
        cube([(head_diameter/2)*recess_radius_factor*2, recess_width, recess_depth], center=true);
      translate([0, 0, (length - head_height)/2 - overlap/2 + head_height/2 - recess_depth/2])
        cube([recess_width, (head_diameter/2)*recess_radius_factor*2, recess_depth], center=true);
    }
  }
}

module head_with_recess() {
  difference() {
    pan_head();
    drive_recess();
  }
}

module screw_body() {
  union() {
    screw_shank();
    shank_tip();
    head_with_recess();
  }
}

module thread_representation() {
  if (threaded) {
    union() {
      for (i = [0:7]) {
        translate([0, 0, -head_height/2 - (length - head_height)/2 + tip_length + thread_ring_pitch*i])
          cylinder(h=thread_ring_thickness, r=major_diameter/2, center=true);
      }
    }
  }
}

// PCB Spacer
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    translate([0, 0, length*10])
      cylinder(h=pcb_spacer_height, r=major_diameter/2, center=true);
  }
}

// Screw and Washer
module screw_and_washer() {
  color("Silver") {
    translate([0, 0, length*10])
      cylinder(h=washer_thickness, r=head_diameter/2, center=true);
  }
}

// Buzzer
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, length*10])
      cylinder(h=buzzer_diameter/2, r=buzzer_diameter/2, center=true);
  }
}

// Assembly
module assembly() {
  union() {
    screw_body();
    thread_representation();
    pcb_spacer();
    screw_and_washer();
    buzzer();
  }
}

assembly();