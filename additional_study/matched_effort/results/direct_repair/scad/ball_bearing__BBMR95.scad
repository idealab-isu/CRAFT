$fn = 128;

bore_d = 5.0;
od_d   = 9.0;
width  = 3.0;

// Simple ball bearing representation: outer ring + inner ring + ball set + light shields
module bearing_5x9x3() {
  ring_clearance = 0.15;          // radial gap between rings
  race_depth     = 0.55;          // how much material is removed to form race grooves
  shield_thk     = 0.25;          // thin shields on both sides
  shield_gap     = 0.25;          // keep shields away from balls
  ball_count     = 8;

  inner_od = bore_d + 2.0;        // inner ring outer diameter (approx)
  outer_id = od_d - 2.0;          // outer ring inner diameter (approx)

  // Ensure geometry stays valid
  inner_od2 = min(inner_od, outer_id - 2*ring_clearance);
  outer_id2 = max(outer_id, inner_od2 + 2*ring_clearance);

  // Ball path radius and ball size
  ball_path_r = (inner_od2/2 + outer_id2/2) / 2;
  ball_d = min( (outer_id2 - inner_od2) * 0.65, width * 0.85 );

  // Outer ring
  difference() {
    cylinder(d=od_d, h=width, center=true);
    cylinder(d=outer_id2, h=width+0.2, center=true);

    // race groove (torus-like subtraction via rotate_extrude)
    rotate_extrude()
      translate([ball_path_r, 0, 0])
        circle(d=ball_d + race_depth);
  }

  // Inner ring
  difference() {
    cylinder(d=inner_od2, h=width, center=true);
    cylinder(d=bore_d, h=width+0.2, center=true);

    // race groove
    rotate_extrude()
      translate([ball_path_r, 0, 0])
        circle(d=ball_d + race_depth);
  }

  // Balls
  for (i = [0:ball_count-1]) {
    angle = 360/ball_count * i;
    rotate([0,0,angle])
      translate([ball_path_r, 0, 0])
        sphere(d=ball_d);
  }

  // Shields (simple thin discs with center opening)
  for (side = [-1, 1]) {
    zpos = side * (width/2 - shield_thk/2);
    difference() {
      translate([0,0,zpos])
        cylinder(d=od_d, h=shield_thk, center=true);
      translate([0,0,zpos])
        cylinder(d=inner_od2 + 0.4, h=shield_thk+0.2, center=true);
      // keep shields from intersecting balls
      translate([0,0,side*(width/2 - shield_thk - shield_gap)])
        cylinder(d=outer_id2 - 0.2, h=shield_thk+0.2, center=true);
    }
  }
}

bearing_5x9x3();