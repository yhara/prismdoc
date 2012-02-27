# coding: utf-8

# Create Languages

[
  ["en", "English", "English"],
  ["ja", "Japanese", "日本語"],
].each do |s, e, n|
  Language.create(short_name: s, english_name: e, native_name: n)
end
