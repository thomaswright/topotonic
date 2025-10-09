const DEFAULT_BITS = 12;

const maskForBits = (bits) => (1 << bits) - 1;

const normalizeValue = (value, bits) => value & maskForBits(bits);

const normalizeShift = (shift, bits) => {
  const mod = shift % bits;
  return mod < 0 ? mod + bits : mod;
};

const binaryString = (value) => value.toString(2);

const collectOnePositions = (binaryStr) => {
  const positions = [];
  for (let i = 0; i < binaryStr.length; i += 1) {
    if (binaryStr[i] === "1") {
      positions.push(i);
    }
  }
  return positions;
};

const rotateBinaryStringLeft = (binaryStr, positions) =>
  binaryStr.slice(positions) + binaryStr.slice(0, positions);

export function rotateRightByOnes(binaryInt, n) {
  if (n === 0) {
    return binaryInt;
  }
  if (n < 0) {
    throw new Error("Invalid value for n");
  }

  const binaryStr = binaryString(binaryInt);
  const positions = collectOnePositions(binaryStr);

  if (n > positions.length) {
    throw new Error("Invalid value for n");
  }

  const rotateIndex = positions[n - 1];
  const rotatedStr = rotateBinaryStringLeft(binaryStr, rotateIndex);

  return parseInt(rotatedStr, 2);
}

export function rotateLeft(num, bits = DEFAULT_BITS, places = 0) {
  const normalized = normalizeValue(num, bits);
  const shift = normalizeShift(places, bits);
  if (shift === 0) {
    return normalized;
  }
  const mask = maskForBits(bits);
  return ((normalized << shift) | (normalized >>> (bits - shift))) & mask;
}

const collectRotations = (num, bits = DEFAULT_BITS) => {
  const rotations = [];
  const seen = new Set();
  for (let shift = 0; shift < bits; shift += 1) {
    const rotated = rotateLeft(num, bits, shift);
    if (seen.has(rotated)) {
      break;
    }
    seen.add(rotated);
    rotations.push(rotated);
  }
  return rotations;
};

export function getMinRotation(num, bits = DEFAULT_BITS) {
  const rotations = collectRotations(num, bits);
  if (rotations.length === 0) {
    return 0;
  }
  let minRotation = rotations[0];
  for (let i = 1; i < rotations.length; i += 1) {
    if (rotations[i] < minRotation) {
      minRotation = rotations[i];
    }
  }
  return minRotation;
}

export function getMaxRotation(num, bits = DEFAULT_BITS) {
  const rotations = collectRotations(num, bits);
  if (rotations.length === 0) {
    return 0;
  }
  let maxRotation = rotations[0];
  for (let i = 1; i < rotations.length; i += 1) {
    if (rotations[i] > maxRotation) {
      maxRotation = rotations[i];
    }
  }
  return maxRotation;
}

export function getAllRotations(num, bits = DEFAULT_BITS) {
  return collectRotations(num, bits);
}

export function areInSameRotationClass(a, b, bits = DEFAULT_BITS) {
  const target = normalizeValue(b, bits);
  const rotations = collectRotations(a, bits);
  for (let i = 0; i < rotations.length; i += 1) {
    if (rotations[i] === target) {
      return true;
    }
  }
  return false;
}

function groupByRotationClass(bits = DEFAULT_BITS) {
  const upperBound = 1 << bits;
  const visited = new Set();
  const groups = [];

  for (let num = 0; num < upperBound; num += 1) {
    if (visited.has(num)) {
      continue;
    }

    const minRotation = getMinRotation(num, bits);
    if (visited.has(minRotation)) {
      continue;
    }

    const canonicalMax = getMaxRotation(minRotation, bits);
    const rotations = collectRotations(canonicalMax, bits);

    rotations.forEach((rotation) => {
      visited.add(rotation);
    });

    groups.push([minRotation, rotations]);
  }

  return groups;
}

export const rotationGroups = groupByRotationClass(DEFAULT_BITS);

export function intToBoolArray(num, bits = DEFAULT_BITS) {
  const normalized = normalizeValue(num, bits);
  const boolArray = [];
  for (let i = 0; i < bits; i += 1) {
    const mask = 1 << (bits - 1 - i);
    boolArray.push((normalized & mask) !== 0);
  }
  return boolArray;
}
