#!/usr/bin/env bash
mkdir -p cov covs

find target/debug/deps -not -name '*.so' -executable -type f | while read -r t; do
  kcov --exclude-pattern '.cargo/' "covs/$(basename "$t")" "$t"
done

kcov --merge cov covs/*
