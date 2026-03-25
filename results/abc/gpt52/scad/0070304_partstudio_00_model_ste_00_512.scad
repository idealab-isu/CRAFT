$fn=64;

plate_th = 6;

body_len = 120;
body_w   = 60;

tongue_len = 70;
tongue_w   = 30;

step_len = 20;

small_hex_flat = 6.5;
large_hex_flat = 16;

small_hex_r = small_hex_flat / sqrt(3);
large_hex_r = large_hex_flat / sqrt(3);

module hex_hole(r, h){
  cylinder(h=h, r=r, $fn=6);
}

module base_profile(){
  union(){
    translate([-(body_len/2), -(body_w/2), 0])
      cube([body_len, body_w, plate_th], center=false);

    translate([(body_len/2), -(tongue_w/2), 0])
      cube([tongue_len, tongue_w, plate_th], center=false);

    translate([(body_len/2 + tongue_len), 0, 0])
      cylinder(h=plate_th, r=tongue_w/2, center=false);
  }
}

module stepped_plate(){
  union(){
    base_profile();
    translate([body_len/2 - step_len, -(body_w/2), plate_th])
      cube([step_len, body_w, 2], center=false);
  }
}

module holes(){
  // Large hex hole on wide section
  translate([-body_len*0.20, 0, -1])
    hex_hole(large_hex_r, plate_th + 4);

  // Four small hex holes near rounded end in 2x2 pattern
  x0 = body_len/2 + tongue_len*0.55;
  dx = 14;
  dy = 14;

  for (ix=[-0.5, 0.5])
    for (iy=[-0.5, 0.5])
      translate([x0 + ix*dx, iy*dy, -1])
        hex_hole(small_hex_r, plate_th + 4);
}

difference(){
  stepped_plate();
  holes();
}