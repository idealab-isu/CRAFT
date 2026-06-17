// Toggle switch (single connected solid)
// Target: 12.6mm body diameter, 13.1mm body height

// Parameters
body_diameter_mm = 12.6; //[6.3:25.2:0.1]
body_height_mm   = 13.1; //[6.55:26.2:0.1]

include_toggle_lever = 1; //[0:1:1]
include_terminals    = 1; //[0:1:1]

collar_diameter_mm   = 14.0; //[7.0:28.0:0.1]
collar_thickness_mm  = 2.0;  //[1.0:4.0:0.1]

// Threaded bushing (visual only; not modeled as real threads)
bushing_diameter_mm  = 6.0;  //[3.0:12.0:0.1]
bushing_height_mm    = 6.0;  //[2.0:12.0:0.1]

// Lever
lever_shaft_diameter_mm = 3.0;  //[1.5:6.0:0.1]
lever_shaft_length_mm   = 12.0; //[6.0:24.0:0.5]
lever_tip_diameter_mm   = 5.0;  //[2.5:10.0:0.1]
lever_tip_height_mm     = 6.0;  //[3.0:12.0:0.5]
lever_tilt_deg          = 15;   //[0:30:1]

// Terminals (simple lugs)
terminal_count          = 3;    //[2:3:1]
terminal_w_mm           = 2.2;  //[1.0:4.0:0.1]
terminal_t_mm           = 0.8;  //[0.4:2.0:0.1]
terminal_l_mm           = 5.0;  //[2.0:10.0:0.1]
terminal_drop_mm        = 4.0;  //[1.0:10.0:0.1]
terminal_spacing_mm     = 4.0;  //[2.0:8.0:0.1]

// Panel reference plane (kept small so it doesn't dominate views)
panel_plane_size_mm      = 22.0; //[10.0:60.0:1]
panel_plane_thickness_mm = 1.0;  //[0.5:3.0:0.1]

$fn = 96;

// Small overlap to guarantee manifold connectivity
overlap_mm = 0.25;

// Derived
body_r    = body_diameter_mm/2;
collar_r  = collar_diameter_mm/2;
bushing_r = bushing_diameter_mm/2;
shaft_r   = lever_shaft_diameter_mm/2;
tip_r     = lever_tip_diameter_mm/2;

// Toggle Lever - connected to bushing top
module toggle_lever() {
  if (include_toggle_lever == 1) {
    // Place lever so its base slightly penetrates bushing for guaranteed union
    z0 = body_height_mm + collar_thickness_mm + bushing_height_mm - overlap_mm;

    rotate([lever_tilt_deg, 0, 0])
    union() {
      // Shaft
      translate([0, 0, z0])
        cylinder(r=shaft_r, h=lever_shaft_length_mm + overlap_mm);

      // Tip
      translate([0, 0, z0 + lever_shaft_length_mm - overlap_mm])
        cylinder(r=tip_r, h=lever_tip_height_mm + overlap_mm);
    }
  }
}

// Terminals - connected to body bottom
module terminals() {
  if (include_terminals == 1) {
    // Start slightly inside body to ensure connection
    z_top = overlap_mm; // inside body (body base at z=0)
    z_center = z_top - terminal_drop_mm/2;

    // Radial placement just outside body, with overlap into body wall
    x_attach = body_r - overlap_mm + terminal_t_mm/2;

    union() {
      if (terminal_count == 2) {
        for (s = [-1, 1]) {
          translate([0, s*terminal_spacing_mm/2, z_center])
            translate([x_attach, 0, 0])
              cube([terminal_t_mm, terminal_w_mm, terminal_drop_mm + overlap_mm], center=true);

          // outward lug
          translate([0, s*terminal_spacing_mm/2, z_center - (terminal_drop_mm/2 - terminal_t_mm/2)])
            translate([x_attach + terminal_l_mm/2 - overlap_mm, 0, 0])
              cube([terminal_l_mm + overlap_mm, terminal_w_mm, terminal_t_mm], center=true);
        }
      } else { // 3 terminals
        for (i = [-1, 0, 1]) {
          translate([0, i*terminal_spacing_mm, z_center])
            translate([x_attach, 0, 0])
              cube([terminal_t_mm, terminal_w_mm, terminal_drop_mm + overlap_mm], center=true);

          translate([0, i*terminal_spacing_mm, z_center - (terminal_drop_mm/2 - terminal_t_mm/2)])
            translate([x_attach + terminal_l_mm/2 - overlap_mm, 0, 0])
              cube([terminal_l_mm + overlap_mm, terminal_w_mm, terminal_t_mm], center=true);
        }
      }
    }
  }
}

// Assembly - ONE connected solid
module assembly() {
  union() {
    // Switch body (base at z=0)
    cylinder(r=body_r, h=body_height_mm);

    // Collar: overlaps into body
    translate([0, 0, body_height_mm - overlap_mm])
      cylinder(r=collar_r, h=collar_thickness_mm + overlap_mm);

    // Threaded bushing: overlaps into collar
    translate([0, 0, body_height_mm + collar_thickness_mm - overlap_mm])
      cylinder(r=bushing_r, h=bushing_height_mm + overlap_mm);

    // Panel reference plane: fused to collar top (kept small)
    translate([0, 0, body_height_mm + collar_thickness_mm - panel_plane_thickness_mm/2 - overlap_mm])
      cube([panel_plane_size_mm, panel_plane_size_mm, panel_plane_thickness_mm], center=true);

    // Terminals
    terminals();

    // Optional lever
    toggle_lever();
  }
}

assembly();