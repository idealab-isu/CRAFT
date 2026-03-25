// Radial configuration: [2.0, 0, 6]
// Goal: a clear 6-fold radial pattern (in XY) with consistent arms/spacing,
// and NO dominating tall off-axis shaft. ONE connected solid.

radial_x = 2.0; //[1.0:4.0:0.1]
radial_y = 0.0; //[-2.0:2.0:0.1]
radial_z = 6.0; //[3.0:12.0:0.1]

connect_overlap = 0.8; //[0.5:2.0:0.1]

$fn = 96;

function vlen(x,y,z) = sqrt(x*x + y*y + z*z);

// 6-fold radial object derived from [x,y,z]:
// - radius comes from XY magnitude (here 2.0)
// - thickness/height comes from Z (here 6.0)
module radial_6fold(x, y, z) {
  r_xy = max(0.01, vlen(x, y, 0));
  h = max(1.0, abs(z));

  // Hub and arms sized from r_xy and h
  hub_r = max(0.6, r_xy * 0.45);
  hub_h = max(1.0, h * 0.35);

  arm_len = max(0.8, r_xy * 0.95);
  arm_w   = max(0.5, r_xy * 0.35);
  arm_h   = max(hub_h, h * 0.35);

  // Ensure arms overlap into hub for connectivity
  overlap = min(connect_overlap, hub_r * 0.9);

  union() {
    // Central hub
    cylinder(r=hub_r, h=hub_h, center=true);

    // 6 arms in XY plane
    for (i = [0:5]) {
      rotate([0,0,i*360/6])
        translate([hub_r + arm_len/2 - overlap, 0, 0])
          cube([arm_len, arm_w, arm_h], center=true);
    }

    // Small center boss to emphasize axis without creating a tall shaft
    boss_r = hub_r * 0.55;
    boss_h = max(hub_h, h * 0.55);
    cylinder(r=boss_r, h=boss_h, center=true);
  }
}

radial_6fold(radial_x, radial_y, radial_z);