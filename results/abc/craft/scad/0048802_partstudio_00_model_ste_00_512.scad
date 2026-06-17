// Dimension-calibrated (target: 0.27 x 0.08 x 0.09 mm)
scale([0.883333, 0.880000, 0.810000])
{
// Symmetric stepped rectangular bar (single connected solid)
// Bounding box: 0.30 x 0.10 x 0.10 (X x Y x Z), elongated along X

L      = 0.30;

end_L  = 0.06;
mid_L  = 0.08;

end_W  = 0.10;
end_H  = 0.10;

web_W  = 0.04;
web_H  = 0.06;

mid_W  = 0.06;
mid_H  = 0.10;

overlap = 0.002; // small overlap to guarantee watertight union

// Derived
web_L = L - 2*end_L + 2*overlap; // spans between end blocks with overlap

module end_block(xsign=1) {
    translate([xsign*(L/2 - end_L/2), 0, 0])
        cube([end_L, end_W, end_H], center=true);
}

union() {
    // Narrow web connecting the ends
    cube([web_L, web_W, web_H], center=true);

    // Thicker mid-body section (centered)
    cube([mid_L + 2*overlap, mid_W, mid_H], center=true);

    // End pads
    end_block(-1);
    end_block( 1);
}
}
