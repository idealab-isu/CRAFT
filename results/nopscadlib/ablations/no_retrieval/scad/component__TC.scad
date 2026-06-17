$fn = 64;

// Parameters
body_L = 60; //[30:120:1]
body_W = 40; //[20:80:1]
body_H = 20; //[10:40:1]

flange_L = 70; //[35:140:1]
flange_W = 50; //[25:100:1]
flange_T = 4;  //[2:10:1]

hole_d = 5; //[2:12:1]
hole_spacing_X = 50; //[20:100:1]
hole_spacing_Y = 30; //[15:80:1]
hole_edge_margin = 10; //[5:25:1]

overlap = 1; //[0.5:2:0.5]

// Derived placement (keeps solids connected and holes centered through full thickness)
z_body_center = flange_T/2 + body_H/2 - overlap;
total_h = flange_T + body_H + 2*overlap;

// Clamp hole spacing so holes stay within flange with margin
max_sx = max(0, flange_L - 2*hole_edge_margin);
max_sy = max(0, flange_W - 2*hole_edge_margin);
sx = min(hole_spacing_X, max_sx);
sy = min(hole_spacing_Y, max_sy);

// Main body box (connected to flange with overlap)
module main_body_box() {
  translate([0, 0, z_body_center])
    cube([body_L, body_W, body_H], center=true);
}

// Base flange box
module base_flange_box() {
  cube([flange_L, flange_W, flange_T], center=true);
}

// Mounting hole cylinder (cuts through flange + body)
module mount_hole_cyl(x, y) {
  translate([x, y, z_body_center])
    cylinder(h=total_h, r=hole_d/2, center=true);
}

// Component with holes (single connected solid)
module component_final() {
  difference() {
    union() {
      base_flange_box();
      main_body_box();

      // Side flanges/ears (subtle) to match views; guaranteed connected
      ear_len = max(0, (flange_L - body_L)/2);
      if (ear_len > 0)
        for (s = [-1, 1])
          translate([s*(body_L/2 + ear_len/2 - overlap), 0, 0])
            cube([ear_len, flange_W, flange_T], center=true);
    }

    // 4 mounting holes
    mount_hole_cyl( sx/2,  sy/2);
    mount_hole_cyl(-sx/2,  sy/2);
    mount_hole_cyl(-sx/2, -sy/2);
    mount_hole_cyl( sx/2, -sy/2);
  }
}

color("Silver") component_final();