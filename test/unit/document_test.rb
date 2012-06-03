require 'test_helper'
require 'rdoc_helper.rb'

module RubyApi
  class DocumentTest < ActiveSupport::TestCase
    context "when creating an instance" do
      context "and validating attirbutes" do
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
      end

#      context "and setting #translated" do
#        should "set 'no' for document not translated" do
#          doc = Document.create(entry: entries("object19"),
#                                language: languages("ja"),
#                                body: "",
#          assert_equal "no", doc.translated
#        end
#      end
      
      context "and creating paragraphs" do
        setup do
          @eng_doc = Document.create(entry: entries("builtin19"),
                                     language: languages("en"),
                                     body: "aa\nbb\n\n\ncc\n\ncc\n")
        end

        should "create paragraphs for English document" do
          paras = @eng_doc.paragraphs
          assert_equal [nil, nil, nil], paras.map(&:original)
          assert_equal ["aa\nbb", "cc", "cc"], paras.map(&:body)
          assert paras[1].id == paras[2].id
        end
        
        should "create paragraphs for translated document" do
          doc = Document.create(entry: entries("builtin19"),
                                language: languages("tt"))
          paras = doc.paragraphs
          assert_equal @eng_doc.paragraphs, paras.map(&:original)
          assert_equal [nil, nil, nil], paras.map(&:body)
        end
      end
    end
  end
end
