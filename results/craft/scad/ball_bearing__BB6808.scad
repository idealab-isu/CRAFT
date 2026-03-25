// Parameters
bore_diameter_mm = 40; //[20:80:0.5]
outer_diameter_mm = 52; //[26:104:0.5]
width_mm = 7; //[3.5:14:0.1]
eps_mm = 0.6; //[0.2:2:0.1]
outer_ring_radial_thickness_mm = 2.2; //[1.2:4.4:0.1]
inner_ring_radial_thickness_mm = 2.2; //[1.2:4.4:0.1]
shield_thickness_mm = 0.6; //[0.3:1.5:0.1]
shield_radial_overlap_mm = 1.2; //[0.5:3:0.1]
ball_diameter_mm = 3.2; //[1.5:6.5:0.1]
ball_count = 8; //[6:14:1]

// Outer Ring
module outer_ring() {
  color("DimGray") difference() {
    cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
    cylinder(r=outer_diameter_mm/2 - outer_ring_radial_thickness_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Inner Ring
module inner_ring() {
  color("DimGray") difference() {
    cylinder(r=bore_diameter_mm/2 + inner_ring_radial_thickness_mm, h=width_mm, center=true);
    cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
  }
}

// Shield
module shield() {
  color("Silver") union() {
    difference() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2 - eps_mm/2])
        cylinder(r=outer_diameter_mm/2 - outer_ring_radial_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
      translate([0, 0, width_mm/2 - shield_thickness_mm/2 - eps_mm/2])
        cylinder(r=bore_diameter_mm/2 + inner_ring_radial_thickness_mm - shield_radial_overlap_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
    }
    difference() {
      translate([0, 0, -width_mm/2 + shield_thickness_mm/2 + eps_mm/2])
        cylinder(r=outer_diameter_mm/2 - outer_ring_radial_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
      translate([0, 0, -width_mm/2 + shield_thickness_mm/2 + eps_mm/2])
        cylinder(r=bore_diameter_mm/2 + inner_ring_radial_thickness_mm - shield_radial_overlap_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Bearing Ball
module bearing_ball() {
  color("Silver") {
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
        translate([(bore_diameter_mm/2 + inner_ring_radial_thickness_mm + (outer_diameter_mm/2 - outer_ring_radial_thickness_mm))/2, 0, 0])
        sphere(r=ball_diameter_mm/2, center=true);
    }
  }
}

// Ball Bearing Assembly
module ball_bearing() {
  union() {
    outer_ring();
    inner_ring();
    shield();
    bearing_ball();
  }
}

// Final Assembly
module assembly() {
  ball_bearing();
}

assembly();