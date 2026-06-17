// 3.0mm THT LED, 3.15mm body height (single connected solid)

// Parameters
led_diameter_mm = 3;          //[1.5:6:0.1]
body_height_mm  = 3.15;       //[1.6:6.3:0.05]  // cylindrical body height (excluding dome)
lead_length_mm  = 5;          //[0:15:0.5]
lead_pitch_mm   = 2.54;       //[1.5:5:0.01]
lead_thickness_mm = 0.5;      //[0.3:1:0.05]
rim_thickness_mm  = 0.6;      //[0.3:1.2:0.05]
rim_diameter_mm   = 3.6;      //[3.1:7.2:0.05]
eps_mm = 0.2;                 //[0.05:0.5:0.05]

// Derived
body_r = led_diameter_mm/2;
rim_r  = rim_diameter_mm/2;

// Typical 3mm LED has a domed lens; approximate dome height as radius
dome_h = body_r;

// Z references (bottom of flange at z=0)
z_rim_center  = rim_thickness_mm/2;
z_body_center = rim_thickness_mm + body_height_mm/2;
z_body_top    = rim_thickness_mm + body_height_mm;

// Leads start at bottom of flange (z=0) and extend downward
lead_h = max(0, lead_length_mm);
z_lead_center = -lead_h/2 + eps_mm/2;

// LED Module (single connected solid)
module led_3mm_tht() {
  union() {
    // Flange (rim)
    cylinder(r=rim_r, h=rim_thickness_mm, center=false, $fn=64);

    // Cylindrical body (sits on top of flange)
    translate([0,0,rim_thickness_mm])
      cylinder(r=body_r, h=body_height_mm, center=false, $fn=64);

    // Domed lens (hemisphere-like cap) connected to body top
    translate([0,0,z_body_top])
      intersection() {
        sphere(r=body_r, $fn=64);
        // keep only upper half so it sits on the body top plane
        translate([0,0,body_r/2]) cube([2*body_r+2*eps_mm, 2*body_r+2*eps_mm, 2*body_r], center=true);
      }

    // Leads (rectangular for simplicity), slightly overlapping into flange for connectivity
    translate([-lead_pitch_mm/2, 0, z_lead_center])
      cube([lead_thickness_mm, lead_thickness_mm, lead_h + eps_mm], center=true);

    translate([ lead_pitch_mm/2, 0, z_lead_center])
      cube([lead_thickness_mm, lead_thickness_mm, lead_h + eps_mm], center=true);
  }
}

led_3mm_tht();