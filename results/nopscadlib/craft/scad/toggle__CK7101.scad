// Toggle switch (stylized) - ONE connected solid
// Requested: 6.86mm body diameter, 12.7mm tall (body only)

// Parameters
body_diameter_mm = 6.86; //[3.43:13.72:0.01]
body_height_mm   = 12.7; //[6.35:25.4:0.01]
centered = 1;            //[0:1:1]

include_toggle_lever = 1; //[0:1:1]
include_terminals    = 1; //[0:1:1]

eps_mm = 0.8; //[0.2:2:0.1]

// Detail parameters (kept proportional; do not change body dims)
face_thickness_mm = 0.6; //[0.3:1.2:0.1]

// Lever
toggle_lever_diameter_mm = 2.5; //[1.2:5:0.1]
toggle_lever_height_mm   = 10;  //[5:20:0.5]
lever_tip_d_mm           = 3.2; // knob at end

// Mounting bushing + hex nut (stylized)
bushing_d_mm = 4.2;
bushing_h_mm = 2.2;
nut_flat_mm  = 6.2;  // across flats
nut_h_mm     = 1.6;

// Terminals (3 lugs)
terminal_w_mm = 1.2;
terminal_t_mm = 0.6;
terminal_h_mm = 3.0;
terminal_pitch_mm = 2.54;

// Resolution
$fn = 96;

function z0() = centered ? 0 : body_height_mm/2; // body centered or sitting on Z=0
function body_top_z() = z0() + body_height_mm/2;
function body_bot_z() = z0() - body_height_mm/2;

module hex_prism(af, h, center=true) {
  // Regular hex with across-flats = af
  r = af / sqrt(3); // circumradius
  cylinder(h=h, r=r, center=center, $fn=6);
}

module toggle_switch() {
  body_r = body_diameter_mm/2;

  // Robust overlap to guarantee manifold connectivity
  overlap = max(0.25, eps_mm/2);

  union() {
    // Main body (exact requested dimensions)
    translate([0,0,z0()])
      cylinder(h=body_height_mm, r=body_r, center=true);

    // Face rings: make them slightly larger so they are visible and still connected
    ring_r = body_r + 0.15;
    translate([0,0, body_top_z() - face_thickness_mm/2 + overlap/2])
      cylinder(h=face_thickness_mm + overlap, r=ring_r, center=true);
    translate([0,0, body_bot_z() + face_thickness_mm/2 - overlap/2])
      cylinder(h=face_thickness_mm + overlap, r=ring_r, center=true);

    // Mounting bushing on top (connected)
    translate([0,0, body_top_z() + bushing_h_mm/2 - overlap])
      cylinder(h=bushing_h_mm, r=bushing_d_mm/2, center=true, $fn=64);

    // Hex nut on top of bushing (connected)
    translate([0,0, body_top_z() + bushing_h_mm + nut_h_mm/2 - 2*overlap])
      hex_prism(nut_flat_mm, nut_h_mm, center=true);

    // Toggle lever (connected)
    if (include_toggle_lever) {
      // Start lever inside bushing for guaranteed connection
      lever_base_z = body_top_z() + bushing_h_mm - overlap;

      translate([0,0, lever_base_z + toggle_lever_height_mm/2 - overlap])
        cylinder(h=toggle_lever_height_mm, r=toggle_lever_diameter_mm/2, center=true, $fn=48);

      // Tip knob (connected)
      translate([0,0, lever_base_z + toggle_lever_height_mm - overlap + lever_tip_d_mm/2 - overlap])
        sphere(d=lever_tip_d_mm, $fn=64);
    }

    // Terminals (3) on bottom (connected)
    if (include_terminals) {
      // Ensure terminal tops overlap into body by 'overlap'
      term_top_z    = body_bot_z() + overlap;
      term_center_z = term_top_z - terminal_h_mm/2;

      for (x = [-terminal_pitch_mm, 0, terminal_pitch_mm]) {
        translate([x, 0, term_center_z])
          cube([terminal_w_mm, terminal_t_mm, terminal_h_mm], center=true);
      }
    }
  }
}

toggle_switch();