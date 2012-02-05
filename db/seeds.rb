# coding: utf-8

# Create Languages

[
  ["en", "English", "English"],
  ["ja", "Japanese", "日本語"],
].each do |s, e, n|
  Language.create(short_name: s, english_name: e, native_name: n)
end

# Create EntryTypes

%w(class module
   class_method instance_method
).each do |n|
  EntryType.create(name: n)
end
