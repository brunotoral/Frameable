require "rails_helper"

RSpec.describe Circle::Creator, type: :service do
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
    Fabricate.build(
      :circle_base,
      frame:,
      center_x: frame_center_x,
      center_y: frame_center_y,
      radius: BigDecimal("10")
    )
  end

  let(:creator) { described_class.new(frame, circle) }

  describe ".valid?" do
    context "when circle is not valid" do
      let(:circle) { Fabricate.build(:circle_base, frame:, center_y: nil) }

      it { expect(creator).to be_invalid }

      it "returns service with errors" do
        creator.valid?
        expect(creator.errors).to be_present
      end
    end

    context "when circle is inside the frame" do
      it { expect(creator).to be_valid }
    end

    context "when the circle is outside the frame" do
      let(:circle) do
        Fabricate.build(
          :circle_base,
          frame:,
          center_x: frame_center_x + frame_width,
          center_y: frame_center_y,
          radius: 1
        )
      end

      it { expect(creator).to be_invalid }

      it "adds an error about being outside the frame" do
        creator.valid?
        expect(creator.errors).to include("must be fully inside frame boundaries")
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
        creator.valid?
      end

      it { expect(creator).to be_invalid }

      it "adds an error about collision" do
        expect(creator.errors).to include("collides with another existing circle")
      end
    end

    context "when the circle does not collide with existing circles in the frame" do
      let(:circle_params) do
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
          center_x: frame_center_x + frame_width,
          center_y: frame_center_y + frame_height,
          radius: BigDecimal("1")
        )
      end

      it { expect(creator).to be_valid }

      it "does not add errors" do
        expect(creator.errors).to be_empty
      end
    end
  end

  describe ".invalid?" do
    context "when circle is not valid" do
      let(:circle) { Fabricate.build(:circle_base, frame:, center_y: nil) }

      it { expect(creator).to be_invalid }

      it "returns service with errors" do
        creator.invalid?
        expect(creator.errors).to be_present
      end
    end

    context "when circle is inside the frame" do
      it { expect(creator).to be_valid }
    end

    context "when the circle is outside the frame" do
      let(:circle) do
        Fabricate.build(:circle_base,
         frame:,
          center_x: frame_center_x + frame_width,
          center_y: frame_center_y,
          radius: 1
        )
      end

      it { expect(creator).to be_invalid }

      it "adds an error about being outside the frame" do
        creator.invalid?
        expect(creator.errors).to include("must be fully inside frame boundaries")
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
        creator.invalid?
      end

      it { expect(creator).to be_invalid }

      it "adds an error about collision" do
        expect(creator.errors).to include("collides with another existing circle")
      end
    end
  end

  describe "#save" do
    let(:called_creator) { creator.save }

    context "when the creator is not valid" do
      let(:circle) { Fabricate.build(:circle_base, frame:, center_y: nil) }

      it "returns false" do
        expect(called_creator).to be_falsy
      end

      it "does not save the circle" do
        expect { called_creator }.not_to change(Circle, :count)
      end
    end

    context "when the creator is valid" do
      let(:circle) { Fabricate.build(:circle_base, frame:, center_x: 0, center_y: 0, radius: 1) }

      it "returns true" do
        expect(called_creator).to be_truthy
      end

      it "saves the circle" do
        expect { called_creator }.to change(Circle, :count).by(1)
      end
    end
  end
end
