// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The rsa_attack library.
library rsa_attack;

import "dart:math" show Random, pow;

int bigRandom(int max) {
  var random = new Random();
  var length = max.toString().length;
  while (true) {
    var digits = new List.generate(length, (_) => random.nextInt(10));
    var intTry = int.parse(digits.join());
    if (intTry < max) return intTry;
  }
}

List<int> getPrimeFactors(int n, int k) {
  var length = n.toString().length;
  var exponent = (length / 2).ceil() - 1;
  var start = pow(10, exponent);
  var end = start * 10;
  var primesDone = false;
  var current = nextPrimeAfter(start, k);
  var primes = [];
  while (current < end) {
    var i = 0;
    while (true) {
      if (i == primes.length) {
        if (primesDone) break;
        primes.add(nextPrimeAfter(0 == primes.length ?
            current : primes.last, k));
        if (primes.last >= end) primesDone = true;
      }
      if (n == primes[i] * current) return [current, primes[i]];
      i++;
    }
    current = primes.removeAt(0);
  }
  throw new Exception("Could not disassemble $n");
}


List<int> primesBetween(int start, int end, int k) {
  var result = [];
  if (start.isEven) start += 1;
  for (int i = start; i < end; i += 2) {
    if (isMillerRabinPrime(i, k)) result.add(i);
  }
  return result;
}

int nextPrimeAfter(int n, int k) {
  n += 1;
  if (n.isEven) n += 1;
  while (true) {
    if (isMillerRabinPrime(n, k)) return n;
    n += 2;
  }
}


bool isMillerRabinPrime(int n, int k) {
  if (3 == n || 2 == n) return true;
  var d = n - 1;
  var s = 0;
  while (0 == d % 2) {
    d ~/= 2;
    s += 1;
  }
  for (int i = 0; i < k; i ++) {
    var a = 2 + bigRandom(n - 4);
    var x = modPow(a, d, n);
    if (1 == x || n - 1 == x) continue;
    for (int r = 1; r <= s - 1; r++) {
      x = modPow(x, 2, n);
      if (1 == x) return false;
      if (n - 1 == x) break;
    }
    if (x != n - 1) return false;
  }
  return true;
}

int modPow(int base, int exponent, int modulus) {
  var result = 1;
  while (exponent > 0) {
    if ((exponent & 1) != 0) result = (base * result) % modulus;
    base = (base * base) % modulus;
    exponent >>= 1;
  }
  return result;
}