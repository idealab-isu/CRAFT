// Dimension-calibrated (target: 0.93 x 0.35 x 1.43 mm)
scale([1.000006, 2.665730, 1.009168])
{
// Elongated ribbed shaft with polygonal end caps, DISCRETE radial tabs, and a single side nub
// Target bounding box ~0.9 x 0.3 x 1.4 mm (Z is long axis)

$fn = 72;

// -------------------- Parameters (mm) --------------------
bbox_x = 0.93;
bbox_y = 0.35;
bbox_z = 1.43;

mid_len = 0.95;
mid_r   = 0.12;

// Ribbed midsection (stacked thin discs)
fin_count = 14;
fin_thk   = 0.02;
fin_r     = 0.165;

// End caps
cap_len   = 0.24;
cap_sides = 8;
cap_r     = 0.175;

// Discrete radial tabs along length (not continuous fins)
tab_count  = 10;
tab_len    = 0.045;   // radial protrusion length
tab_w      = 0.05;    // tangential width
tab_h      = 0.03;    // axial height
tab_z_span = 0.80;    // span along Z where tabs appear
tab_ring_n = 4;       // number of tabs around circumference per Z station

// Single side nub near one end
nub_r          = 0.03;
nub_len        = 0.04;
nub_z_from_end = 0.18; // measured from very bottom end toward center

// NOTE: model is in mm; use small overlaps appropriate to this scale
overlap   = 0.006;   // robust unions at this tiny scale
chamfer_h = 0.02;

// -------------------- Helpers --------------------
module mid_cyl_body() {
  cylinder(h=mid_len, r=mid_r, center=true);
}

module fin_at(zpos) {
  translate([0,0,zpos])
    cylinder(h=fin_thk, r=fin_r, center=true);
}

module ribbed_fins_midsection() {
  union() {
    if (fin_count <= 1) {
      fin_at(0);
    } else {
      for (i = [0:fin_count-1]) {
        fin_at((-mid_len/2) + fin_thk/2 + i*(mid_len - fin_thk)/(fin_count-1));
      }
    }
  }
}

module end_cap(zsign=1) { // zsign: -1 bottom, +1 top
  // Centered so it overlaps slightly into the midsection for a watertight union
  translate([0,0, zsign*(mid_len/2 + cap_len/2 - overlap)])
    cylinder(h=cap_len, r=cap_r, center=true, $fn=cap_sides);
}

// One tab, oriented radially outward along +X, centered at given z
module tab_primitive(zpos) {
  // Inner face overlaps into shaft for connectivity
  translate([mid_r + tab_len/2 - overlap, 0, zpos])
    cube([tab_len + 2*overlap, tab_w, tab_h], center=true);
}

// Tabs: discrete protrusions (small blocks) at multiple Z positions and multiple angles
module radial_tabs_array() {
  union() {
    if (tab_count <= 1) {
      for (a = [0:tab_ring_n-1])
        rotate([0,0,a*360/tab_ring_n]) tab_primitive(0);
    } else {
      for (i = [0:tab_count-1]) {
        zpos = (-tab_z_span/2) + i*(tab_z_span)/(tab_count-1);
        for (a = [0:tab_ring_n-1])
          rotate([0,0,a*360/tab_ring_n]) tab_primitive(zpos);
      }
    }
  }
}

module single_side_nub() {
  // Whole part extents (with caps) along Z:
  // bottom end = -(mid_len/2 + cap_len)
  // top end    = +(mid_len/2 + cap_len)
  z_bottom = -(mid_len/2 + cap_len);
  z0 = z_bottom + nub_z_from_end;

  // Clamp nub Z so it stays on/near the bottom cap region and remains connected
  // (prevents accidental placement outside the solid if parameters change)
  z0c = min(z0, -(mid_len/2) + cap_len - overlap);
  z0cc = max(z0c, z_bottom + overlap);

  // Attach on +X side; overlap into shaft/cap region
  translate([mid_r + nub_len/2 - overlap, 0, z0cc])
    rotate([0,90,0])
      cylinder(h=nub_len + 2*overlap, r=nub_r, center=true, $fn=36);
}

module cap_chamfer_cutter(zpos, flip=false) {
  translate([0,0,zpos])
    rotate([flip ? 180 : 0, 0, 0])
      cylinder(h=chamfer_h, r1=cap_r + 0.02, r2=0, center=true, $fn=cap_sides*2);
}

module main_union_pre_chamfer() {
  union() {
    // Core
    mid_cyl_body();

    // Ribbed/grip texture (circumferential rings)
    ribbed_fins_midsection();

    // Enlarged polygonal end housings/collars
    end_cap(-1);
    end_cap( 1);

    // Discrete side tabs/protrusions along the length
    radial_tabs_array();

    // Single asymmetrical side nub near one end
    single_side_nub();
  }
}

module final_part() {
  difference() {
    main_union_pre_chamfer();

    // Bottom cap chamfer (outer end)
    cap_chamfer_cutter(
      zpos = (-(mid_len/2 + cap_len)) + chamfer_h/2,
      flip = true
    );

    // Top cap chamfer (outer end)
    cap_chamfer_cutter(
      zpos = ( (mid_len/2 + cap_len)) - chamfer_h/2,
      flip = false
    );
  }
}

// Output: one connected solid
final_part();
}
