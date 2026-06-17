// Parameters
stator_diameter = 11.5; //[5.75:23:0.1]
stator_height = 9.5; //[4.75:19:0.1]
stator_inner_bore_diameter = 3; //[1.5:6:0.1]
housing_wall_thickness = 0.5; //[0.25:1:0.05]
housing_clearance_radial = 0.3; //[0.1:0.8:0.05]
endcap_thickness = 0.8; //[0.4:1.6:0.05]
shaft_diameter = 2; //[1:4:0.1]
overlap = 1.2; //[0.5:2:0.1]   // use 1-2mm to guarantee connections
buzzer_diameter = 6; //[3:12:0.1]
buzzer_height = 3; //[1.5:6:0.1]
buzzer_pin_diameter = 1.2; //[0.6:2.4:0.1]

// Derived dimensions
motor_outer_r = stator_diameter/2 + housing_clearance_radial + housing_wall_thickness;
motor_total_h = stator_height + 2*endcap_thickness;

// Side feature (mount/connector) - ensure it is ATTACHED (no gap) and pin is CONNECTED
module side_feature() {
  // Place the side cylinder so it intersects the motor can by 'overlap'
  // Motor outer surface at x = motor_outer_r
  // Side cylinder radius = buzzer_diameter/2
  // Center x = motor_outer_r + side_r - overlap  => intersection depth = overlap
  side_r = buzzer_diameter/2;
  side_h = buzzer_height;

  side_cx = motor_outer_r + side_r - overlap;

  // Pin: start inside the side cylinder by 'overlap' so it is fused
  pin_r = buzzer_pin_diameter/2;
  pin_h = buzzer_height; // keep original intent
  pin_cz = side_h/2 + pin_h/2 - overlap; // overlaps into side cylinder

  union() {
    // Side cylindrical body
    cylinder(r=side_r, h=side_h, center=true, $fn=32);

    // Thin pin/shaft on the side feature (connected via overlap)
    translate([0, 0, pin_cz])
      cylinder(r=pin_r, h=pin_h, center=true, $fn=16);
  }

  // Position the whole side feature relative to motor
  // (wrapped by caller translate)
}

// BLDC motor (missing part) - single connected solid (before bores are cut)
module bldc_motor_solid() {
  union() {
    // Stator core (solid)
    cylinder(r=stator_diameter/2, h=stator_height, center=true, $fn=64);

    // Motor housing can (ring)
    difference() {
      cylinder(r=motor_outer_r, h=motor_total_h, center=true, $fn=64);
      cylinder(r=stator_diameter/2 + housing_clearance_radial,
               h=motor_total_h + 2*overlap, center=true, $fn=64);
    }

    // Endcaps (slightly overlapping into can)
    translate([0, 0,  stator_height/2 + endcap_thickness/2 - overlap])
      cylinder(r=motor_outer_r, h=endcap_thickness, center=true, $fn=64);

    translate([0, 0, -(stator_height/2 + endcap_thickness/2 - overlap)])
      cylinder(r=motor_outer_r, h=endcap_thickness, center=true, $fn=64);

    // Side mount/connector feature (attached to motor body with overlap)
    translate([motor_outer_r + buzzer_diameter/2 - overlap, 0, 0])
      side_feature();
  }
}

// Final assembly: union into one solid, then cut bores (still one connected part)
module assembly() {
  difference() {
    union() {
      bldc_motor_solid();
    }

    // Central shaft bore (through full motor)
    cylinder(r=shaft_diameter/2,
             h=motor_total_h + 2*overlap, center=true, $fn=32);

    // Stator inner bore (through stator)
    cylinder(r=stator_inner_bore_diameter/2,
             h=stator_height + 2*overlap, center=true, $fn=32);
  }
}

assembly();