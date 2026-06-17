$fn = 64;

module ssr_module(len=63.0, wid=45.0, ht=23.0, corner_r=2.0) {
    // Main body: rounded rectangular prism
    linear_extrude(height=ht)
        offset(r=corner_r)
            square([len - 2*corner_r, wid - 2*corner_r], center=true);
}

ssr_module();