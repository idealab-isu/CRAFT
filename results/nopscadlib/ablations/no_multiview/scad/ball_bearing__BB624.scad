// Parameters
bore_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 13.0; //[6.5:26.0:0.1]
width_mm = 5.0; //[2.5:10.0:0.1]
flange_diameter_mm = 0.0; //[0.0:26.0:0.1]
flange_width_mm = 0.0; //[0.0:5.0:0.1]
eps_mm = 0.6; //[0.2:2.0:0.1]
outer_rim_radial_mm = 1.2; //[0.6:2.4:0.1]
inner_rim_radial_mm = 1.0; //[0.5:2.0:0.1]
annulus_clearance_mm = 0.3; //[0.1:0.8:0.05]
annulus_axial_margin_mm = 0.6; //[0.2:1.5:0.1]
ball_diameter_mm = 2.0; //[1.0:3.5:0.1]
ball_count = 8; //[6:12:1]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer Ring
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm, h=width_mm + 2*eps_mm, center=true);
    }
    // Inner Ring
    difference() {
      cylinder(r=bore_diameter_mm/2 + inner_rim_radial_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
    }
    // Annulus
    difference() {
      cylinder(r=(outer_diameter_mm/2 - outer_rim_radial_mm) - annulus_clearance_mm, h=width_mm - 2*annulus_axial_margin_mm, center=true);
      cylinder(r=(bore_diameter_mm/2 + inner_rim_radial_mm) + annulus_clearance_mm, h=(width_mm - 2*annulus_axial_margin_mm) + 2*eps_mm, center=true);
    }
    // Optional Flange
    if (flange_diameter_mm > 0 && flange_width_mm > 0) {
      difference() {
        translate([0, 0, width_mm/2 - flange_width_mm/2])
          cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true);
        translate([0, 0, width_mm/2 - flange_width_mm/2])
          cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm, h=flange_width_mm + 2*eps_mm, center=true);
      }
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("DimGray") {
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
        translate([((bore_diameter_mm/2 + inner_rim_radial_mm) + (outer_diameter_mm/2 - outer_rim_radial_mm))/2, 0, 0])
          sphere(r=ball_diameter_mm/2);
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();