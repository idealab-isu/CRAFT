// Dimension-calibrated (target: 0.01 x 0.01 x 0.01 mm)
scale([1.020412, 1.020412, 1.348363])
{
// Axisymmetric coupling/knob with two knurled bands, stepped flange, and through hex bore
// Units: mm

$fn = 160;

// Parameters (kept from original, but interpreted as mm-scale values)
body_D = 0.0082;
body_L = 0.0096;

flange_D = 0.0098;
flange_L = 0.0016;

hex_flat = 0.0046;

upper_knurl_L = 0.0022;
lower_knurl_L = 0.0022;

knurl_peak = 0.00035;          // radial protrusion of knurl teeth
serration_count = 18;          // teeth around circumference
overlap = 0.0006;

chamfer_z = 0.00035;           // end chamfer height
relief_groove_L = 0.0007;      // small relief at bottom end
relief_groove_depth = 0.00035; // radial depth of relief groove

mid_serration_L = 0.0016;      // optional mid band height (kept subtle)
knurl_phase_deg = 10;

scale_uniform = 1;

// Derived
body_r = body_D/2;
flange_r = flange_D/2;

// Z layout (centered body)
z_bot = -body_L/2;
z_top =  body_L/2;

z_lower_knurl_c = z_bot + lower_knurl_L/2;
z_upper_knurl_c = z_top - flange_L - upper_knurl_L/2;

// Place mid band between lower and upper regions
mid_free_L = max(0, body_L - flange_L - upper_knurl_L - lower_knurl_L);
z_mid_c = z_bot + lower_knurl_L + mid_free_L/2;

// ---------- Helpers ----------
module hex2d(flat) {
  // Regular hex with given flat-to-flat distance
  // circumradius = flat / sqrt(3)
  r = flat / sqrt(3);
  polygon(points=[for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

module knurl_band(zc, h, base_r, peak, n, phase=0) {
  // Adds outward triangular teeth around circumference (axisymmetric base + radial teeth)
  // Teeth overlap into base by 'overlap' to ensure connectivity.
  tooth_len = peak + overlap;
  tooth_w   = 2*PI*base_r / n * 0.55; // tangential width
  union() {
    // Slightly enlarged band cylinder to blend teeth
    translate([0,0,zc]) cylinder(r=base_r + peak*0.25, h=h, center=true);

    for (i = [0:n-1]) {
      rotate([0,0,phase + i*360/n])
        translate([base_r + tooth_len/2 - overlap, 0, zc])
          // Triangular prism tooth (pointing outward)
          rotate([0,90,0])
            linear_extrude(height=tooth_len, center=true, convexity=5)
              polygon(points=[
                [-tooth_w/2, -h/2],
                [-tooth_w/2,  h/2],
                [ tooth_w/2,  0]
              ]);
    }
  }
}

module end_chamfer(zc, r, h, top=true) {
  // Chamfer as a conical frustum removed from end
  // top=true -> chamfer at +Z end, else at -Z end
  translate([0,0,zc])
    cylinder(h=h, r1=top ? r : 0, r2=top ? 0 : r, center=true);
}

// ---------- Main solid ----------
module outer_solid() {
  union() {
    // Main body
    cylinder(r=body_r, h=body_L, center=true);

    // Stepped flange on +Z end (distinct)
    translate([0,0, z_top - flange_L/2 + overlap])
      cylinder(r=flange_r, h=flange_L, center=true);

    // Knurled grip bands (upper and lower)
    knurl_band(z_lower_knurl_c, lower_knurl_L, body_r, knurl_peak, serration_count, 0);
    knurl_band(z_upper_knurl_c, upper_knurl_L, body_r, knurl_peak, serration_count, knurl_phase_deg);

    // Subtle mid serration band (smaller than knurl)
    if (mid_serration_L > 0)
      knurl_band(z_mid_c, mid_serration_L, body_r, serration_depth=knurl_peak*0.55, n=serration_count, phase=knurl_phase_deg/2);
  }
}

// OpenSCAD doesn't allow named args not in signature; provide wrapper for mid band depth
module knurl_band(zc, h, base_r, peak, n, phase=0, serration_depth=undef) {
  p = (serration_depth == undef) ? peak : serration_depth;
  tooth_len = p + overlap;
  tooth_w   = 2*PI*base_r / n * 0.55;
  union() {
    translate([0,0,zc]) cylinder(r=base_r + p*0.20, h=h, center=true);
    for (i = [0:n-1]) {
      rotate([0,0,phase + i*360/n])
        translate([base_r + tooth_len/2 - overlap, 0, zc])
          rotate([0,90,0])
            linear_extrude(height=tooth_len, center=true, convexity=5)
              polygon(points=[
                [-tooth_w/2, -h/2],
                [-tooth_w/2,  h/2],
                [ tooth_w/2,  0]
              ]);
    }
  }
}

module outer_with_details() {
  difference() {
    outer_solid();

    // End chamfers (remove material)
    // Top chamfer around flange OD
    end_chamfer(z_top + chamfer_z/2 - overlap, flange_r + overlap, chamfer_z + 2*overlap, top=true);

    // Bottom chamfer around body OD
    end_chamfer(z_bot - chamfer_z/2 + overlap, body_r + overlap, chamfer_z + 2*overlap, top=false);

    // Bottom relief groove (a shallow undercut ring)
    translate([0,0, z_bot + relief_groove_L/2])
      cylinder(r=body_r + knurl_peak + overlap, h=relief_groove_L + 2*overlap, center=true);

    // Carve the relief depth by subtracting a slightly smaller cylinder from the groove region
    // (leaves a step/undercut)
    translate([0,0, z_bot + relief_groove_L/2])
      cylinder(r=body_r + knurl_peak - relief_groove_depth, h=relief_groove_L + 2*overlap, center=true);
  }
}

module through_hex_bore() {
  // Through bore spans entire part including chamfers/flange with margin
  bore_h = body_L + flange_L + 2*chamfer_z + 6*overlap;
  linear_extrude(height=bore_h, center=true, convexity=10)
    hex2d(hex_flat);
}

module final_part() {
  difference() {
    outer_with_details();
    through_hex_bore();
  }
}

// Final output
scale([scale_uniform, scale_uniform, scale_uniform])
  final_part();
}
