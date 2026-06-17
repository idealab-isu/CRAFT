// Parameters
bore_d = 5.0; //[2.5:10.0:0.1]
outer_d = 13.0; //[6.5:26.0:0.1]
width = 4.0; //[2.0:8.0:0.1]
flange_d = 15.0; //[7.5:30.0:0.1]
flange_thk = 0.8; //[0.4:1.6:0.05]
inner_ring_od = 8.0; //[6.0:12.0:0.1]
outer_ring_id = 10.0; //[8.5:12.5:0.1]
radial_clearance = 0.1; //[0.05:0.3:0.01]
seal_thk = 0.3; //[0.15:0.8:0.05]
groove_depth = 0.4; //[0.2:0.8:0.05]
groove_radius = 0.6; //[0.3:1.2:0.05]
overlap = 0.6; //[0.2:1.5:0.05]
ball_d = 1.2; //[0.6:2.4:0.05]
num_balls = 8; //[5:12:1]
cage_thk = 0.6; //[0.3:1.2:0.05]
cage_radial_thk = 0.5; //[0.2:1.2:0.05]

// Base Shapes
module outer_ring_outer_cyl() {
  cylinder(r=outer_d/2, h=width, center=true);
}

module outer_ring_inner_bore_cyl() {
  cylinder(r=outer_ring_id/2, h=width + 2*overlap, center=true);
}

module flange_cyl() {
  translate([0, 0, width/2 - flange_thk/2])
    cylinder(r=flange_d/2, h=flange_thk, center=true);
}

module inner_ring_outer_cyl() {
  cylinder(r=inner_ring_od/2, h=width, center=true);
}

module inner_ring_bore_cyl() {
  cylinder(r=bore_d/2, h=width + 2*overlap, center=true);
}

module outer_groove_cutter_sphere() {
  translate([(outer_ring_id/2 + inner_ring_od/2)/2, 0, 0])
    sphere(r=groove_radius);
}

module inner_groove_cutter_sphere() {
  translate([(outer_ring_id/2 + inner_ring_od/2)/2, 0, 0])
    sphere(r=groove_radius);
}

module shield_left_cyl() {
  translate([0, 0, -width/2 + seal_thk/2])
    cylinder(r=outer_ring_id/2 - radial_clearance, h=seal_thk, center=true);
}

module shield_right_cyl() {
  translate([0, 0, width/2 - seal_thk/2])
    cylinder(r=outer_ring_id/2 - radial_clearance, h=seal_thk, center=true);
}

module cage_ring_outer_cyl() {
  cylinder(r=(outer_ring_id/2 + inner_ring_od/2)/2 + ball_d/2 + cage_radial_thk, h=cage_thk, center=true);
}

module cage_ring_inner_cyl() {
  cylinder(r=(outer_ring_id/2 + inner_ring_od/2)/2 - ball_d/2 - cage_radial_thk, h=cage_thk + 2*overlap, center=true);
}

module ball(pos) {
  translate(pos)
    sphere(r=ball_d/2);
}

// Operations
module outer_ring_shell() {
  difference() {
    outer_ring_outer_cyl();
    outer_ring_inner_bore_cyl();
  }
}

module outer_ring_with_flange() {
  union() {
    outer_ring_shell();
    flange_cyl();
  }
}

module inner_ring_shell() {
  difference() {
    inner_ring_outer_cyl();
    inner_ring_bore_cyl();
  }
}

module outer_ring_with_groove() {
  difference() {
    outer_ring_with_flange();
    translate([groove_depth, 0, 0]) outer_groove_cutter_sphere();
  }
}

module inner_ring_with_groove() {
  difference() {
    inner_ring_shell();
    translate([-groove_depth, 0, 0]) inner_groove_cutter_sphere();
  }
}

module cage_ring() {
  difference() {
    cage_ring_outer_cyl();
    cage_ring_inner_cyl();
  }
}

module balls_union() {
  union() {
    for (i = [0:num_balls-1]) {
      ball([(outer_ring_id/2 + inner_ring_od/2)/2 * cos(360/num_balls*i),
            (outer_ring_id/2 + inner_ring_od/2)/2 * sin(360/num_balls*i),
            0]);
    }
  }
}

module bearing_assembly_union() {
  union() {
    outer_ring_with_groove();
    inner_ring_with_groove();
    shield_left_cyl();
    shield_right_cyl();
    cage_ring();
    balls_union();
  }
}

module bearing_voids_clearances() {
  difference() {
    bearing_assembly_union();
    outer_ring_inner_bore_cyl();
  }
}

// Final Output
bearing_voids_clearances();