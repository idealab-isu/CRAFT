// Parameters
thread_diameter_mm = 2.5; //[1.25:5:0.05]
length_mm = 10; //[5:20:0.1]
head_diameter_mm = 5.35; //[2.675:10.7:0.05]
head_height_mm = 1.6; //[0.8:3.2:0.05]
tip_cone_height_mm = 0.8; //[0.4:1.6:0.05]
underhead_overlap_mm = 0.8; //[0.5:2:0.05]
drive_recess_enable = 1; //[0:1:1]
drive_recess_diameter_mm = 2.2; //[1.2:3.5:0.05]
drive_recess_depth_mm = 0.8; //[0.3:1.4:0.05]
dome_sphere_radius_factor = 1.2; //[0.8:2.0:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Global overlap to guarantee physical connection between stacked parts
connect_overlap_mm = 1.2; // 1–2mm recommended

// Screw (dome head) - built as one connected solid
module screw() {
  color("DimGray")
  union() {
    // Coordinate convention:
    // Head spans z=[-head_height_mm, 0] (top at 0)
    // Shank starts slightly inside head and goes downward
    // Tip continues from shank with overlap

    // Head (with recess cut)
    difference() {
      union() {
        // Head base
        translate([0, 0, -head_height_mm/2])
          cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);

        // Dome cap (kept within head height envelope)
        intersection() {
          translate([0, 0, -head_height_mm + (head_diameter_mm/2)*dome_sphere_radius_factor])
            sphere(r=(head_diameter_mm/2)*dome_sphere_radius_factor);
          translate([0, 0, -head_height_mm/2])
            cube([head_diameter_mm*2, head_diameter_mm*2, head_height_mm], center=true);
        }
      }

      // Drive recess from top face downward
      if (drive_recess_enable) {
        translate([0, 0, -drive_recess_depth_mm/2 + eps_mm/2])
          cylinder(h=drive_recess_depth_mm + eps_mm, r=drive_recess_diameter_mm/2, center=true);
      }
    }

    // Shank: top of shank overlaps into head by connect_overlap_mm
    // Shank top plane should be at z = -head_height_mm + connect_overlap_mm
    translate([0, 0, (-head_height_mm + connect_overlap_mm) - length_mm/2])
      cylinder(h=length_mm, r=thread_diameter_mm/2, center=true);

    // Tip: overlaps into shank by connect_overlap_mm
    // Shank bottom plane is at z = (-head_height_mm + connect_overlap_mm) - length_mm
    // Tip top plane should be at shank bottom + connect_overlap_mm
    translate([0, 0, (-head_height_mm + connect_overlap_mm) - length_mm - tip_cone_height_mm/2 + connect_overlap_mm])
      cylinder(h=tip_cone_height_mm, r1=thread_diameter_mm/2, r2=0, center=true);
  }
}

// PCB Spacer (middle cylindrical segment) - attached to screw head with overlap
module pcb_spacer() {
  spacer_h = 5;
  spacer_r = 3;

  // Bottom of spacer overlaps into top of screw head (top of head at z=0)
  translate([0, 0, spacer_h/2 - connect_overlap_mm])
    color("Silver")
      cylinder(h=spacer_h, r=spacer_r, center=true);
}

// Buzzer (top large cylindrical segment) - attached to spacer with overlap
module buzzer() {
  buzzer_h = 10;
  buzzer_r = 5;
  spacer_h = 5;

  // Spacer top plane is at z = (spacer_h - connect_overlap_mm)
  // Place buzzer so its bottom overlaps into spacer by connect_overlap_mm
  translate([0, 0, (spacer_h - connect_overlap_mm) + buzzer_h/2 - connect_overlap_mm])
    color("Black")
      cylinder(h=buzzer_h, r=buzzer_r, center=true);
}

// Assembly: single connected solid (union) to eliminate floating/disconnected parts
module assembly() {
  union() {
    screw();
    pcb_spacer();
    buzzer();
  }
}

assembly();