
require "rails_helper"

RSpec.describe Frame::Creator, type: :service do
  let(:frame_width) { BigDecimal("100") }
  let(:frame_height) { BigDecimal("100") }
  let(:frame_center_x) { BigDecimal("0") }
  let(:frame_center_y) { BigDecimal("0") }

  let!(:existing_frame) do
    Fabricate(:frame,
      center_x: frame_center_x,
      center_y: frame_center_y,
      width: frame_width,
      height: frame_height,
      circles: []
    )
  end

  let(:creator) { described_class.new(frame) }

  describe ".valid?" do
    context "when frame is not valid" do
      let(:frame) { Fabricate.build(:frame_base, center_y: nil) }

      it { expect(creator).to be_invalid }

      it "returns service with errors" do
        creator.valid?
        expect(creator.errors).to be_present
      end
    end

    context "when frame does not collides with another frame" do
      let(:frame) do
        Fabricate(
          :frame_base,
          center_x: 1500,
          center_y: 300,
          width: frame_width,
          height: frame_height
        )
      end
      it { expect(creator).to be_valid }
    end

    context "when the frame collides with existing frame" do
      let(:frame) do
        Fabricate(
          :frame_base,
          center_x: 1,
          center_y: 1,
          width: frame_width,
          height: frame_height
        )
      end

      before do
        creator.valid?
      end

      it { expect(creator).to be_invalid }

      it "adds an error to the service about collision" do
        expect(creator.errors).to include("collides with another existing frame")
      end
    end
  end

  describe ".invalid?" do
    context "when circle is not valid" do
      let(:frame) { Fabricate.build(:frame_base, center_y: nil) }

      it { expect(creator).to be_invalid }

      it "returns service with errors" do
        creator.invalid?
        expect(creator.errors).to be_present
      end
    end

    context "when the frame collides with existing frame" do
      let(:frame) do
        Fabricate(
          :frame_base,
          center_x: 1,
          center_y: 1,
          width: frame_width,
          height: frame_height
        )
      end

      before do
        creator.invalid?
      end

      it { expect(creator).to be_invalid }

      it "adds an error about collision" do
        expect(creator.errors).to include("collides with another existing frame")
      end
    end

    context "when the circle does not collide with existing frame" do
      let(:frame) do
        Fabricate(
          :frame_base,
          center_x: 100,
          center_y: 100,
          width: frame_width / 2,
          height: frame_height / 2
        )
      end


      it { expect(creator).to be_valid }

      it "does not add errors" do
        expect(creator.errors).to be_empty
      end
    end
  end

  describe "#save" do
    let(:called_creator) { creator.save }

    context "when the creator is not valid" do
      let(:frame) { Fabricate.build(:frame_base, center_y: nil) }

      it "returns false" do
        expect(called_creator).to be_falsy
      end

      it "does not save the frame" do
        expect { called_creator }.not_to change(Frame, :count)
      end
    end

    context "when the creator is valid" do
      let(:frame) { Fabricate.build(:frame_base, center_x: 200, center_y: 100, width: 1, height: 1) }

      it "returns true" do
        expect(called_creator).to be_truthy
      end

      it "saves the Frame" do
        expect { called_creator }.to change(Frame, :count).by(1)
      end
    end
  end
end
