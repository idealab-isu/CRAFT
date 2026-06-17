// Parameters
height_mm = 70.2; //[35.1:140.4:0.1]
diameter_mm = 32.4; //[16.2:64.8:0.1]
body_diameter_mm = 32.4; //[16.2:64.8:0.1]
body_height_mm = 70.2; //[35.1:140.4:0.1]
positive_terminal_diameter_mm = 10; //[5:20:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.1]
negative_terminal_diameter_mm = 12; //[6:24:0.1]
negative_terminal_height_mm = 0.3; //[0.15:0.6:0.05]
edge_fillet_radius_mm = 0.5; //[0.25:1:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
endcap_height_mm = 0.5; //[0.25:1.5:0.05]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    union() {
      // Main cylindrical body
      translate([0, 0, 0])
        cylinder(h=body_height_mm, r=body_diameter_mm/2, center=true, $fn=64);

      // Positive terminal button
      translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - overlap_mm])
        cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);

      // Negative terminal contact
      translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + overlap_mm])
        cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true, $fn=32);

      // Positive endcap rounding
      translate([0, 0, body_height_mm/2 + endcap_height_mm/2 - overlap_mm])
        cylinder(h=endcap_height_mm, r=body_diameter_mm/2, center=true, $fn=64);

      // Negative endcap rounding
      translate([0, 0, -body_height_mm/2 - endcap_height_mm/2 + overlap_mm])
        cylinder(h=endcap_height_mm, r=body_diameter_mm/2, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();