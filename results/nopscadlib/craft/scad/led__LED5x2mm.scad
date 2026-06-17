// Parameters
led_diameter   = 5;    //[2.5:10:0.1]
led_height     = 8;    //[4:16:0.1]
rim_thickness  = 1.2;  //[0.6:2.4:0.1]
rim_diameter   = 6;    //[3:12:0.1]
lead_length    = 5;    //[2.5:10:0.1]
lead_thickness = 0.6;  //[0.3:1.2:0.05]
lead_pitch     = 2.54; //[1.27:5.08:0.01]
right_angle    = 0;    //[0:12:0.1]
overlap        = 0.8;  //[0.5:2:0.1]

$fn = 64;

// LED - ONE connected solid
module led() {

  // Radii
  body_r = led_diameter/2;
  rim_r  = rim_diameter/2;

  // Z references (rim centered at z=0)
  rim_zc  = 0;
  rim_top = rim_zc + rim_thickness/2;
  rim_bot = rim_zc - rim_thickness/2;

  // Body sits above rim with overlap
  body_h  = led_height;
  body_zc = rim_top + body_h/2 - overlap;

  // Dome on top of body with overlap
  dome_r  = body_r;
  dome_zc = (body_zc + body_h/2) + dome_r - overlap;

  // Leads: ensure they actually intersect the rim (connectivity)
  // Put lead tops slightly ABOVE rim_bot so they overlap into rim volume.
  lead_h  = lead_length + overlap;
  lead_top_z = rim_bot + overlap;                 // inside rim by 'overlap'
  lead_zc = lead_top_z - lead_h/2;                // center from top

  // Optional right-angle bend at bottom of vertical lead, overlapping it
  bend_len = right_angle + overlap;
  bend_zc  = (lead_zc - lead_h/2) + lead_thickness/2 + overlap; // overlaps bottom of vertical
  bend_yc  = -(bend_len/2) + lead_thickness/2;                  // starts at y=0 and goes negative

  union() {
    // Plastic (kept as geometry; color doesn't affect export)
    union() {
      translate([0, 0, rim_zc])
        cylinder(r=rim_r, h=rim_thickness, center=true);

      translate([0, 0, body_zc])
        cylinder(r=body_r, h=body_h, center=true);

      translate([0, 0, dome_zc])
        sphere(r=dome_r);
    }

    // Leads (overlap into rim to make ONE connected solid)
    union() {
      translate([-lead_pitch/2, 0, lead_zc])
        cube([lead_thickness, lead_thickness, lead_h], center=true);

      translate([ lead_pitch/2, 0, lead_zc])
        cube([lead_thickness, lead_thickness, lead_h], center=true);

      if (right_angle > 0) {
        translate([-lead_pitch/2, bend_yc, bend_zc])
          cube([lead_thickness, bend_len, lead_thickness], center=true);

        translate([ lead_pitch/2, bend_yc, bend_zc])
          cube([lead_thickness, bend_len, lead_thickness], center=true);
      }
    }
  }
}

led();