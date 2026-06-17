// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:1]
center = true; //[0:1:1]
type_id = 0; //[0:5:1]
default_id = 2.0; //[1.0:4.0:0.1]
default_od = 3.2; //[1.6:6.4:0.1]
wall_extra = 0.0; //[-0.5:1.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
resistor_body_length = 6.5; //[4.0:13.0:0.1]
resistor_body_diameter = 2.5; //[1.5:5.0:0.1]
lead_diameter = 0.6; //[0.3:1.2:0.05]
bare_lead = 5; //[2:10:1]
sleeving_length = 10; //[5:25:1]

// Derived
id_r = ((forced_id > 0) ? forced_id : default_id) / 2;
od_r = (default_od + wall_extra) / 2;
eps = 0.01;

// 1–2mm overlap to guarantee connection
conn = 1.5;

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(h=length, r=od_r, center=center);
      cylinder(h=length + 2*eps, r=id_r, center=center);
    }
  }
}

// Sleeved Resistor - complete geometry (with connected center collar)
module sleeved_resistor() {

  // Precompute positions so all parts overlap by conn
  body_half = resistor_body_length/2;
  sleeve_half = sleeving_length/2;

  // Sleeve centers along X so inner ends overlap into body by conn
  // Inner end of left sleeve: x = -body_half + conn
  // Inner end of right sleeve: x =  body_half - conn
  left_sleeve_x  = -(body_half + sleeve_half - conn);
  right_sleeve_x =  (body_half + sleeve_half - conn);

  // Leads (extend through sleeves and into body slightly)
  lead_len = sleeving_length + bare_lead + conn;
  left_lead_x  = -(body_half + lead_len/2 - conn);
  right_lead_x =  (body_half + lead_len/2 - conn);

  // Center collar MUST be physically attached to the black sleeves:
  // Make it span from (left sleeve inner end - conn) to (right sleeve inner end + conn)
  // so it overlaps each sleeve by conn.
  collar_len = resistor_body_length + 4*conn; // guarantees overlap into both sleeves
  collar_r_outer = od_r * 1.15;
  collar_r_inner = id_r;

  // Vertical insert/sleeve through the center (the "floating" light gray piece in views)
  // Attach it by intersecting the collar and the resistor body region.
  // Make it pass through the collar with 1–2mm overlap.
  insert_h = (2*collar_r_outer) + 2*conn; // tall enough to fully pass through collar
  insert_r_outer = collar_r_outer * 0.95;
  insert_r_inner = collar_r_inner;

  union() {
    // Black parts
    color([0.2, 0.2, 0.2]) union() {
      // Resistor body
      rotate([0, 90, 0])
        cylinder(h=resistor_body_length, r=resistor_body_diameter / 2, center=true);

      // Leads
      translate([left_lead_x, 0, 0])
        rotate([0, 90, 0]) cylinder(h=lead_len, r=lead_diameter / 2, center=true);

      translate([right_lead_x, 0, 0])
        rotate([0, 90, 0]) cylinder(h=lead_len, r=lead_diameter / 2, center=true);

      // Left lead sleeve (overlaps into body by conn)
      difference() {
        translate([left_sleeve_x, 0, 0])
          rotate([0, 90, 0]) cylinder(h=sleeving_length, r=od_r, center=true);
        translate([left_sleeve_x, 0, 0])
          rotate([0, 90, 0]) cylinder(h=sleeving_length + 2*eps, r=id_r, center=true);
      }

      // Right lead sleeve (overlaps into body by conn)
      difference() {
        translate([right_sleeve_x, 0, 0])
          rotate([0, 90, 0]) cylinder(h=sleeving_length, r=od_r, center=true);
        translate([right_sleeve_x, 0, 0])
          rotate([0, 90, 0]) cylinder(h=sleeving_length + 2*eps, r=id_r, center=true);
      }
    }

    // Light gray collar + vertical insert are UNIONED and OVERLAP the black sleeves/body
    color([0.75, 0.75, 0.7]) union() {
      // Center collar (horizontal, along X) - overlaps both black sleeves by conn
      difference() {
        rotate([0, 90, 0])
          cylinder(h=collar_len, r=collar_r_outer, center=true);
        rotate([0, 90, 0])
          cylinder(h=collar_len + 2*eps, r=collar_r_inner, center=true);
      }

      // Vertical sleeve/insert through center - physically attached by intersecting collar
      // (and also intersects the resistor body region at the center)
      difference() {
        cylinder(h=insert_h, r=insert_r_outer, center=true);
        cylinder(h=insert_h + 2*eps, r=insert_r_inner, center=true);
      }
    }
  }
}

// Assembly - single connected solid
module assembly() {
  // Ensure everything is one connected solid:
  // Place the standalone tubing so it intersects the resistor assembly by conn.
  // Both are centered at origin; align along Z (tubing) and ensure it intersects the collar/insert.
  union() {
    // Move tubing so it passes through the center region and intersects the vertical insert/collar.
    // With center=true, tubing spans [-length/2, +length/2] in Z already, so no translate needed.
    tubing();

    // Resistor assembly centered at origin; collar/insert at origin ensures intersection with tubing.
    sleeved_resistor();
  }
}

assembly();