// Parameters
bore_d = 8.0; //[4.0:16.0:0.1]
outer_d = 22.0; //[11.0:44.0:0.1]
width = 7.0; //[3.5:14.0:0.1]
inner_ring_radial_thk = 3.0; //[1.5:6.0:0.1]
outer_ring_radial_thk = 3.0; //[1.5:6.0:0.1]
ball_d = 3.5; //[1.5:7.0:0.1]
ball_count = 7; //[5:12:1]
ball_clearance = 0.2; //[0.0:0.6:0.05]
groove_depth = 0.6; //[0.2:1.2:0.05]
groove_radius = 1.9; //[1.0:3.5:0.05]
cage_thk = 0.8; //[0.4:1.6:0.05]
cage_clearance = 0.2; //[0.0:0.6:0.05]
shield_thk = 0.3; //[0.15:0.8:0.05]
shield_radial_gap = 0.3; //[0.1:1.0:0.05]
overlap = 0.8; //[0.5:2.0:0.1]

// Base Shapes
module outer_ring_outer_cyl() {
  cylinder(r=outer_d/2, h=width, center=true);
}

module outer_ring_inner_bore_cyl() {
  cylinder(r=outer_d/2 - outer_ring_radial_thk, h=width + 2*overlap, center=true);
}

module inner_ring_outer_cyl() {
  cylinder(r=bore_d/2 + inner_ring_radial_thk, h=width, center=true);
}

module inner_ring_bore_cyl() {
  cylinder(r=bore_d/2, h=width + 2*overlap, center=true);
}

module outer_race_groove_torus() {
  rotate_extrude() translate([((outer_d/2 - outer_ring_radial_thk) - (bore_d/2 + inner_ring_radial_thk))/2 + (bore_d/2 + inner_ring_radial_thk), 0, 0])
    circle(r=groove_radius);
}

module inner_race_groove_torus() {
  rotate_extrude() translate([((outer_d/2 - outer_ring_radial_thk) - (bore_d/2 + inner_ring_radial_thk))/2 + (bore_d/2 + inner_ring_radial_thk), 0, 0])
    circle(r=groove_radius);
}

module ball(position_angle) {
  translate([((outer_d/2 - outer_ring_radial_thk) + (bore_d/2 + inner_ring_radial_thk))/2 * cos(position_angle),
             ((outer_d/2 - outer_ring_radial_thk) + (bore_d/2 + inner_ring_radial_thk))/2 * sin(position_angle), 0])
    sphere(r=ball_d/2);
}

module cage_outer_cyl() {
  cylinder(r=((outer_d/2 - outer_ring_radial_thk) + (bore_d/2 + inner_ring_radial_thk))/2 + (ball_d/2 + cage_clearance) + cage_thk,
           h=width - 2*(shield_thk + overlap), center=true);
}

module cage_inner_cyl() {
  cylinder(r=((outer_d/2 - outer_ring_radial_thk) + (bore_d/2 + inner_ring_radial_thk))/2 - (ball_d/2 + cage_clearance) - cage_thk,
           h=width - 2*(shield_thk + overlap) + 2*overlap, center=true);
}

module shield_top_disk() {
  translate([0, 0, width/2 - shield_thk/2])
    cylinder(r=outer_d/2 - overlap, h=shield_thk, center=true);
}

module shield_top_hole() {
  translate([0, 0, width/2 - shield_thk/2])
    cylinder(r=bore_d/2 + inner_ring_radial_thk + shield_radial_gap, h=shield_thk + 2*overlap, center=true);
}

module shield_bottom_disk() {
  translate([0, 0, -width/2 + shield_thk/2])
    cylinder(r=outer_d/2 - overlap, h=shield_thk, center=true);
}

module shield_bottom_hole() {
  translate([0, 0, -width/2 + shield_thk/2])
    cylinder(r=bore_d/2 + inner_ring_radial_thk + shield_radial_gap, h=shield_thk + 2*overlap, center=true);
}

// Operations
module outer_ring_raw() {
  difference() {
    outer_ring_outer_cyl();
    outer_ring_inner_bore_cyl();
  }
}

module inner_ring_raw() {
  difference() {
    inner_ring_outer_cyl();
    inner_ring_bore_cyl();
  }
}

module outer_race_groove_scaled() {
  scale([1, 1, groove_depth/groove_radius])
    outer_race_groove_torus();
}

module inner_race_groove_scaled() {
  scale([1, 1, groove_depth/groove_radius])
    inner_race_groove_torus();
}

module outer_ring() {
  difference() {
    outer_ring_raw();
    outer_race_groove_scaled();
  }
}

module inner_ring() {
  difference() {
    inner_ring_raw();
    inner_race_groove_scaled();
  }
}

module raceway_grooves() {
  union() {
    outer_race_groove_scaled();
    inner_race_groove_scaled();
  }
}

module ball_set() {
  union() {
    for (i = [0:ball_count-1]) {
      ball(360/ball_count*i);
    }
  }
}

module cage_ring() {
  difference() {
    cage_outer_cyl();
    cage_inner_cyl();
  }
}

module cage() {
  union() {
    cage_ring();
    ball_set();
  }
}

module shield_top() {
  difference() {
    shield_top_disk();
    shield_top_hole();
  }
}

module shield_bottom() {
  difference() {
    shield_bottom_disk();
    shield_bottom_hole();
  }
}

module shields_or_seals() {
  union() {
    shield_top();
    shield_bottom();
  }
}

module bearing_core() {
  union() {
    outer_ring();
    inner_ring();
    cage();
    shields_or_seals();
  }
}

// Final Output
bearing_core();