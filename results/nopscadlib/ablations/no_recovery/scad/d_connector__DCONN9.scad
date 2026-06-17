// Parameters
overlap = 1; //[0.5:2:0.1]
shell_W = 30; //[15:60:0.5]
shell_H = 12; //[6:24:0.5]
shell_D = 8; //[4:16:0.5]
shell_wall_t = 1.2; //[0.6:2.4:0.1]
body_W = 34; //[17:68:0.5]
body_H = 14; //[7:28:0.5]
body_D = 18; //[9:36:0.5]
flange_W = 46; //[23:92:0.5]
flange_H = 18; //[9:36:0.5]
flange_t = 2.5; //[1.2:5:0.1]
mount_hole_d = 3.2; //[1.6:6.4:0.1]
mount_hole_spacing = 33; //[16.5:66:0.5]
face_recess_D = 1.5; //[0.5:4:0.1]
pin_rows = 2; //[1:3:1]
pin_cols = 9; //[1:25:1]
pin_pitch_x = 2.77; //[1.5:5:0.01]
pin_pitch_y = 2.84; //[1.5:5:0.01]
pin_d = 1; //[0.5:2:0.05]
pin_plate_t = 1.5; //[0.8:3:0.1]
jackscrew_d = 5; //[3:8:0.1]
jackscrew_len = 10; //[5:20:0.5]
strain_relief_W = 20; //[10:40:0.5]
strain_relief_H = 10; //[5:20:0.5]
strain_relief_D = 6; //[3:12:0.5]
boot_r = 8; //[4:16:0.5]
boot_len = 18; //[9:36:0.5]
fillet_r = 1; //[0.5:3:0.1]

// D-shell outer profile
module d_shell_outer_profile() {
  linear_extrude(height = shell_D, center = true)
    polygon(points = [
      [-shell_W/2, -shell_H/2],
      [shell_W/2, -shell_H/2],
      [shell_W/2, shell_H/2],
      [-shell_W/2, shell_H/2],
      [-shell_W/2, -shell_H/2]
    ]);
}

// D-shell outer rounder
module d_shell_outer_rounder() {
  translate([shell_W/2 - shell_H/2, 0, 0])
    cylinder(r = shell_H/2, h = shell_D, center = true);
}

// D-shell inner profile
module d_shell_inner_profile() {
  linear_extrude(height = shell_D - shell_wall_t, center = true)
    polygon(points = [
      [-(shell_W - 2*shell_wall_t)/2, -(shell_H - 2*shell_wall_t)/2],
      [(shell_W - 2*shell_wall_t)/2, -(shell_H - 2*shell_wall_t)/2],
      [(shell_W - 2*shell_wall_t)/2, (shell_H - 2*shell_wall_t)/2],
      [-(shell_W - 2*shell_wall_t)/2, (shell_H - 2*shell_wall_t)/2],
      [-(shell_W - 2*shell_wall_t)/2, -(shell_H - 2*shell_wall_t)/2]
    ]);
}

// D-shell inner rounder
module d_shell_inner_rounder() {
  translate([(shell_W - 2*shell_wall_t)/2 - (shell_H - 2*shell_wall_t)/2, 0, 0])
    cylinder(r = (shell_H - 2*shell_wall_t)/2, h = shell_D - shell_wall_t, center = true);
}

// Connector body
module connector_body() {
  translate([0, 0, -(shell_D/2 + body_D/2 - overlap)])
    cube([body_W, body_H, body_D], center = true);
}

// Mounting flange
module mounting_flange() {
  translate([0, 0, shell_D/2 + flange_t/2 - overlap])
    cube([flange_W, flange_H, flange_t], center = true);
}

// Mounting holes
module mount_hole_left() {
  translate([-mount_hole_spacing/2, 0, shell_D/2 + flange_t/2 - overlap])
    cylinder(r = mount_hole_d/2, h = flange_t + 2*overlap, center = true);
}

module mount_hole_right() {
  translate([mount_hole_spacing/2, 0, shell_D/2 + flange_t/2 - overlap])
    cylinder(r = mount_hole_d/2, h = flange_t + 2*overlap, center = true);
}

// Mating face recess profile
module mating_face_recess_profile() {
  linear_extrude(height = face_recess_D + overlap, center = true)
    polygon(points = [
      [-(shell_W - 2*shell_wall_t)/2, -(shell_H - 2*shell_wall_t)/2],
      [(shell_W - 2*shell_wall_t)/2, -(shell_H - 2*shell_wall_t)/2],
      [(shell_W - 2*shell_wall_t)/2, (shell_H - 2*shell_wall_t)/2],
      [-(shell_W - 2*shell_wall_t)/2, (shell_H - 2*shell_wall_t)/2],
      [-(shell_W - 2*shell_wall_t)/2, -(shell_H - 2*shell_wall_t)/2]
    ]);
}

// Mating face recess rounder
module mating_face_recess_rounder() {
  translate([(shell_W - 2*shell_wall_t)/2 - (shell_H - 2*shell_wall_t)/2, 0, shell_D/2 - face_recess_D/2])
    cylinder(r = (shell_H - 2*shell_wall_t)/2, h = face_recess_D + overlap, center = true);
}

// Pin field placeholder
module pin_field_placeholder() {
  translate([0, 0, shell_D/2 - face_recess_D - pin_plate_t/2 + overlap])
    cube([(pin_cols - 1)*pin_pitch_x + 2*pin_d, (pin_rows - 1)*pin_pitch_y + 2*pin_d, pin_plate_t], center = true);
}

// Pin detail geometry
module pin_detail_geometry() {
  translate([0, 0, shell_D/2 - face_recess_D - pin_plate_t/2 + overlap])
    cylinder(r = pin_d/2, h = pin_plate_t + overlap, center = true);
}

// Jackscrews
module jackscrew_left() {
  translate([-mount_hole_spacing/2, 0, shell_D/2 + flange_t + jackscrew_len/2 - overlap])
    cylinder(r = jackscrew_d/2, h = jackscrew_len, center = true);
}

module jackscrew_right() {
  translate([mount_hole_spacing/2, 0, shell_D/2 + flange_t + jackscrew_len/2 - overlap])
    cylinder(r = jackscrew_d/2, h = jackscrew_len, center = true);
}

// Strain relief
module strain_relief() {
  translate([0, 0, -(shell_D/2 + body_D - strain_relief_D/2 - overlap)])
    cube([strain_relief_W, strain_relief_H, strain_relief_D], center = true);
}

// Rear cable boot
module rear_cable_boot() {
  translate([0, 0, -(shell_D/2 + body_D + boot_len/2 - overlap)])
    cylinder(r = boot_r, h = boot_len, center = true);
}

// Shell fillet chamfers sphere
module shell_fillet_chamfers_sphere() {
  sphere(r = fillet_r, center = true);
}

// Assemble the connector
module connector() {
  // D-shell outer
  union() {
    d_shell_outer_profile();
    d_shell_outer_rounder();
  }
  
  // D-shell inner
  translate([0, 0, -shell_wall_t/2])
    union() {
      d_shell_inner_profile();
      d_shell_inner_rounder();
    }
  
  // D-shell hollow
  difference() {
    union() {
      d_shell_outer_profile();
      d_shell_outer_rounder();
    }
    translate([0, 0, -shell_wall_t/2])
      union() {
        d_shell_inner_profile();
        d_shell_inner_rounder();
      }
  }
  
  // Mating face recess
  translate([0, 0, shell_D/2 - face_recess_D/2])
    union() {
      mating_face_recess_profile();
      mating_face_recess_rounder();
    }
  
  // D-shell with recess
  difference() {
    difference() {
      union() {
        d_shell_outer_profile();
        d_shell_outer_rounder();
      }
      translate([0, 0, -shell_wall_t/2])
        union() {
          d_shell_inner_profile();
          d_shell_inner_rounder();
        }
    }
    translate([0, 0, shell_D/2 - face_recess_D/2])
      union() {
        mating_face_recess_profile();
        mating_face_recess_rounder();
      }
  }
  
  // Mounting holes
  union() {
    mount_hole_left();
    mount_hole_right();
  }
  
  // Flange with holes
  difference() {
    mounting_flange();
    union() {
      mount_hole_left();
      mount_hole_right();
    }
  }
  
  // Jackscrews
  union() {
    jackscrew_left();
    jackscrew_right();
  }
  
  // Connector core union
  union() {
    difference() {
      difference() {
        union() {
          d_shell_outer_profile();
          d_shell_outer_rounder();
        }
        translate([0, 0, -shell_wall_t/2])
          union() {
            d_shell_inner_profile();
            d_shell_inner_rounder();
          }
      }
      translate([0, 0, shell_D/2 - face_recess_D/2])
        union() {
          mating_face_recess_profile();
          mating_face_recess_rounder();
        }
    }
    connector_body();
    difference() {
      mounting_flange();
      union() {
        mount_hole_left();
        mount_hole_right();
      }
    }
    pin_field_placeholder();
    pin_detail_geometry();
    union() {
      jackscrew_left();
      jackscrew_right();
    }
    strain_relief();
    rear_cable_boot();
  }
}

// Final output with fillet chamfers
minkowski() {
  connector();
  shell_fillet_chamfers_sphere();
}