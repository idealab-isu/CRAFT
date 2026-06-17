// Parameters
thread_diameter = 4; //[2:8:0.1]
length = 10; //[5:20:0.5]
head_diameter = 7.6; //[3.8:15.2:0.1]
head_height = 2.2; //[1.1:4.4:0.1]
overlap = 1; //[0.5:2:0.1]
washer_outer_diameter = 9; //[5:18:0.1]
washer_thickness = 1; //[0.5:2:0.1]
spacer_height = 6; //[3:12:0.5]
spacer_wall = 1.8; //[0.9:3.6:0.1]
spacer_clearance = 0.4; //[0.2:0.8:0.05]
buzzer_diameter = 12; //[6:24:0.5]
buzzer_height = 7; //[3.5:14:0.5]

// Derived Z layout (all solids centered on Z=0 head mid-plane)
shaft_h = length - head_height;

// Head spans: z in [-head_height/2, +head_height/2]
z_head_center   = 0;

// Shaft should start slightly inside head to guarantee union
// Shaft top at z = -head_height/2 + overlap
z_shaft_center  = (-head_height/2 + overlap) - shaft_h/2;

// Washer sits under head and overlaps into head by 'overlap'
z_washer_center = (-head_height/2 - washer_thickness/2 + overlap);

// Spacer sits under washer and overlaps into washer by 'overlap'
z_spacer_center = (z_washer_center - washer_thickness/2) - spacer_height/2 + overlap;

// Buzzer sits under spacer and overlaps into spacer by 'overlap'
z_buzzer_center = (z_spacer_center - spacer_height/2) - buzzer_height/2 + overlap;

// Screw and Washer - connected geometry
module screw_and_washer() {
  color("DimGray")
  union() {
    // Threaded Shaft (overlaps into head)
    translate([0, 0, z_shaft_center])
      cylinder(h=shaft_h, r=thread_diameter/2, center=true);

    // Dome Head
    intersection() {
      translate([0, 0, head_height/2 - head_diameter/2])
        sphere(r=head_diameter/2, center=true);
      translate([0, 0, z_head_center])
        cube([head_diameter, head_diameter, head_height], center=true);
    }

    // Washer (overlaps into head)
    difference() {
      translate([0, 0, z_washer_center])
        cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
      translate([0, 0, z_washer_center])
        cylinder(h=washer_thickness + 2*overlap, r=thread_diameter/2 + spacer_clearance, center=true);
    }
  }
}

// PCB Spacer - connected to washer
module pcb_spacer() {
  color("Silver")
  difference() {
    translate([0, 0, z_spacer_center])
      cylinder(h=spacer_height, r=thread_diameter/2 + spacer_clearance + spacer_wall, center=true);
    translate([0, 0, z_spacer_center])
      cylinder(h=spacer_height + 2*overlap, r=thread_diameter/2 + spacer_clearance, center=true);
  }
}

// Buzzer - connected to spacer (no floating)
module buzzer() {
  color("Black")
  translate([0, 0, z_buzzer_center])
    cylinder(h=buzzer_height, r=buzzer_diameter/2, center=true);
}

// Assembly: single connected solid
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    buzzer();
  }
}

assembly();