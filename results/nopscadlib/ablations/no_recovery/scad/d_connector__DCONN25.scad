// Parameters
shell_W = 30; //[15:60:1]
shell_H = 12; //[6:24:1]
shell_D = 18; //[9:36:1]
shell_wall_t = 1.5; //[0.8:3:0.1]
face_recess_D = 2; //[1:6:0.5]
flange_W = 40; //[20:80:1]
flange_H = 16; //[8:32:1]
flange_t = 2.5; //[1:6:0.5]
mount_hole_d = 3.2; //[2:6:0.1]
mount_hole_spacing = 33; //[16:66:1]
rear_block_W = 22; //[11:44:1]
rear_block_H = 10; //[5:20:1]
rear_block_D = 10; //[5:20:1]
overlap = 1; //[0.5:2:0.1]
pin_d = 1; //[0.6:2:0.1]
pin_len = 6; //[3:12:0.5]
pin_pitch_x = 2.8; //[2:4:0.1]
pin_pitch_y = 2.5; //[2:4:0.1]
jackscrew_d = 4; //[3:8:0.5]
jackscrew_len = 8; //[4:16:0.5]
boot_D = 14; //[8:28:1]
boot_r1 = 7; //[4:14:0.5]
boot_r2 = 4.5; //[2.5:10:0.5]
key_w = 4; //[2:8:0.5]
key_h = 2; //[1:5:0.5]
key_d = 1.5; //[0.8:4:0.1]
lip_t = 0.8; //[0.4:2:0.1]
lip_inset = 0.6; //[0.3:2:0.1]

// Base Shapes
module shell_outer_dshape() {
  union() {
    translate([0, 0, 0])
      cube([shell_W, shell_H, shell_D], center=true);
    translate([0, -shell_H/2, 0])
      cylinder(r=shell_H/2, h=shell_D, center=true);
  }
}

module shell_inner_dshape() {
  union() {
    translate([0, 0, shell_wall_t])
      cube([shell_W-2*shell_wall_t, shell_H-2*shell_wall_t, shell_D-2*shell_wall_t], center=true);
    translate([0, -shell_H/2+shell_wall_t, shell_wall_t])
      cylinder(r=shell_H/2-shell_wall_t, h=shell_D-2*shell_wall_t, center=true);
  }
}

module shell_hollow() {
  difference() {
    shell_outer_dshape();
    shell_inner_dshape();
  }
}

module mating_face_opening() {
  union() {
    translate([0, 0, shell_D/2-face_recess_D/2])
      cube([shell_W-2*shell_wall_t, shell_H-2*shell_wall_t, face_recess_D], center=true);
    translate([0, -shell_H/2+shell_wall_t, shell_D/2-face_recess_D/2])
      cylinder(r=shell_H/2-shell_wall_t, h=face_recess_D, center=true);
  }
}

module d_shell_housing() {
  difference() {
    shell_hollow();
    mating_face_opening();
  }
}

module mounting_flange() {
  difference() {
    union() {
      translate([0, 0, shell_D/2+flange_t/2-overlap])
        cube([flange_W, flange_H, flange_t], center=true);
      d_shell_housing();
    }
    translate([-mount_hole_spacing/2, 0, shell_D/2+flange_t/2-overlap])
      cylinder(r=mount_hole_d/2, h=flange_t+2*overlap, center=true);
    translate([mount_hole_spacing/2, 0, shell_D/2+flange_t/2-overlap])
      cylinder(r=mount_hole_d/2, h=flange_t+2*overlap, center=true);
  }
}

module rear_termination_block() {
  union() {
    mounting_flange();
    translate([0, 0, -shell_D/2-rear_block_D/2+overlap])
      cube([rear_block_W, rear_block_H, rear_block_D], center=true);
  }
}

module strain_relief_boot() {
  union() {
    rear_termination_block();
    translate([0, 0, -shell_D/2-rear_block_D-boot_D/2+2*overlap])
      cylinder(r1=boot_r1, r2=boot_r2, h=boot_D, center=true);
  }
}

module pins_or_sockets_array() {
  union() {
    for (i = [-2:2]) {
      translate([i*pin_pitch_x, pin_pitch_y/2, shell_D/2-face_recess_D-pin_len/2+overlap])
        cylinder(r=pin_d/2, h=pin_len, center=true);
      translate([i*pin_pitch_x+pin_pitch_x/2, -pin_pitch_y/2, shell_D/2-face_recess_D-pin_len/2+overlap])
        cylinder(r=pin_d/2, h=pin_len, center=true);
    }
  }
}

module jackscrews() {
  union() {
    translate([-mount_hole_spacing/2, 0, shell_D/2-face_recess_D-jackscrew_len/2+overlap])
      cylinder(r=jackscrew_d/2, h=jackscrew_len, center=true);
    translate([mount_hole_spacing/2, 0, shell_D/2-face_recess_D-jackscrew_len/2+overlap])
      cylinder(r=jackscrew_d/2, h=jackscrew_len, center=true);
  }
}

module keying_features() {
  translate([0, shell_H/2-shell_wall_t-key_h/2, shell_D/2-face_recess_D+key_d/2-overlap])
    cube([key_w, key_h, key_d], center=true);
}

module shell_lip_chamfers_fillets() {
  difference() {
    union() {
      translate([0, 0, shell_D/2-lip_t/2])
        cube([shell_W, shell_H, lip_t], center=true);
      translate([0, -shell_H/2, shell_D/2-lip_t/2])
        cylinder(r=shell_H/2, h=lip_t, center=true);
    }
    union() {
      translate([0, 0, shell_D/2-lip_t/2])
        cube([shell_W-2*lip_inset, shell_H-2*lip_inset, lip_t+2*overlap], center=true);
      translate([0, -shell_H/2+lip_inset, shell_D/2-lip_t/2])
        cylinder(r=shell_H/2-lip_inset, h=lip_t+2*overlap, center=true);
    }
  }
}

// Final Output
module connector_with_pins() {
  union() {
    strain_relief_boot();
    pins_or_sockets_array();
    jackscrews();
    keying_features();
    shell_lip_chamfers_fillets();
  }
}

// Render the connector
connector_with_pins();