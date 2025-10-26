require "rails_helper"

RSpec.describe Filterable, type: :concern do
  let(:dummy_class) do
    Class.new do
      include Filterable
      def self.all; end
      def self.filter_by_name(value); self; end
      def self.filter_by_category(value); self; end
      def self.filter_by_status(value); self; end
    end
  end


  describe ".filtered" do
    before do
      allow(dummy_class).to receive(:all).and_return(dummy_class)
      allow(dummy_class).to receive(:filter_by_name).and_return(dummy_class)
      allow(dummy_class).to receive(:filter_by_category).and_return(dummy_class)
      allow(dummy_class).to receive(:filter_by_status).and_return(dummy_class)
    end

    context "when there are no filters" do
      let(:filters) { { name: nil, category: "", status: " " } }

      it "calls .all" do
        expect(dummy_class).to receive(:all).once

        dummy_class.filtered(filters:)
      end

      it "does not call blank filters" do
        expect(dummy_class).not_to receive(:filter_by_name)
        expect(dummy_class).not_to receive(:filter_by_category)
        expect(dummy_class).not_to receive(:filter_by_status)

        dummy_class.filtered(filters:)
      end
    end

    context "when there are filters" do
      let(:filters) { { name: "name", category: "category", status: "status" } }

      it "calls every filter with correct argument" do
        expect(dummy_class).to receive(:filter_by_name).with(filters[:name]).and_return(dummy_class)
        expect(dummy_class).to receive(:filter_by_category).with(filters[:category]).and_return(dummy_class)
        expect(dummy_class).to receive(:filter_by_status).with(filters[:status]).and_return(dummy_class)

        dummy_class.filtered(filters:)
      end
    end
  end
end
