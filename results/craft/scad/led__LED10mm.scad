// Parameters
led_diameter_mm = 10.0; //[5.0:20.0:0.1]
body_height_mm = 11.0; //[5.5:22.0:0.1]
through_hole = 1; //[0:1:1]
lead_count = 2; //[2:2:1]
lead_length_mm = 5.0; //[2.5:10.0:0.1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_thickness_mm = 0.6; //[0.3:1.2:0.05]
rim_thickness_mm = 1.2; //[0.6:2.4:0.05]
rim_diameter_mm = 11.5; //[10.0:23.0:0.1]
eps_mm = 0.2; //[0.05:0.5:0.01]

// Rendering
$fn = 96;

// Derived
led_r = led_diameter_mm/2;
rim_r = rim_diameter_mm/2;

// Lens/body proportions (param-driven by body_height_mm)
lens_h = min(led_r, body_height_mm * 0.55);   // domed portion height
cyl_h  = max(0, body_height_mm - lens_h);     // straight portion height

// Structural overlap: enforce 1–2mm overlap for guaranteed attachment
overlap = 1.2;

module LED10mm() {
  union() {

    // LED epoxy body (rim + cylinder + dome) as ONE connected solid
    color([0.85, 0.85, 0.8])
    union() {

      // Rim flange at base: z = 0 .. rim_thickness_mm
      translate([0, 0, rim_thickness_mm/2])
        cylinder(r=rim_r, h=rim_thickness_mm, center=true);

      // Cylindrical body: starts at rim top, overlaps into rim
      if (cyl_h > 0)
        translate([0, 0, rim_thickness_mm + cyl_h/2 - overlap/2])
          cylinder(r=led_r, h=cyl_h + overlap, center=true);

      // Domed lens: intersects the cylinder by 'overlap'
      dome_base_z = rim_thickness_mm + cyl_h - overlap;

      translate([0, 0, dome_base_z])
        intersection() {
          scale([1, 1, lens_h/led_r])
            translate([0, 0, led_r])
              sphere(r=led_r);

          translate([0, 0, (lens_h + 2)/2])
            cube([2*led_r + 4, 2*led_r + 4, lens_h + 2], center=true);
        }
    }

    // Leads (pins): MUST physically penetrate the underside of the rim by 'overlap'
    if (through_hole == 1)
      color("Silver")
      union() {
        lead_h  = lead_length_mm + overlap;                 // total lead solid height
        // Place lead so its TOP is at z = overlap (inside rim), guaranteeing intersection.
        // With center=true, top = lead_zc + lead_h/2 => set to overlap.
        lead_zc = overlap - lead_h/2;

        translate([-lead_pitch_mm/2, 0, lead_zc])
          cube([lead_thickness_mm, lead_thickness_mm, lead_h], center=true);

        translate([ lead_pitch_mm/2, 0, lead_zc])
          cube([lead_thickness_mm, lead_thickness_mm, lead_h], center=true);
      }
  }
}

// Assembly
LED10mm();