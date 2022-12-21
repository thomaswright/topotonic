import React from "react";

export const Logo = () => {
  return (
    <div
      className="h-8 w-8"
      dangerouslySetInnerHTML={{
        __html: `
      <svg width="100%" height="100%" viewBox="0 0 82 105" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" xmlns:serif="http://www.serif.com/" style="fill-rule:evenodd;clip-rule:evenodd;stroke-linejoin:round;stroke-miterlimit:2;">
    <g transform="matrix(1,0,0,1,-1203.77,-2135.7)">
        <g>
            <g transform="matrix(1,0,0,1,-6.35441,16.7353)">
                <path d="M1287.82,2137.26L1258.72,2137.26L1240.27,2223.96L1220.92,2223.96L1239.22,2137.26L1210.12,2137.26L1214.02,2118.96L1291.57,2118.96L1287.82,2137.26Z" style="fill:rgb(25,0,175);fill-rule:nonzero;"/>
            </g>
            <g transform="matrix(1.05087,0,0,1,-83.0834,136.691)">
                <g transform="matrix(0.951595,-0,-0,1,1224.56,1999.01)">
                    <use xlink:href="#_Image1" x="15.025" y="40.439" width="51.562px" height="65.108px" transform="matrix(0.991569,0,0,0.986482,0,0)"/>
                </g>
            </g>
        </g>
    </g>
    <defs>
        <image id="_Image1" width="52px" height="66px" xlink:href="data:image/png;base64,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"/>
    </defs>
</svg>
      `,
      }}
    />
  );
};
