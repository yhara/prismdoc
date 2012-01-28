# coding: utf-8

# Create Languages

[
  ["English", "English"],
  ["Japanese", "日本語"],
].each do |e, n|
  Language.create(english_name: e, native_name: n)
end

# Create EntryTypes

%w(class module
   class_method instance_method
).each do |n|
  EntryType.create(name: n)
end
