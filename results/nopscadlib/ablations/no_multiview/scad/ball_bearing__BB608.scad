// Parameters
bore_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 22; //[11:44:0.1]
width_mm = 7; //[3.5:14:0.1]
radial_clearance_mm = 0.3; //[0.1:1:0.05]
outer_ring_radial_thickness_mm = 2.6; //[1.3:5.2:0.1]
inner_ring_radial_thickness_mm = 2.4; //[1.2:4.8:0.1]
shield_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_radial_overlap_mm = 0.8; //[0.3:2:0.05]
shield_axial_overlap_mm = 0.6; //[0.3:1.5:0.05]
ball_diameter_mm = 3.5; //[2:6:0.1]
ball_count = 7; //[5:12:1]
ball_overlap_mm = 0.8; //[0.3:2:0.05]
fill_annulus_extra_mm = 0.4; //[0.1:1.5:0.05]
connection_overlap_mm = 0.8; //[0.3:2:0.05]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer Ring
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - outer_ring_radial_thickness_mm, h=width_mm + 2*connection_overlap_mm, center=true);
    }
    // Inner Ring
    difference() {
      cylinder(r=bore_diameter_mm/2 + inner_ring_radial_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*connection_overlap_mm, center=true);
    }
    // Filled Annulus
    difference() {
      cylinder(r=outer_diameter_mm/2 - outer_ring_radial_thickness_mm + fill_annulus_extra_mm, h=width_mm - 2*shield_thickness_mm + 2*shield_axial_overlap_mm, center=true);
      cylinder(r=bore_diameter_mm/2 + inner_ring_radial_thickness_mm - fill_annulus_extra_mm, h=width_mm - 2*shield_thickness_mm + 2*shield_axial_overlap_mm + 2*connection_overlap_mm, center=true);
    }
    // Shields
    union() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2 - shield_axial_overlap_mm])
        difference() {
          cylinder(r=outer_diameter_mm/2 - outer_ring_radial_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
          cylinder(r=bore_diameter_mm/2 + inner_ring_radial_thickness_mm - shield_radial_overlap_mm, h=shield_thickness_mm + 2*connection_overlap_mm, center=true);
        }
      translate([0, 0, -(width_mm/2 - shield_thickness_mm/2 - shield_axial_overlap_mm)])
        difference() {
          cylinder(r=outer_diameter_mm/2 - outer_ring_radial_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
          cylinder(r=bore_diameter_mm/2 + inner_ring_radial_thickness_mm - shield_radial_overlap_mm, h=shield_thickness_mm + 2*connection_overlap_mm, center=true);
        }
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("DimGray") {
    sphere(r=ball_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count])
      translate([((bore_diameter_mm/2 + inner_ring_radial_thickness_mm) + (outer_diameter_mm/2 - outer_ring_radial_thickness_mm))/2, 0, 0])
        bearing_ball();
  }
}

assembly();