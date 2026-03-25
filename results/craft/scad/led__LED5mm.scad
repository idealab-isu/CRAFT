// Standalone 5.0mm through-hole LED (5.9mm body height) - ONE connected solid

// Parameters
led_diameter_mm = 5;            //[2.5:10:0.1]
body_height_mm = 5.9;           //[3:12:0.1]
lead_count = 2;                 //[2:2:1]
lead_pitch_mm = 2.54;           //[1.5:5:0.01]
lead_length_mm = 25;            //[10:50:1]
lead_thickness_mm = 0.5;        //[0.3:1:0.05]
rim_thickness_mm = 1;           //[0.5:2:0.1]
rim_diameter_mm = 6;            //[5.2:12:0.1]
overlap_mm = 0.6;               //[0.2:2:0.1]
lens_round_radius_mm = 2.5;     //[1.25:5:0.1]

// Quality
$fn = 64;

// LED5mm - complete geometry (single connected solid)
module LED5mm() {

  // Z reference: bottom of rim flange at z=0
  rim_zc  = rim_thickness_mm/2;
  body_zc = rim_thickness_mm + body_height_mm/2 - overlap_mm/2;

  // Place dome so it overlaps into the cylinder (connected)
  dome_zc = (rim_thickness_mm + body_height_mm) - lens_round_radius_mm + overlap_mm/2;

  // Leads: start slightly inside rim to guarantee connection
  lead_zc = -(lead_length_mm/2) + overlap_mm/2;

  union() {
    // Rim flange
    translate([0, 0, rim_zc])
      cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true);

    // LED body (cylindrical)
    translate([0, 0, body_zc])
      cylinder(r=led_diameter_mm/2, h=body_height_mm, center=true);

    // Rounded lens top
    translate([0, 0, dome_zc])
      sphere(r=lens_round_radius_mm);

    // Leads (two rectangular pins)
    translate([-lead_pitch_mm/2, 0, lead_zc])
      cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);

    translate([ lead_pitch_mm/2, 0, lead_zc])
      cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
  }
}

LED5mm();