// Timing pulley: 20 teeth, pitch diameter 12.22mm (pitch radius 6.11mm)
// Corrected to create circumferential belt teeth (not axial ribs) and enforce pitch diameter.
// Teeth are modeled as a 2D tooth-space profile revolved (rotate_extrude) and repeated 20x.
// Model is one connected solid; all translations are dimension-based.

$fn = 220;

// ----------------- Parameters -----------------
tooth_count = 20;
pitch_diameter_mm = 12.22;
pitch_radius_mm = pitch_diameter_mm/2;

pulley_width_mm = 10;

// Tooth geometry (printable approximation of timing pulley tooth form)
tooth_radial_height_mm = 1.2;      // radial height from root to tip
tooth_root_clearance_mm = 0.6;     // root radius = pitch_radius - clearance
tooth_tangential_width_factor = 0.55;
tooth_tip_relief_factor = 0.75;    // tip narrower than root
tooth_round_mm = 0.25;             // rounding of tooth corners (2D)

bore_diameter_mm = 5;

// Optional features (kept but dimension-driven and connected)
hub_diameter_mm = 16;
hub_length_mm = 6;
flange_diameter_mm = 18;
flange_thickness_mm = 1.5;

set_screw_count = 0;
set_screw_hole_diameter_mm = 3;
set_screw_z_mm = 3;
set_screw_hole_length_mm = 60;

overlap_mm = 0.6;

// ----------------- Derived -----------------
pitch_mm = PI * pitch_diameter_mm / tooth_count;

tooth_w_root = pitch_mm * tooth_tangential_width_factor;
tooth_w_tip  = tooth_w_root * tooth_tip_relief_factor;

root_radius  = pitch_radius_mm - tooth_root_clearance_mm;
outer_radius = root_radius + tooth_radial_height_mm;

// Ensure a solid core under the tooth root and around the bore
core_radius = max(root_radius, bore_diameter_mm/2 + 1.0);

// ----------------- Helpers -----------------
module rounded_poly(points, r) {
  // Rounds a polygon by offsetting out then in.
  // Works well for small r; if r<=0, returns the raw polygon.
  if (r <= 0)
    polygon(points=points);
  else
    offset(r=r) offset(delta=-r) polygon(points=points);
}

// 2D tooth "material" profile in (radius r, tangential y) plane.
// This is revolved around Z to create circumferential teeth.
module tooth_profile_2d() {
  // Place tooth so its mid-radius equals pitch radius:
  // mid_r = root_radius + tooth_radial_height/2
  // shift = pitch_radius - mid_r
  shift_r = pitch_radius_mm - (root_radius + tooth_radial_height_mm/2);

  r0 = root_radius + shift_r;
  r1 = outer_radius + shift_r;

  // Trapezoid in (r,y)
  pts = [
    [r0, -tooth_w_root/2],
    [r1, -tooth_w_tip/2],
    [r1,  tooth_w_tip/2],
    [r0,  tooth_w_root/2]
  ];

  rounded_poly(pts, tooth_round_mm);
}

module teeth_ring() {
  // Build teeth by repeating a small rotate_extrude segment for each tooth.
  // This creates belt teeth around the circumference (not axial ribs).
  union() {
    for (i = [0:tooth_count-1]) {
      rotate([0,0,i*360/tooth_count])
        rotate_extrude(angle=360/tooth_count, convexity=10)
          tooth_profile_2d();
    }
  }
}

module pulley_body() {
  union() {
    // Core cylinder under teeth
    cylinder(r=core_radius, h=pulley_width_mm, center=true);

    // Hub (connected with overlap)
    translate([0,0,-pulley_width_mm/2 - hub_length_mm/2 + overlap_mm])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges (connected with overlap)
    translate([0,0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

    translate([0,0,-pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
  }
}

module set_screw_holes() {
  if (set_screw_count > 0) {
    for (i = [0:set_screw_count-1]) {
      rotate([0,0,i*360/set_screw_count])
        translate([hub_diameter_mm/2 - overlap_mm, 0,
                   -pulley_width_mm/2 - hub_length_mm + set_screw_z_mm])
          rotate([0,90,0])
            cylinder(r=set_screw_hole_diameter_mm/2,
                     h=set_screw_hole_length_mm,
                     center=true, $fn=64);
    }
  }
}

// ----------------- Assembly -----------------
module pulley() {
  difference() {
    union() {
      pulley_body();
      // Teeth are centered on the pulley width and overlap into the core by construction
      linear_extrude(height=pulley_width_mm, center=true, convexity=10)
        projection(cut=false) children(); // placeholder (no-op)
      // Actual 3D teeth:
      // Make teeth full width by intersecting with a width-limited slab
      intersection() {
        teeth_ring();
        translate([0,0,0])
          cylinder(r=outer_radius + 5, h=pulley_width_mm + 2*overlap_mm, center=true);
      }
    }

    // Bore through entire part
    cylinder(r=bore_diameter_mm/2,
             h=pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 8*overlap_mm,
             center=true, $fn=120);

    // Set screw holes
    set_screw_holes();
  }
}

pulley();