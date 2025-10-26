require "rails_helper"

RSpec.describe Circle, type: :model do
  let(:circle) { Fabricate(:circle, center_x: 10, center_y: 20, radius: 5) }

  describe "associations" do
    it { is_expected.to belong_to(:frame).counter_cache(true) }
  end

  describe "scopes" do
    let(:frame_one) { Fabricate(:frame_base) }
    let(:frame_two) { Fabricate(:frame_base) }
    let(:circle_frame_one_a) { Fabricate(:circle, frame: frame_one, center_x: 10.0, center_y: 10.0, radius: 2.0) }
    let(:circle_frame_one_b) { Fabricate(:circle, frame: frame_one, center_x: 10.0, center_y: 10.0, radius: 2.0) }
    let(:circle_frame_two_a) { Fabricate(:circle, frame: frame_two, center_x: 20.0, center_y: 20.0, radius: 1.0) }

    describe ".filter_by_frame_id" do
      it "returns circles with the specified frame_id" do
        expect(described_class.filter_by_frame_id(frame_one.id)).to match_array([ circle_frame_one_a, circle_frame_one_b ])
      end

      it "does not return circles with a different frame_id" do
        expect(described_class.filter_by_frame_id(frame_one.id)).not_to include(circle_frame_two_a)
      end

      it "returns an empty collection if no circles match the frame_id" do
        expect(described_class.filter_by_frame_id(0)).to be_empty
      end
    end

    describe ".filter_by_area" do
      let(:filter_params) { { center_x: 10.0, center_y: 10.0, radius: 5.0 } }
      let(:expected_collection) { [ circle_frame_one_a, circle_frame_one_b ] }

      it "returns circles whose centers are within the calculated containment distance" do
        expect(described_class.filter_by_area(filter_params)).to match_array(expected_collection)
      end

      context "when parameters are missing" do
        it "raises an ArgumentError if center_x is missing" do
          expect { described_class.filter_by_area(center_y: 10, radius: 5) }
            .to raise_error(ArgumentError, "Missing parameters: center_x, center_y and radius are required for area filter")
        end

        it "raises an ArgumentError if center_y is missing" do
          expect { described_class.filter_by_area(center_x: 10, radius: 5) }
            .to raise_error(ArgumentError, "Missing parameters: center_x, center_y and radius are required for area filter")
        end

        it "raises an ArgumentError if radius is missing" do
          expect { described_class.filter_by_area(center_x: 10, center_y: 10) }
            .to raise_error(ArgumentError, "Missing parameters: center_x, center_y and radius are required for area filter")
        end

        it "raises an ArgumentError if all parameters are missing" do
          expect { described_class.filter_by_area({}) }
            .to raise_error(ArgumentError, "Missing parameters: center_x, center_y and radius are required for area filter")
        end
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:center_x) }
    it { is_expected.to validate_numericality_of(:center_x) }
    it { is_expected.to validate_presence_of(:center_y) }
    it { is_expected.to validate_numericality_of(:center_y) }
    it { is_expected.to validate_presence_of(:radius) }
    it { is_expected.to validate_numericality_of(:radius).is_greater_than(0) }
  end

  describe "#left_edge" do
    it { expect(circle.left_edge).to eq(5) }
  end

  describe "#right_edge" do
    it { expect(circle.right_edge).to eq(15) }
  end

  describe "#top_edge" do
    it { expect(circle.top_edge).to eq(15) }
  end

  describe "#bottom_edge" do
    it { expect(circle.bottom_edge).to eq(25) }
  end


  describe "#overlaps_existing_circles?" do
    let(:frame) { Fabricate(:frame_base) }
    let!(:existing_circle) do
      Fabricate(
        :circle,
        frame:,
        center_x: 10,
        center_y: 10,
        radius: 5
      )
    end

    context "when there are no overlapping circles" do
      let(:non_overlapping_circle) do
        Fabricate.build(
          :circle,
          frame:,
          center_x: 100,
          center_y: 100,
          radius: 5
        )
      end

      let(:just_outside_circle) do
        Fabricate.build(
          :circle,
          frame:,
          center_x: 21,
          center_y: 10,
          radius: 5
        )
      end

      let(:circles) { frame.circles }

      it "returns false for a circle far away" do
        expect(non_overlapping_circle.overlaps_existing_circles?(circles)).to be(false)
      end

      it "returns false for a circle just outside the boundary" do
        expect(just_outside_circle.overlaps_existing_circles?(circles)).to be(false)
      end
    end

    context "when there are overlapping circles" do
      let(:partially_overlapping_circle) do
        Fabricate.build(
          :circle,
          frame:,
          center_x: 15,
          center_y: 10,
          radius: 5
        )
      end

      let(:containing_circle) do
        Fabricate.build(
          :circle,
          frame:,
          center_x: 10,
          center_y: 10,
          radius: 10
        )
      end

      let(:contained_circle) do
        Fabricate.build(
          :circle,
          frame:,
          center_x: 10,
          center_y: 10,
          radius: 2
        )
      end

      let(:circles) { frame.circles }

      it "returns true for a partially overlapping circle" do
        expect(partially_overlapping_circle.overlaps_existing_circles?(circles)).to be(true)
      end

      it "returns true for a completely containing circle" do
        expect(containing_circle.overlaps_existing_circles?(circles)).to be(true)
      end

      it "returns true for a contained circle" do
        expect(contained_circle.overlaps_existing_circles?(circles)).to be(true)
      end
    end
  end
end
