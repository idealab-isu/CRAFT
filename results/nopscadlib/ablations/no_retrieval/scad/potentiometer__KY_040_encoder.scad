// Parameters
body_L = 12; //[6:24:0.5]
body_W = 12; //[6:24:0.5]
body_H = 6.5; //[3.25:13:0.25]
wall_t = 1.0; //[0.5:2.0:0.1]
adjuster_d = 4.0; //[2.0:8.0:0.25]
adjuster_depth = 1.5; //[0.75:3.0:0.1]
pin_d = 0.8; //[0.4:1.6:0.05]
pin_len = 3.5; //[1.75:7.0:0.25]
pin_spacing = 5.0; //[2.5:10.0:0.25]
pin_row_y = 0.0; //[-3.0:3.0:0.25]
mark_w = 2.0; //[1.0:4.0:0.25]
mark_h = 1.0; //[0.5:2.0:0.1]
mark_t = 0.4; //[0.2:1.0:0.05]
fillet_r = 0.6; //[0.3:1.2:0.05]
overlap = 0.8; //[0.5:2.0:0.1]

// Main body with corner fillets
module main_body() {
  color([0.0, 0.4, 0.2]) // PCB green
  minkowski() {
    translate([0, 0, 0])
      cube([body_L - 2*fillet_r, body_W - 2*fillet_r, body_H - 2*fillet_r], center=true);
    sphere(r=fillet_r);
  }
}

// Top adjuster recess
module top_adjuster_recess() {
  translate([0, 0, body_H/2 - adjuster_depth/2])
    cylinder(r=adjuster_d/2, h=adjuster_depth + overlap, center=true);
}

// Mounting pins
module mounting_pins() {
  color("Silver")
  union() {
    translate([0, pin_row_y, -body_H/2 - pin_len/2 + overlap/2])
      cylinder(r=pin_d/2, h=pin_len + overlap, center=true);
    translate([-pin_spacing/2, pin_row_y, -body_H/2 - pin_len/2 + overlap/2])
      cylinder(r=pin_d/2, h=pin_len + overlap, center=true);
    translate([pin_spacing/2, pin_row_y, -body_H/2 - pin_len/2 + overlap/2])
      cylinder(r=pin_d/2, h=pin_len + overlap, center=true);
  }
}

// Side marking
module side_markings() {
  color("DimGray")
  translate([0, body_W/2 + mark_t/2 - overlap, 0])
    cube([mark_w, mark_t, mark_h], center=true);
}

// Complete model
module complete_model() {
  difference() {
    main_body();
    top_adjuster_recess();
  }
  mounting_pins();
  side_markings();
}

// Render the complete model
complete_model();