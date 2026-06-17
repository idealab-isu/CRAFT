// Simple SMD package (one connected solid)
// Target overall size: [8.70, 3.90, 1.25] (L, W, H)

body_L = 8.70;
body_W = 3.90;
body_H = 1.25;

// Small top-edge bevel (kept subtle; does not change overall size)
edge_bevel = 0.12;   // mm
bevel_h    = 0.10;   // mm (height of bevel region from top)

// Pin-1 polarity mark (engraved dot on top)
mark_r     = 0.25;   // mm
mark_depth = 0.08;   // mm
mark_inset = 0.70;   // mm from left and top edges

// Bottom terminations (simple end pads as part of the solid)
pad_L      = 0.90;   // mm (length along L)
pad_H      = 0.18;   // mm (thickness below body)
pad_insetW = 0.20;   // mm inset from each side edge

overlap = 0.02;
$fn = 64;

function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

eb = clamp(edge_bevel, 0, min(body_L, body_W)/2 - 0.01);
bh = clamp(bevel_h, 0, body_H - 0.01);
md = clamp(mark_depth, 0, body_H - 0.01);

module body_with_top_bevel() {
  // Keep overall size exactly [body_L, body_W, body_H]
  // by beveling only within the top region.
  difference() {
    cube([body_L, body_W, body_H], center=true);

    // Four top-edge bevel cuts (long wedges along each side)
    // +Y edge
    translate([0,  body_W/2 - eb/2, body_H/2 - bh/2])
      rotate([0, 90, 0])
        linear_extrude(height=body_L + 2*overlap, center=true)
          polygon(points=[[0,0],[eb,0],[0,bh]]);
    // -Y edge
    translate([0, -body_W/2 + eb/2, body_H/2 - bh/2])
      rotate([0,-90, 0])
        linear_extrude(height=body_L + 2*overlap, center=true)
          polygon(points=[[0,0],[eb,0],[0,bh]]);
    // +X edge
    translate([ body_L/2 - eb/2, 0, body_H/2 - bh/2])
      rotate([90, 0, 90])
        linear_extrude(height=body_W + 2*overlap, center=true)
          polygon(points=[[0,0],[eb,0],[0,bh]]);
    // -X edge
    translate([-body_L/2 + eb/2, 0, body_H/2 - bh/2])
      rotate([-90,0, 90])
        linear_extrude(height=body_W + 2*overlap, center=true)
          polygon(points=[[0,0],[eb,0],[0,bh]]);
  }
}

module pin1_mark_cut() {
  // Engraved dot near top-left corner on the top face
  translate([
      -body_L/2 + mark_inset,
       body_W/2 - mark_inset,
       body_H/2 - md/2
    ])
    cylinder(r=mark_r, h=md + 2*overlap, center=true);
}

module end_pad(side) {
  // side = -1 (left), +1 (right)
  // Pads are attached to the bottom, protruding slightly below the body.
  pad_W = body_W - 2*pad_insetW;

  translate([
      side*(body_L/2 - pad_L/2),
      0,
      -body_H/2 - pad_H/2 + overlap
    ])
    cube([pad_L, pad_W, pad_H], center=true);
}

module smd_package() {
  difference() {
    union() {
      body_with_top_bevel();
      end_pad(-1);
      end_pad( 1);
    }
    pin1_mark_cut();
  }
}

smd_package();