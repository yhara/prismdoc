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

      context "and creating paragraphs" do
        setup do
          @eng_doc = Document.create(entry: entries("builtin19"),
                                     language: languages("en"),
                                     body: "aa\nbb\n\n\ncc\n\ncc\n AA\n \n BB")
        end

        should "create paragraphs for English document" do
          paras = @eng_doc.paragraphs
          assert_equal ["aa\nbb", "cc", "cc", " AA\n \n BB"], paras.map(&:body)
          assert_equal [nil, nil, nil, nil], paras.map(&:original)
          assert paras[1].id == paras[2].id
        end
        
        should "create paragraphs for translated document" do
          doc = Document.create(entry: entries("builtin19"),
                                language: languages("tt"))
          paras = doc.paragraphs
          assert_equal @eng_doc.paragraphs, paras.map(&:original)
          assert_equal [nil, nil, nil, nil], paras.map(&:body)
        end
      end

      context "and setting #translated" do
        setup do
          @eng_doc18 = Document.create!(entry: entries("builtin18"),
                                        language: languages("en"),
                                        body: "aa\nbb\n\n\ncc\n\ncc\n")
          @eng_doc19 = Document.create!(entry: entries("builtin19"),
                                        language: languages("en"),
                                        body: "aa\nbb\n\n\ncc\n\ncc\n")
        end

        should "set 'no' for a document not translated at all" do
          doc = Document.create!(entry: entries("builtin19"),
                                 language: languages("tt"))
          assert_equal "no", doc.translated
        end

        should "set 'partially' for a document partially translated" do
          doc18 = Document.create!(entry: entries("builtin18"),
                                   language: languages("tt"))
          doc18.paragraphs.first.update_attributes!(body: "ddd")
          
          doc = Document.create!(entry: entries("builtin19"),
                                 language: languages("tt"))
          assert_equal "partially", doc.translated
        end

        should "set 'yes' for a document fully translated" do
          doc18 = Document.create!(entry: entries("builtin18"),
                                   language: languages("tt"))
          doc18.paragraphs.each do |para18|
            para18.update_attributes!(body: "ddd")
          end
          
          doc = Document.create!(entry: entries("builtin19"),
                                 language: languages("tt"))
          assert_equal "yes", doc.translated
        end
      end
    end
  end
end
