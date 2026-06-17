// Parameters
body_diameter = 5.0; //[2.5:10.0:0.1]
body_height = 8.5; //[4.25:17.0:0.1]
base_thickness = 1.2; //[0.6:2.4:0.1]
base_diameter_factor = 1.08; //[1.02:1.2:0.01]
dome_height = 2.0; //[1.0:4.0:0.1]
lead_diameter = 0.5; //[0.25:1.0:0.05]
lead_spacing = 2.54; //[1.27:5.08:0.01]
lead_length = 25.0; //[12.5:50.0:0.5]
lead_length_delta = 2.0; //[0.0:6.0:0.1]
lead_bend_start = 3.0; //[1.0:8.0:0.1]
lead_bend_offset = 0.6; //[0.0:2.0:0.05]
overlap = 0.8; //[0.2:2.0:0.1]
flat_side_depth = 0.6; //[0.2:1.5:0.05]
flat_side_width_factor = 0.55; //[0.3:0.8:0.01]
internal_die_size_factor = 0.22; //[0.1:0.4:0.01]
internal_die_height = 0.8; //[0.3:2.0:0.1]
lead_tip_chamfer_height = 0.8; //[0.2:2.0:0.1]

// LED Body
module led_body() {
  color([0.85, 0.85, 0.8]) // Off-white for LED lens
  union() {
    translate([0, 0, base_thickness + body_height/2])
      cylinder(r=body_diameter/2, h=body_height, center=true);
    translate([0, 0, base_thickness + body_height + (body_diameter/2 - dome_height)])
      sphere(r=body_diameter/2, center=true);
  }
}

// LED Base
module led_base() {
  color([0.85, 0.85, 0.8]) // Off-white for LED base
  translate([0, 0, base_thickness/2])
    cylinder(r=(body_diameter*base_diameter_factor)/2, h=base_thickness, center=true);
}

// Flat Side on Body
module flat_side_on_body() {
  translate([body_diameter/2 - flat_side_depth/2, 0, (base_thickness + body_height + dome_height)/2])
    cube([flat_side_depth + overlap, body_diameter*flat_side_width_factor, body_height + dome_height + base_thickness], center=true);
}

// Leads
module leads() {
  color("Silver") // Silver for metal leads
  union() {
    translate([-lead_spacing/2, 0, -(lead_length/2) + overlap/2])
      cylinder(r=lead_diameter/2, h=lead_length + overlap, center=true);
    translate([lead_spacing/2, 0, -((lead_length - lead_length_delta)/2) + overlap/2])
      cylinder(r=lead_diameter/2, h=lead_length - lead_length_delta + overlap, center=true);
    translate([-lead_spacing/2 + lead_bend_offset, 0, -lead_bend_start/2 + overlap/2])
      cube([lead_diameter + overlap, lead_diameter + overlap, lead_bend_start + overlap], center=true);
    translate([-lead_spacing/2, 0, -lead_length + lead_length_delta/2 + overlap/2])
      cube([lead_diameter + overlap, lead_diameter + overlap, lead_length_delta + overlap], center=true);
    translate([-lead_spacing/2, 0, -lead_length - lead_tip_chamfer_height/2 + overlap])
      rotate([180, 0, 0])
      cylinder(r1=lead_diameter/2, r2=0, h=lead_tip_chamfer_height, center=true);
    translate([lead_spacing/2, 0, -(lead_length - lead_length_delta) - lead_tip_chamfer_height/2 + overlap])
      rotate([180, 0, 0])
      cylinder(r1=lead_diameter/2, r2=0, h=lead_tip_chamfer_height, center=true);
  }
}

// Internal Die Hint
module internal_die_hint() {
  color("Black") // Black for internal die
  translate([0, 0, base_thickness + internal_die_height/2 + overlap])
    cube([body_diameter*internal_die_size_factor, body_diameter*internal_die_size_factor, internal_die_height], center=true);
}

// LED Complete Model
module led_complete_model() {
  union() {
    difference() {
      union() {
        led_base();
        led_body();
      }
      flat_side_on_body();
    }
    leads();
    internal_die_hint();
  }
}

// Render the complete LED model
led_complete_model();