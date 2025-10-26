
require "rails_helper"

RSpec.describe Circle::Updater, type: :service do
  let(:frame_width) { BigDecimal("100") }
  let(:frame_height) { BigDecimal("100") }
  let(:frame_center_x) { BigDecimal("0") }
  let(:frame_center_y) { BigDecimal("0") }

  let(:frame) do
    Fabricate(:frame,
              center_x: frame_center_x,
              center_y: frame_center_y,
              width: frame_width,
              height: frame_height,
              circles: []
             )
  end

  let(:circle) do
    Fabricate(
      :circle_base,
      frame:,
      center_x: frame_center_x,
      center_y: frame_center_y,
      radius: BigDecimal("10")
    )
  end

  let(:params) do
    {
      center_x: frame_center_x + BigDecimal("1"),
      center_y: frame_center_y + BigDecimal("1"),
      radius: BigDecimal("12")
    }.with_indifferent_access
  end

  let(:updater) { described_class.new(circle, params) }

  describe ".valid?" do
    context "when circle is not valid" do
      let(:params) do
        {
          radius: nil
        }.with_indifferent_access
      end

      it { expect(updater).to be_invalid }

      it "returns service with errors" do
        updater.valid?
        expect(updater.errors).to be_present
      end
    end

    context "when circle is inside the frame" do
      it { expect(updater).to be_valid }
    end

    context "when the circle is outside the frame" do
      let(:params) do
        {
          center_x: frame_center_x + frame_width
        }
      end

      it { expect(updater).to be_invalid }

      it "adds an error about being outside the frame" do
        updater.valid?
        expect(updater.errors).to include("must be fully inside frame boundaries")
      end
    end

    context "when the circle collides with existing circles in the frame" do
      let(:params) do
        {
          center_x: frame_center_x,
          center_y: frame_center_y,
          radius: BigDecimal("1")
        }
      end

      before do
        Fabricate(:circle_base,
                  frame:,
                  center_x: frame_center_x,
                  center_y: frame_center_y + BigDecimal("1"),
                  radius: BigDecimal("10")
                 )
        updater.valid?
      end

      it { expect(updater).to be_invalid }

      it "adds an error about collision" do
        expect(updater.errors).to include("collides with another existing circle")
      end
    end

    context "when the circle does not collide with existing circles in the frame" do
      let(:params) do
        {
          center_x: frame_center_x,
          center_y: frame_center_y,
          radius: BigDecimal("10")
        }
      end

      before do
        Fabricate(:circle_base,
                  frame:,
                  center_x: frame_center_x + frame_width,
                  center_y: frame_center_y + frame_height,
                  radius: BigDecimal("1")
                 )
      end

      it { expect(updater).to be_valid }

      it "does not add errors" do
        expect(updater.errors).to be_empty
      end
    end
    end

  describe ".invalid?" do
    context "when circle is not valid" do
      let(:params) { { center_y: nil } }

      it { expect(updater).to be_invalid }

      it "returns service with errors" do
        updater.invalid?
        expect(updater.errors).to be_present
      end
    end

    context "when circle is inside the frame" do
      it { expect(updater).to be_valid }
    end

    context "when the circle is outside the frame" do
      let(:params) do
        {
          center_x: frame_center_x + frame_width,
          center_y: frame_center_y,
          radius: 1
        }
      end

      it { expect(updater).to be_invalid }

      it "adds an error about being outside the frame" do
        updater.invalid?
        expect(updater.errors).to include("must be fully inside frame boundaries")
      end
    end

    context "when the circle collides with existing circles in the frame" do
      let(:circle) do
        Fabricate.build(:circle_base,
                        frame:,
                        center_x: frame_center_x,
                        center_y: frame_center_y,
                        radius: BigDecimal("10")
                       )
      end

      before do
        Fabricate(:circle_base,
                  frame:,
                  center_x: frame_center_x,
                  center_y: frame_center_y + BigDecimal("1"),
                  radius: BigDecimal("10")
                 )
        frame.reload
        updater.invalid?
      end

      it { expect(updater).to be_invalid }

      it "adds an error about collision" do
        expect(updater.errors).to include("collides with another existing circle")
      end
    end
    end

  describe "#save" do
    let(:called_updater) { updater.save }

    context "when the updater is not valid" do
      let(:params) { { center_y: nil } }

      it "returns false" do
        expect(called_updater).to be_falsy
      end
    end

    context "when the updater is valid" do
      let(:params) { { radius: 2 } }

      it "returns true" do
        expect(called_updater).to be_truthy
      end
    end
  end
end
