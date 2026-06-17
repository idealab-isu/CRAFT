$fn = 96;

// Ring terminal parameters (mm)
ring_od = 16;          // outer diameter of ring
ring_id = 8;           // inner hole diameter
ring_th = 2.0;         // thickness (Z)

neck_len = 10;         // length from ring tangent to barrel start
neck_w   = 6.0;        // neck width
neck_th  = ring_th;    // neck thickness

barrel_len = 18;       // barrel length
barrel_od  = 7.5;      // barrel outer diameter
wire_id    = 4.0;      // wire hole diameter

flare_len  = 3.0;      // small flare at barrel end
flare_od   = 8.5;      // flare outer diameter

// Derived
ring_r_out = ring_od/2;
ring_r_in  = ring_id/2;

module ring_terminal() {
  difference() {
    union() {
      // Ring
      linear_extrude(height=ring_th)
        difference() {
          circle(r=ring_r_out);
          circle(r=ring_r_in);
        }

      // Neck (rectangular strap) attached to ring at +X side
      translate([ring_r_out, -neck_w/2, 0])
        cube([neck_len, neck_w, neck_th], center=false);

      // Barrel (tube) aligned along +X, centered on neck
      translate([ring_r_out + neck_len, 0, ring_th/2])
        rotate([0,90,0])
          cylinder(h=barrel_len, r=barrel_od/2, center=false);

      // Flare at barrel end
      translate([ring_r_out + neck_len + barrel_len, 0, ring_th/2])
        rotate([0,90,0])
          cylinder(h=flare_len, r1=barrel_od/2, r2=flare_od/2, center=false);
    }

    // Wire hole through barrel + flare
    translate([ring_r_out + neck_len - 0.5, 0, ring_th/2])
      rotate([0,90,0])
        cylinder(h=barrel_len + flare_len + 1.0, r=wire_id/2, center=false);

    // Slight relief where neck meets ring (optional smoothing cut)
    translate([ring_r_out - 0.2, 0, ring_th/2])
      rotate([0,90,0])
        cylinder(h=1.2, r=neck_w*0.55, center=true);
  }
}

ring_terminal();