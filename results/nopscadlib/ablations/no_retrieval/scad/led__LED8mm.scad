// Parameters
body_diameter = 8.0; //[4.0:16.0:0.1]
body_height = 9.2; //[4.6:18.4:0.1]
lead_diameter = 0.6; //[0.3:1.2:0.05]
lead_length_below_body = 25.0; //[12.5:50.0:0.5]
lead_pitch = 2.54; //[1.27:5.08:0.01]
lens_dome_height = 2.0; //[1.0:4.0:0.1]
base_flange_height = 1.0; //[0.5:2.0:0.1]
lead_straight_length_before_bend = 3.0; //[1.0:8.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
cathode_flat_depth = 0.8; //[0.4:1.6:0.05]
internal_post_radius = 0.8; //[0.4:1.6:0.05]
internal_post_height = 5.0; //[2.5:10.0:0.1]
marking_bump_radius = 0.4; //[0.2:1.0:0.05]

// LED Body with Dome
module led_body_with_dome() {
  union() {
    // Main cylindrical body
    translate([0, 0, body_height/2])
      cylinder(r=body_diameter/2, h=body_height, center=true);

    // Lens dome
    intersection() {
      translate([0, 0, body_height + lens_dome_height - body_diameter/2])
        sphere(r=body_diameter/2, center=true);
      translate([0, 0, body_height + lens_dome_height + body_diameter/2])
        cube([body_diameter*2, body_diameter*2, body_diameter*2], center=true);
    }

    // Meniscus at base
    intersection() {
      translate([0, 0, base_flange_height/2])
        rotate_extrude() translate([body_diameter/2, 0, 0]) circle(r=base_flange_height);
      translate([0, 0, base_flange_height/2])
        cube([body_diameter*3, body_diameter*3, base_flange_height], center=true);
    }
  }
}

// Cathode Flat
module cathode_flat() {
  difference() {
    led_body_with_dome();
    translate([body_diameter/2 - cathode_flat_depth/2, 0, (body_height + lens_dome_height)/2])
      cube([cathode_flat_depth, body_diameter*2, body_height + lens_dome_height + base_flange_height], center=true);
  }
}

// Leads
module leads() {
  union() {
    // Left lead
    translate([-lead_pitch/2, 0, (body_height - (lead_length_below_body + body_height - overlap))/2])
      cylinder(r=lead_diameter/2, h=lead_length_below_body + body_height - overlap, center=true);

    // Right lead
    translate([lead_pitch/2, 0, (body_height - (lead_length_below_body + body_height - overlap))/2])
      cylinder(r=lead_diameter/2, h=lead_length_below_body + body_height - overlap, center=true);

    // Bridge between leads
    translate([0, 0, lead_diameter/2])
      cube([lead_pitch + lead_diameter - overlap, lead_diameter, lead_diameter], center=true);
  }
}

// Internal Silhouettes
module internal_silhouettes() {
  union() {
    // Anvil post
    translate([-lead_pitch/2, 0, base_flange_height + internal_post_height/2])
      cylinder(r=internal_post_radius, h=internal_post_height, center=true);

    // Anvil plate
    translate([-lead_pitch/2, 0, base_flange_height + internal_post_height - body_diameter*0.075])
      cube([body_diameter*0.35, body_diameter*0.25, body_diameter*0.15], center=true);
  }
}

// Markings
module markings() {
  union() {
    // Marking bump
    translate([-(body_diameter/2 - marking_bump_radius), 0, base_flange_height + marking_bump_radius])
      sphere(r=marking_bump_radius, center=true);
  }
}

// Complete LED
module led_complete() {
  union() {
    cathode_flat();
    leads();
    internal_silhouettes();
    markings();
  }
}

// Render the complete LED
led_complete();