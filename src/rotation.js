function rotateLeft(num, bits, places) {
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
  let groups = {};
  let visited = new Set();

  for (let num = 0; num < 1 << bits; num++) {
    if (visited.has(num)) continue;

    const rotations = getAllRotations(num, bits);
    rotations.forEach((rot) => visited.add(rot));
    let minRotation = Math.min(...rotations);

    if (!groups[minRotation]) {
      groups[minRotation] = [];
    }
    groups[minRotation].push(num);
  }

  return Object.entries(groups);
}

export const rotationGroups = groupByRotationClass(12);

export function intToBoolArray(num, bits = 12) {
  let boolArray = [];

  for (let i = bits - 1; i >= 0; i--) {
    boolArray.push((num & (1 << i)) !== 0);
  }

  return boolArray;
}
