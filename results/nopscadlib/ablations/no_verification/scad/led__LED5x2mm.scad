// Parameters
led_type = 5; //[3:10:1]
lead = 5; //[3:15:1]
right_angle = 0; //[0:12:1]
eps = 0.8; //[0.2:2:0.1]
body_height = 8; //[5:16:1]
rim_thickness = 1.2; //[0.6:2.4:0.1]
rim_diameter_factor = 1.12; //[1.05:1.3:0.01]
lead_thickness = 0.6; //[0.3:1.2:0.1]
lead_pitch_factor = 0.5; //[0.35:0.7:0.01]
solder_end_length = 1.2; //[0.6:3:0.1]
bend_radius_factor = 1.2; //[0.8:2.0:0.1]

$fn = 64;

// Derived dimensions
body_r = led_type/2;
rim_r  = (led_type * rim_diameter_factor)/2;

lead_pitch = led_type * lead_pitch_factor;
lead_xL = -lead_pitch/2;
lead_xR =  lead_pitch/2;

// Keep everything in +Z so it doesn't get clipped by view/camera setups.
// Rim bottom at z=0, leads go downward from rim.
z_rim_center  = rim_thickness/2;
z_body_center = rim_thickness + body_height/2;

// Leads: top slightly overlaps into rim (at z=0..rim_thickness)
z_lead_center = -lead/2 + eps; // lead top at z=eps (overlaps into rim)

// Solder ends: overlap into lead bottoms
z_solder_center = (z_lead_center - lead/2) - solder_end_length/2 + eps;

// LED Body (cylinder + dome), connected to rim by overlap
module led_body() {
  union() {
    translate([0, 0, z_body_center])
      cylinder(r=body_r, h=body_height, center=true);

    // Dome: center at top of cylinder, overlaps by eps
    translate([0, 0, rim_thickness + body_height - body_r + eps])
      sphere(r=body_r);
  }
}

// LED Rim (flange), overlaps into body slightly
module led_rim() {
  translate([0, 0, z_rim_center])
    cylinder(r=rim_r, h=rim_thickness, center=true);
}

// LED Leads (rectangular pins), overlap into rim
module led_leads() {
  union() {
    translate([lead_xL, 0, z_lead_center])
      cube([lead_thickness, lead_thickness, lead], center=true);

    translate([lead_xR, 0, z_lead_center])
      cube([lead_thickness, lead_thickness, lead], center=true);
  }
}

// Solder Ends (thicker tips), overlap into lead bottoms
module solder_ends() {
  tip = lead_thickness * 1.2;
  union() {
    translate([lead_xL, 0, z_solder_center])
      cube([tip, tip, solder_end_length], center=true);

    translate([lead_xR, 0, z_solder_center])
      cube([tip, tip, solder_end_length], center=true);
  }
}

// LED Assembly - ONE connected solid (all parts overlap)
module led() {
  union() {
    led_rim();
    led_body();
    led_leads();
    solder_ends();
  }
}

led();