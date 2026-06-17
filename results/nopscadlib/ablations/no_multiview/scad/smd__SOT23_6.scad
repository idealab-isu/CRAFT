// Parameters
body_length = 3.0; //[1.5:6.0:0.05]
body_width = 1.6; //[0.8:3.2:0.05]
body_height = 1.05; //[0.5:2.1:0.05]
endcap_length = 0.35; //[0.15:0.8:0.01]
endcap_thickness = 0.05; //[0.02:0.15:0.01]
endcap_height = 0.9; //[0.4:1.5:0.05]
marking_thickness = 0.03; //[0.01:0.1:0.01]
marking_length = 1.2; //[0.4:2.4:0.05]
marking_width = 0.5; //[0.2:1.2:0.05]
fillet_radius = 0.12; //[0.05:0.3:0.01]
polarity_diameter = 0.35; //[0.15:0.7:0.01]
polarity_height = 0.03; //[0.01:0.1:0.01]
overlap = 0.02; //[0.01:0.2:0.01]

// Base shapes
module smd_body_core() {
  cube([body_length - 2*fillet_radius, body_width - 2*fillet_radius, body_height - 2*fillet_radius], center=true);
}

module body_edge_fillet_sphere() {
  sphere(r=fillet_radius);
}

module endcap_left() {
  translate([-(body_length/2) + (endcap_length + endcap_thickness + overlap)/2, 0, 0])
    cube([endcap_length + endcap_thickness + overlap, body_width, endcap_height], center=true);
}

module endcap_right() {
  translate([(body_length/2) - (endcap_length + endcap_thickness + overlap)/2, 0, 0])
    cube([endcap_length + endcap_thickness + overlap, body_width, endcap_height], center=true);
}

module top_marking() {
  translate([0, 0, body_height/2 + marking_thickness/2 - overlap])
    cube([marking_length, marking_width, marking_thickness], center=true);
}

module polarity_indicator() {
  translate([-(body_length/2) + endcap_length + polarity_diameter/2, (body_width/2) - polarity_diameter/2, body_height/2 + polarity_height/2 - overlap])
    cylinder(h=polarity_height, r=polarity_diameter/2, center=true);
}

// Operations
module smd_body() {
  minkowski() {
    smd_body_core();
    body_edge_fillet_sphere();
  }
}

module terminal_endcaps() {
  union() {
    endcap_left();
    endcap_right();
  }
}

module smd_complete_model() {
  union() {
    smd_body();
    terminal_endcaps();
    top_marking();
    polarity_indicator();
  }
}

// Final output
smd_complete_model();