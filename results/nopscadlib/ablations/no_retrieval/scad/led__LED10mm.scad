$fn = 96;

// Parameters
body_diameter = 10.0; //[5.0:20.0:0.1]
body_height   = 11.0; //[6.0:22.0:0.1]   // total lens height above flange top
dome_height   = 3.0;  //[1.5:6.0:0.1]    // spherical cap height
flange_diameter   = 10.6; //[6.0:22.0:0.1]
flange_thickness  = 1.0;  //[0.5:2.5:0.1]
lead_diameter = 0.6;  //[0.3:1.2:0.05]
lead_length   = 25.0; //[12.0:50.0:0.5]
lead_pitch    = 2.54; //[1.27:5.08:0.01]
lead_standoff = 1.0;  //[0.0:3.0:0.1]
overlap       = 0.8;  //[0.3:2.0:0.1]
flat_depth    = 0.6;  //[0.2:1.5:0.05]
polarity_mark_depth = 0.3; //[0.1:1.0:0.05]
die_stub_radius = 1.0; //[0.5:2.5:0.1]
die_stub_height = 1.2; //[0.5:3.0:0.1]

// Derived
r_body = body_diameter/2;
r_flange = flange_diameter/2;

cyl_h = body_height - dome_height;                 // cylindrical lens section height
z_flange_center = flange_thickness/2;
z_flange_top = flange_thickness;

z_cyl_center = z_flange_top + cyl_h/2;
z_cyl_top = z_flange_top + cyl_h;

// Spherical cap: sphere radius = r_body, cap height = dome_height
// Sphere center is below cap top by r_body, so:
z_dome_top = z_flange_top + body_height;
z_sphere_center = z_dome_top - r_body;

// Leads: start at flange bottom (z=0) and extend downward
lead_total_h = lead_length + lead_standoff;
z_lead_center = -(lead_total_h/2) + overlap/2;     // slight overlap into flange

// LED Body (cylindrical part)
module led_body() {
  translate([0, 0, z_cyl_center])
    cylinder(h=cyl_h, r=r_body, center=true);
}

// LED Dome (spherical cap clipped to dome_height)
module led_dome() {
  intersection() {
    translate([0, 0, z_sphere_center])
      sphere(r=r_body);
    // Keep only the top dome_height above z_cyl_top
    translate([0, 0, z_cyl_top + dome_height/2])
      cylinder(h=dome_height + overlap, r=r_body + 0.01, center=true);
  }
}

// Body Flange
module body_flange() {
  translate([0, 0, z_flange_center])
    cylinder(h=flange_thickness, r=r_flange, center=true);
}

// Lead (generic)
module lead_at(xpos) {
  translate([xpos, 0, z_lead_center])
    cylinder(h=lead_total_h + overlap, r=lead_diameter/2, center=true);
}

// Lead Bend Relief (connects leads to flange underside)
module lead_bend_relief() {
  // A thin block under the flange that overlaps both leads and flange
  relief_h = lead_standoff + overlap;
  translate([0, 0, -(relief_h/2) + overlap/2])
    cube([flange_diameter, lead_pitch + lead_diameter*3, relief_h], center=true);
}

// Internal Die Stub (inside lens, connected to flange)
module internal_die_stub() {
  translate([0, 0, z_flange_top + die_stub_height/2 - overlap/2])
    cylinder(h=die_stub_height + overlap, r=die_stub_radius, center=true);
}

// Lens Flat Spot (subtract)
module lens_flat_spot() {
  // Cut a flat along +X side through the lens (not the flange)
  translate([r_body - flat_depth/2, 0, z_flange_top + body_height/2])
    cube([flat_depth + overlap, body_diameter + 2*overlap, body_height + 2*overlap], center=true);
}

// Polarity Marking (subtract small notch on -X side near lower lens)
module polarity_marking() {
  mark_h = cyl_h * 0.6;
  translate([-(r_body - polarity_mark_depth/2), 0, z_flange_top + mark_h/2])
    cube([polarity_mark_depth + overlap, body_diameter/3, mark_h + overlap], center=true);
}

// Final LED Model (one connected solid)
module led_model() {
  difference() {
    union() {
      // Lens + flange
      union() {
        body_flange();
        led_body();
        led_dome();
      }

      // Leads (connected via overlap into flange/relief)
      lead_at( lead_pitch/2);
      lead_at(-lead_pitch/2);
      lead_bend_relief();

      // Internal feature (connected)
      internal_die_stub();
    }

    // Subtractive details
    lens_flat_spot();
    polarity_marking();
  }
}

// Render the LED
color([0.85, 0.85, 0.8])
led_model();