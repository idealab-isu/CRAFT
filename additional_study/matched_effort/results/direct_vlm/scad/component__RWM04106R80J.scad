$fn=96;

// Resistor 6R8 3W vitreous enamel (cement / vitreous wirewound style)
// Typical form factor: rectangular ceramic body with axial leads.
// Dimensions are approximate (mm) and oriented along X (lead-to-lead).

// --- Main dimensions ---
body_len = 25.0;     // ceramic block length
body_w   = 9.0;      // width
body_h   = 9.0;      // height

end_cap_len = 2.2;   // metal end cap length (each end)
end_cap_w   = 9.2;   // slightly larger than body
end_cap_h   = 9.2;

lead_d = 0.8;
lead_len_each = 28.0;

// Small overlaps to ensure ONE connected solid
overlap = 0.4;

// Edge rounding (small, for performance)
edge_r = 0.6;

// --- Helpers ---
module rounded_box(size=[10,10,10], r=0.5){
  // Rounded rectangular prism via Minkowski (keep r modest)
  minkowski(){
    cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=true);
    sphere(r=r);
  }
}

module lead_x(len){
  // Lead along +X, starting at x=0
  color([0.75,0.75,0.78])
    rotate([0,90,0])
      cylinder(h=len, d=lead_d, center=false);
}

module resistor_3w_vitreous(){
  union(){
    // Ceramic body (centered at origin)
    color([0.96,0.96,0.94])
      rounded_box([body_len, body_w, body_h], r=edge_r);

    // Metal end caps (connected with slight overlap into body)
    for (s=[-1,1]){
      color([0.85,0.85,0.86])
        translate([s*(body_len/2 - end_cap_len/2 + overlap/2), 0, 0])
          rounded_box([end_cap_len + overlap, end_cap_w, end_cap_h], r=min(edge_r, end_cap_len/2));
    }

    // Leads (axial, along X) - start at end cap outer faces with overlap
    // Left lead: extends to -X
    translate([-(body_len/2 + overlap/2), 0, 0])
      rotate([0,0,180])
        lead_x(lead_len_each + overlap);

    // Right lead: extends to +X
    translate([ (body_len/2 + overlap/2), 0, 0])
      lead_x(lead_len_each + overlap);
  }
}

resistor_3w_vitreous();