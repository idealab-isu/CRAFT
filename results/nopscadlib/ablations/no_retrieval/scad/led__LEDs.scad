// Parameters
body_diameter = 5.0; //[2.5:10.0:0.1]
body_height = 8.5; //[4.25:17.0:0.1]
lens_dome_height = 2.0; //[1.0:4.0:0.1]
base_flange_diameter = 5.6; //[2.8:11.2:0.1]
base_flange_thickness = 1.0; //[0.5:2.0:0.1]
lead_diameter = 0.6; //[0.3:1.2:0.05]
lead_length = 25.0; //[12.5:50.0:0.5]
lead_spacing = 2.54; //[1.27:5.08:0.01]
overlap = 0.8; //[0.5:2.0:0.1]
flat_key_depth = 0.6; //[0.3:1.2:0.05]
internal_electrode_radius = 0.7; //[0.35:1.4:0.05]
internal_electrode_height = 3.0; //[1.5:6.0:0.1]
lead_bend_height = 2.0; //[1.0:6.0:0.1]
lead_bend_offset = 0.6; //[0.3:2.0:0.05]

// LED Body
module led_body() {
  translate([0, 0, base_flange_thickness + body_height/2 - overlap])
    cylinder(r=body_diameter/2, h=body_height, center=true);
}

// Base Flange
module base_flange() {
  translate([0, 0, base_flange_thickness/2])
    cylinder(r=base_flange_diameter/2, h=base_flange_thickness, center=true);
}

// Lens Dome
module lens_dome() {
  translate([0, 0, base_flange_thickness + body_height - overlap + (body_diameter/2 - lens_dome_height)])
    sphere(r=body_diameter/2, center=true);
}

// Flat Side Key
module flat_side_key() {
  translate([body_diameter/2 - flat_key_depth + body_diameter/2, 0, base_flange_thickness + (body_height + lens_dome_height)/2])
    cube([body_diameter, body_diameter, body_height + base_flange_thickness + lens_dome_height + body_diameter], center=true);
}

// Lead Anode
module lead_anode() {
  translate([lead_spacing/2, 0, -(lead_length + overlap)/2])
    cylinder(r=lead_diameter/2, h=lead_length + overlap, center=true);
}

// Lead Cathode
module lead_cathode() {
  translate([-lead_spacing/2, 0, -(lead_length + overlap)/2])
    cylinder(r=lead_diameter/2, h=lead_length + overlap, center=true);
}

// Lead Bend
module lead_bend() {
  translate([lead_bend_offset, 0, base_flange_thickness/2 - (lead_bend_height + overlap)/2])
    cube([lead_spacing + lead_diameter + 2*overlap, lead_diameter, lead_bend_height + overlap], center=true);
}

// Internal Electrode Detail
module internal_electrode_detail() {
  translate([0, 0, base_flange_thickness + internal_electrode_height/2])
    cylinder(r=internal_electrode_radius, h=internal_electrode_height, center=true);
}

// Markings Text (Placeholder)
module markings_text() {
  translate([0, 0, base_flange_thickness/2])
    cube([overlap, overlap, overlap], center=true);
}

// Complete LED
module led_complete() {
  difference() {
    union() {
      color([0.85, 0.85, 0.8]) led_body();
      color([0.85, 0.85, 0.8]) base_flange();
      color([0.85, 0.85, 0.8]) lens_dome();
      color([0.4, 0.4, 0.43]) lead_anode();
      color([0.4, 0.4, 0.43]) lead_cathode();
      color([0.4, 0.4, 0.43]) lead_bend();
      color([0.72, 0.45, 0.2]) internal_electrode_detail();
      color([0.2, 0.2, 0.2]) markings_text();
    }
    flat_side_key();
  }
}

// Render the complete LED
led_complete();