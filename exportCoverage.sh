#!/usr/bin/env bash -x

profdata=$(find "." -name "*.profdata")
find ".build/" -name "*xctest" | while read f
do
  _proj=${f##*/}  
  _proj=${_proj%."xctest"}
  dest=$([ -f "$f/$_proj" ] && echo "$f/$_proj" || echo "$f/Contents/MacOS/$_proj")
  _proj_name=$(echo "$_proj" | sed -e 's/[[:space:]]//g')
  xcrun llvm-cov show -instr-profile "$profdata" "$dest" > "$_proj_name.xctest.coverage.txt"
done
