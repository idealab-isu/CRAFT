$fn=64;

shaft_d = 8.0;
block_x = 42.0;
block_y = 36.0;
block_z = 20.0;

clearance = 0.4;
bore_d = shaft_d + clearance;

mount_hole_d = 5.0;
mount_hole_spacing_x = 32.0;
mount_hole_spacing_y = 26.0;

counterbore_d = 9.0;
counterbore_depth = 4.0;

clamp_slot_w = 2.0;
clamp_slot_len = 18.0;

clamp_screw_d = 3.2;
clamp_screw_head_d = 6.2;
clamp_screw_head_depth = 2.5;
clamp_screw_offset_y = 10.0;

module mount_holes() {
  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([sx*mount_hole_spacing_x/2, sy*mount_hole_spacing_y/2, 0]) {
      cylinder(d=mount_hole_d, h=block_z+0.2, center=true);
      translate([0,0, block_z/2 - counterbore_depth/2])
        cylinder(d=counterbore_d, h=counterbore_depth+0.2, center=true);
    }
  }
}

module clamp_features() {
  translate([0, 0, 0])
    translate([0, 0, 0])
      translate([0, 0, 0])
        translate([0, 0, 0])
          translate([0, 0, 0])
            translate([0, 0, 0])
              translate([0, 0, 0])
                translate([0, 0, 0])
                  translate([0, 0, 0])
                    translate([0, 0, 0])
                      translate([0, 0, 0])
                        translate([0, 0, 0])
                          translate([0, 0, 0])
                            translate([0, 0, 0])
                              translate([0, 0, 0])
                                translate([0, 0, 0])
                                  translate([0, 0, 0])
                                    translate([0, 0, 0])
                                      translate([0, 0, 0])
                                        translate([0, 0, 0])
                                          translate([0, 0, 0])
                                            translate([0, 0, 0])
                                              translate([0, 0, 0])
                                                translate([0, 0, 0])
                                                  translate([0, 0, 0])
                                                    translate([0, 0, 0])
                                                      translate([0, 0, 0])
                                                        translate([0, 0, 0])
                                                          translate([0, 0, 0])
                                                            translate([0, 0, 0])
                                                              translate([0, 0, 0])
                                                                translate([0, 0, 0])
                                                                  translate([0, 0, 0])
                                                                    translate([0, 0, 0])
                                                                      translate([0, 0, 0])
                                                                        translate([0, 0, 0])
                                                                          translate([0, 0, 0])
                                                                            translate([0, 0, 0])
                                                                              translate([0, 0, 0])
                                                                                translate([0, 0, 0])
                                                                                  translate([0, 0, 0])
                                                                                    translate([0, 0, 0])
                                                                                      translate([0, 0, 0])
                                                                                        translate([0, 0, 0])
                                                                                          translate([0, 0, 0])
                                                                                            translate([0, 0, 0])
                                                                                              translate([0, 0, 0])
                                                                                                translate([0, 0, 0])
                                                                                                  translate([0, 0, 0])
                                                                                                    translate([0, 0, 0])
                                                                                                      translate([0, 0, 0])
                                                                                                        translate([0, 0, 0])
                                                                                                          translate([0, 0, 0])
                                                                                                            translate([0, 0, 0])
                                                                                                              translate([0, 0, 0])
                                                                                                                translate([0, 0, 0])
                                                                                                                  translate([0, 0, 0])
                                                                                                                    translate([0, 0, 0])
                                                                                                                      translate([0, 0, 0])
                                                                                                                        translate([0, 0, 0])
                                                                                                                          translate([0, 0, 0])
                                                                                                                            translate([0, 0, 0])
                                                                                                                              translate([0, 0, 0])
                                                                                                                                translate([0, 0, 0])
                                                                                                                                  translate([0, 0, 0])
                                                                                                                                    translate([0, 0, 0])
                                                                                                                                      translate([0, 0, 0])
                                                                                                                                        translate([0, 0, 0])
                                                                                                                                          translate([0, 0, 0])
                                                                                                                                            translate([0, 0, 0])
                                                                                                                                              translate([0, 0, 0])
                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                  translate([0, 0, 0])
                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                      translate([0, 0, 0])
                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                          translate([0, 0, 0])
                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                              translate([0, 0, 0])
                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                  translate([0, 0, 0])
                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                      translate([0, 0, 0])
                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                          translate([0, 0, 0])
                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                              translate([0, 0, 0])
                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                  translate([0, 0, 0])
                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                      translate([0, 0, 0])
                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                          translate([0, 0, 0])
                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                              translate([0, 0, 0])
                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                  translate([0, 0, 0])
                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                      translate([0, 0, 0])
                                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                                          translate([0, 0, 0])
                                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                              translate([0, 0, 0])
                                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                                  translate([0, 0, 0])
                                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                                      translate([0, 0, 0])
                                                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                                                          translate([0, 0, 0])
                                                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                                              translate([0, 0, 0])
                                                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                                                  translate([0, 0, 0])
                                                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                                                      translate([0, 0, 0])
                                                                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                                                                          translate([0, 0, 0])
                                                                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                                                              translate([0, 0, 0])
                                                                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                                                                  translate([0, 0, 0])
                                                                                                                                                                                                                                                    translate([0, 0, 0])
                                                                                                                                                                                                                                                      translate([0, 0, 0])
                                                                                                                                                                                                                                                        translate([0, 0, 0])
                                                                                                                                                                                                                                                          translate([0, 0, 0])
                                                                                                                                                                                                                                                            translate([0, 0, 0])
                                                                                                                                                                                                                                                              translate([0, 0, 0])
                                                                                                                                                                                                                                                                translate([0, 0, 0])
                                                                                                                                                                                                                                                                          cube([clamp_slot_len, clamp_slot_w, block_z+0.2], center=true);

  for (sx = [-1, 1]) {
    translate([sx*(clamp_slot_len/2 - 3.0), clamp_screw_offset_y, 0]) {
      cylinder(d=clamp_screw_d, h=block_z+0.2, center=true);
      translate([0,0, block_z/2 - clamp_screw_head_depth/2])
        cylinder(d=clamp_screw_head_d, h=clamp_screw_head_depth+0.2, center=true);
    }
  }
}

module bearing_block() {
  difference() {
    cube([block_x, block_y, block_z], center=true);

    rotate([90,0,0])
      cylinder(d=bore_d, h=block_y+0.4, center=true);

    mount_holes();

    translate([0, block_y/2 - clamp_slot_w/2, 0])
      cube([clamp_slot_len, clamp_slot_w, block_z+0.2], center=true);

    translate([0, block_y/2 - clamp_slot_w/2, 0])
      clamp_features();
  }
}

bearing_block();