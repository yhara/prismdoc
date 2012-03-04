# coding: utf-8

# Create Languages
[
  ["en", "English", "English"],
  ["ja", "Japanese", "日本語"],
  ["cp", "Capitalized", "CAPITALIZED"], # for experimental use
].each do |s, e, n|
  Language.create(short_name: s, english_name: e, native_name: n)
end
