// Brushless DC motor (BLDC) with recognizable features
// Target: stator diameter = 17.75mm, stator height = 14.5mm
// Output: ONE connected solid (union only; no floating parts)

$fn = 128;

// -------------------- Parameters --------------------
stator_diameter_mm = 17.75; //[8.875:35.5:0.05]
stator_height_mm   = 14.5;  //[7.25:29:0.05]

overlap_mm = 0.6;           //[0.2:2:0.1]

// Housing / can
housing_wall_mm = 1.2;      //[0.8:3:0.1]
endcap_thk_mm   = 1.0;      //[0.6:2.5:0.1]

// Rotor / airgap
airgap_mm = 0.35;           //[0.2:1.0:0.05]
rotor_shell_mm = 1.0;       //[0.6:2.0:0.1]

// Shaft
shaft_diameter_mm = 3;      //[1:8:0.1]
shaft_front_len_factor = 0.55; //[0.2:1.2:0.05]
shaft_back_len_factor  = 0.25; //[0.1:0.8:0.05]

// Mounting bosses (rear)
mount_boss_d_mm = 3.2;      //[2:6:0.1]
mount_boss_h_mm = 1.2;      //[0.6:3:0.1]
mount_bolt_circle_factor = 0.72; //[0.5:0.9:0.02]
mount_count = 4;            //[3:6:1]

// Stator teeth
stator_tooth_count = 12;    //[9:18:1]
stator_tooth_depth_mm = 1.6;//[0.8:3:0.1]
stator_tooth_w_mm = 2.0;    //[1.0:3.5:0.1]

// Outer bell ribs
bell_rib_count = 6;         //[3:12:1]
bell_rib_w_mm = 1.2;        //[0.6:2.5:0.1]
bell_rib_depth_mm = 0.8;    //[0.3:2.0:0.1]

// Wiring grommet + leads (adds non-symmetric side detail so L/R views differ)
wire_grommet_d_factor = 0.22;   //[0.12:0.35:0.01]
wire_grommet_len_factor = 0.55; //[0.25:0.9:0.05]
wire_lead_d_mm = 1.0;           //[0.6:1.8:0.1]
wire_lead_len_factor = 1.2;     //[0.6:2.0:0.05]
wire_lead_count = 3;            //[2:5:1]
wire_lead_spread_deg = 18;      //[8:40:1]

// Optional top cap (kept connected)
buzzer_diameter_factor = 0.70; //[0.3:1.2:0.05]
buzzer_height_factor   = 0.28; //[0.1:0.8:0.05]
buzzer_pin_diameter_mm = 2;    //[1:4:0.1]
buzzer_pin_height_factor = 0.55;//[0.2:1.2:0.05]

// -------------------- Derived dimensions --------------------
stator_r = stator_diameter_mm/2;
stator_h = stator_height_mm;

housing_r = stator_r + housing_wall_mm;
housing_h = stator_h + 2*endcap_thk_mm;

rotor_outer_r = stator_r - airgap_mm;
rotor_inner_r = max(rotor_outer_r - rotor_shell_mm, shaft_diameter_mm/2 + 0.6);
rotor_h = stator_h * 0.92;

shaft_r = shaft_diameter_mm/2;
shaft_front_len = stator_h * shaft_front_len_factor;
shaft_back_len  = stator_h * shaft_back_len_factor;

mount_bolt_circle_r = housing_r * mount_bolt_circle_factor;

buzzer_r = (stator_diameter_mm * buzzer_diameter_factor)/2;
buzzer_h = stator_h * buzzer_height_factor;
buzzer_pin_h = buzzer_h * buzzer_pin_height_factor;

wire_grommet_r = housing_r * wire_grommet_d_factor;
wire_grommet_len = housing_r * wire_grommet_len_factor;
wire_lead_len = housing_r * wire_lead_len_factor;

// -------------------- Helpers --------------------
module radial_array(n) {
  for (i = [0:n-1]) rotate([0,0,i*360/n]) children();
}

// -------------------- BLDC motor (ONE connected solid) --------------------
module BLDC_motor_connected() {
  union() {

    // Outer housing can + ribs + endcap lips
    union() {
      cylinder(r=housing_r, h=housing_h, center=true);

      // Bell ribs (protrude outward, overlap into can)
      radial_array(bell_rib_count)
        translate([housing_r + bell_rib_depth_mm/2 - overlap_mm, 0, 0])
          cube([bell_rib_depth_mm, bell_rib_w_mm, housing_h*0.75], center=true);

      // Front endcap lip (small step)
      translate([0,0, housing_h/2 - endcap_thk_mm/2])
        cylinder(r=housing_r*0.92, h=endcap_thk_mm + overlap_mm, center=true);

      // Back endcap lip
      translate([0,0,-housing_h/2 + endcap_thk_mm/2])
        cylinder(r=housing_r*0.92, h=endcap_thk_mm + overlap_mm, center=true);
    }

    // Stator core + teeth (stator height exactly stator_h)
    union() {
      cylinder(r=stator_r, h=stator_h, center=true);

      // Teeth protruding inward from stator inner radius
      stator_inner_r = rotor_outer_r + airgap_mm; // nominal inner boundary near rotor
      tooth_len = stator_tooth_depth_mm;
      tooth_w   = stator_tooth_w_mm;

      radial_array(stator_tooth_count)
        translate([stator_inner_r - tooth_len/2 + overlap_mm, 0, 0])
          cube([tooth_len, tooth_w, stator_h*0.92], center=true);
    }

    // Rotor bell (solid for single-solid requirement) + hub + front face plate
    union() {
      cylinder(r=rotor_outer_r, h=rotor_h, center=true);

      hub_r = max(shaft_r + 0.8, rotor_inner_r*0.75);
      cylinder(r=hub_r, h=rotor_h*0.85, center=true);

      translate([0,0, rotor_h/2 - (endcap_thk_mm*0.6)/2])
        cylinder(r=rotor_outer_r*0.98, h=endcap_thk_mm*0.6 + overlap_mm, center=true);
    }

    // Shaft (front and back), connected through rotor/hub
    union() {
      // Through section (inside motor)
      cylinder(r=shaft_r, h=stator_h + 2*endcap_thk_mm + overlap_mm, center=true);

      // Front protrusion
      translate([0,0, (stator_h + 2*endcap_thk_mm)/2 + shaft_front_len/2 - overlap_mm])
        cylinder(r=shaft_r, h=shaft_front_len, center=true);

      // Back protrusion
      translate([0,0,-(stator_h + 2*endcap_thk_mm)/2 - shaft_back_len/2 + overlap_mm])
        cylinder(r=shaft_r, h=shaft_back_len, center=true);
    }

    // Mounting bosses on back face (connected to housing)
    radial_array(mount_count)
      translate([mount_bolt_circle_r, 0,
                 -housing_h/2 - mount_boss_h_mm/2 + overlap_mm])
        cylinder(r=mount_boss_d_mm/2, h=mount_boss_h_mm, center=true);

    // Side wiring grommet + leads (connected; breaks symmetry so side views differ)
    union() {
      // Grommet: a short cylinder sticking out radially from the can
      // Place so it overlaps into the housing by overlap_mm
      translate([housing_r + wire_grommet_len/2 - overlap_mm, 0, -housing_h*0.18])
        rotate([0,90,0])
          cylinder(r=wire_grommet_r, h=wire_grommet_len, center=true);

      // Leads: 3 small cylinders extending further out from grommet
      // Start at grommet outer face, overlap slightly into grommet
      for (k = [0:wire_lead_count-1]) {
        ang = (k - (wire_lead_count-1)/2) * (wire_lead_spread_deg / max(1, wire_lead_count-1));
        translate([housing_r + wire_grommet_len - overlap_mm + wire_lead_len/2 - overlap_mm, 0, -housing_h*0.18])
          rotate([0,90,ang])
            cylinder(r=wire_lead_d_mm/2, h=wire_lead_len, center=true);
      }
    }

    // Optional top cap (connected to front endcap)
    union() {
      translate([0,0, housing_h/2 + buzzer_h/2 - overlap_mm])
        cylinder(r=buzzer_r, h=buzzer_h, center=true);

      // Pin on top of cap (connected)
      translate([0,0, housing_h/2 + buzzer_h - overlap_mm + buzzer_pin_h/2 - overlap_mm])
        cylinder(r=buzzer_pin_diameter_mm/2, h=buzzer_pin_h, center=true);
    }
  }
}

BLDC_motor_connected();