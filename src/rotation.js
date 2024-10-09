export function rotateRightByOnes(binaryInt, n) {
  let binaryStr = binaryInt.toString(2);

  let positions = [];
  for (let i = 0; i < binaryStr.length; i++) {
    if (binaryStr[i] === "1") {
      positions.push(i);
    }
  }
  if (n === 0) {
    return binaryInt;
  } else if (n < 0 || n > positions.length) {
    throw new Error("Invalid value for n");
  }

  let rotateIndex = positions[n - 1];

  let rotatedStr =
    binaryStr.slice(rotateIndex) + binaryStr.slice(0, rotateIndex);

  return parseInt(rotatedStr, 2);
}

export function rotateLeft(num, bits, places) {
  return ((num << places) | (num >>> (bits - places))) & ((1 << bits) - 1);
}

function rotateRight(num, bits, places) {
  return ((num >>> places) | (num << (bits - places))) & ((1 << bits) - 1);
}

export function getMinRotation(num, bits = 12) {
  let minRotation = num;
  for (let i = 1; i < bits; i++) {
    const rotated = rotateLeft(num, bits, i);
    if (rotated < minRotation) {
      minRotation = rotated;
    }
  }
  return minRotation;
}

export function getMaxRotation(num, bits = 12) {
  let maxRotation = num;
  for (let i = 1; i < bits; i++) {
    const rotated = rotateLeft(num, bits, i);
    if (rotated > maxRotation) {
      maxRotation = rotated;
    }
  }
  return maxRotation;
}

function getAllRotations(num, bits = 12) {
  let rotations = new Set();
  let rotationsArr = [];
  for (let i = 0; i < bits; i++) {
    let v = rotateLeft(num, bits, i);
    if (!rotations.has(v)) {
      rotationsArr.push(v);
    }
    rotations.add(v);
  }
  return rotationsArr;
}

export function areInSameRotationClass(a, b, bits = 12) {
  const rotationsOfA = new Set(getAllRotations(a, bits));
  return rotationsOfA.has(b);
}

function groupByRotationClass(bits = 12) {
  let species = new Set();

  for (let num = 0; num < 1 << bits; num++) {
    const rotations = getAllRotations(num, bits);
    let minRotation = Math.min(...rotations);

    species.add(minRotation);
  }

  return Array.from(species).map((v) => [
    v,
    getAllRotations(getMaxRotation(v), bits),
  ]);
}

export const rotationGroups = groupByRotationClass(12);

export function intToBoolArray(num, bits = 12) {
  let boolArray = [];

  for (let i = bits - 1; i >= 0; i--) {
    boolArray.push((num & (1 << i)) !== 0);
  }

  return boolArray;
}
