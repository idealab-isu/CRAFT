// Threaded heat-set insert (M3) — 5.8mm OD, 4.6mm long
// One connected solid with a visible through-hole and internal thread indication.

// Parameters
screw_nominal_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 5.8; //[2.9:11.6:0.1]
length_mm = 4.6; //[2.3:9.2:0.1]

lead_in_chamfer_height_mm = 0.4; //[0.2:0.8:0.05]
lead_in_chamfer_angle_deg = 45; //[20:70:1] // (kept for UI; geometry uses height)

outer_knurl_depth_mm = 0.25; //[0.1:0.5:0.01]
rib_count = 12; //[6:24:1]
rib_width_mm = 0.6; //[0.3:1.2:0.05]

stop_face_thickness_mm = 0.6; //[0.3:1.2:0.05]
stop_face_diameter_mm = 6.4; //[3.2:12.8:0.1]

internal_thread_minor_diameter_mm = 2.6; //[1.3:5.2:0.05]
thread_clearance_extra_mm = 0.15; //[0.05:0.4:0.01]

// Visual thread indication (not a true helical thread; creates visible internal grooves)
thread_pitch_mm = 0.5;          // approximate M3 pitch
thread_groove_depth_mm = 0.18;  // radial depth of grooves
thread_groove_width_mm = 0.35;  // axial width of each groove

overlap_mm = 0.8; //[0.5:2:0.1]

$fn = 128;

module threaded_insert() {
  // Derived
  body_r = outer_diameter_mm/2;
  stop_r = stop_face_diameter_mm/2;

  // Keep stop face within overall length (no extra length beyond 4.6mm)
  stop_t = min(stop_face_thickness_mm, length_mm);
  stop_z = length_mm/2 - stop_t/2; // flush with top end

  chamfer_h = min(lead_in_chamfer_height_mm, length_mm/2);
  chamfer_z = -length_mm/2 + chamfer_h/2; // flush with bottom end

  // Through-hole sized for M3 screw clearance (minor + extra)
  hole_r = internal_thread_minor_diameter_mm/2 + thread_clearance_extra_mm;

  // Ensure hole never exceeds body (prevents empty/invalid geometry)
  hole_r_safe = min(hole_r, body_r - 0.25);

  // Internal groove ring radius (slightly larger than hole to show "thread" features)
  groove_r = min(hole_r_safe + thread_groove_depth_mm, body_r - 0.05);

  // Knurl ribs: place so they protrude outward and overlap into body for connectivity
  rib_radial = outer_knurl_depth_mm;
  rib_overlap_into_body = min(0.15, rib_radial*0.6); // small guaranteed overlap
  rib_len_z = max(0.01, length_mm - chamfer_h);      // avoid negative
  rib_center_z = (-length_mm/2 + chamfer_h) + rib_len_z/2; // starts above chamfer

  difference() {
    union() {
      // Main body
      cylinder(r=body_r, h=length_mm, center=true);

      // Stop face (flange) at top, connected
      translate([0, 0, stop_z])
        cylinder(r=stop_r, h=stop_t, center=true);

      // Lead-in chamfer at bottom, connected
      // Use a proper chamfer: r2 reduced by chamfer height (clamped)
      translate([0, 0, chamfer_z])
        cylinder(r1=body_r, r2=max(0.01, body_r - chamfer_h), h=chamfer_h, center=true);

      // Knurl ribs (connected, protruding outward)
      for (i = [0:rib_count-1]) {
        rotate([0, 0, i*360/rib_count])
          // Inner face at body_r - rib_overlap_into_body, outer face at body_r + rib_radial - rib_overlap_into_body
          translate([body_r + (rib_radial/2 - rib_overlap_into_body), 0, rib_center_z])
            cube([rib_radial, rib_width_mm, rib_len_z], center=true);
      }
    }

    // Through-hole
    cylinder(r=hole_r_safe, h=length_mm + 2*overlap_mm, center=true);

    // Internal "thread" indication: stacked shallow grooves along Z
    // Subtract thin rings from the inside wall (kept strictly inside body)
    for (z = [-length_mm/2 + thread_pitch_mm/2 : thread_pitch_mm : length_mm/2 - thread_pitch_mm/2]) {
      translate([0, 0, z])
        difference() {
          cylinder(r=groove_r,     h=thread_groove_width_mm, center=true);
          cylinder(r=hole_r_safe,  h=thread_groove_width_mm + 2*overlap_mm, center=true);
        }
    }
  }
}

threaded_insert();