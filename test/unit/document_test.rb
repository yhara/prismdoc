require 'test_helper'
require 'rdoc_helper.rb'

module RubyApi
  class DocumentTest < ActiveSupport::TestCase
    context "when creating an instance" do
      should "check <translated> has valid value" do
        doc = Document.new(entry: entries("builtin19"),
                           language: languages("ja"),
                           body: "")
        doc.translated = "xxxx"
        assert_equal false, doc.valid?
        assert_match /unknown state/, doc.errors[:translated].first
      end

      should "check it is not translated yet" do
        doc = Document.new(entry: entries("object19"),
                           language: languages("ja"),
                           body: "")
        assert_equal false, doc.valid?
        assert_match /already/, doc.errors[:entry_id].first
      end

#      context "and setting #translated" do
#        should "set 'no' for document not translated" do
#          doc = Document.create(entry: entries("object19"),
#                                language: languages("ja"),
#                                body: "",
#          assert_equal "no", doc.translated
#        end
#      end
      
      should "create paragraphs for English document" do
        doc = Document.create(entry: entries("builtin19"),
                              language: languages("en"),
                              body: "aa\nbb\n\n\ncc\n\ncc\n")
        paras = doc.paragraphs
        assert_equal [nil, nil, nil], paras.map(&:original)
        assert_equal ["aa\nbb", "cc", "cc"], paras.map(&:body)
        assert paras[1].id == paras[2].id
      end
      
#      should "create paragraphs for translated document" do
#        doc = Document.create(entry: entries("builtin19"),
#                              language: languages("tt"))
#        paras = doc.paragraphs
#        assert_equal [nil, nil], paras.map(&:original)
#        assert_equal ["aa\nbb\n", "cc"], paras.map(&:body)
#      end
    end
  end
end
