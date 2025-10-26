require "rails_helper"

RSpec.describe Frame, type: :model do
  let(:frame) { Fabricate(:frame_base, center_x: 50, center_y: 50, width: 20, height: 40) }
  let(:half) { BigDecimal(2) }

  describe "associations" do
    it { is_expected.to have_many(:circles) }
    it { is_expected.to have_one(:lowest_circle).order(center_y: :asc).class_name("Circle") }
    it { is_expected.to have_one(:leftmost_circle).order(center_x: :asc).class_name("Circle") }
    it { is_expected.to have_one(:rightmost_circle).order(center_x: :desc).class_name("Circle") }
    it { is_expected.to have_one(:highest_circle).order(center_y: :desc).class_name("Circle") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:center_x) }
    it { is_expected.to validate_numericality_of(:center_x) }
    it { is_expected.to validate_presence_of(:center_y) }
    it { is_expected.to validate_numericality_of(:center_y) }
    it { is_expected.to validate_presence_of(:height) }
    it { is_expected.to validate_numericality_of(:height).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:width) }
    it { is_expected.to validate_numericality_of(:width).is_greater_than(0) }
  end

  describe "#left_edge" do
    it "calculates the left edge correctly" do
      expected_left_edge = frame.center_x - (frame.width / half)
      expect(frame.left_edge).to eq(expected_left_edge)
    end
  end

  describe "#right_edge" do
    it "calculates the right edge correctly" do
      expected_right_edge = frame.center_x + (frame.width / half)
      expect(frame.right_edge).to eq(expected_right_edge)
    end
  end

  describe "#top_edge" do
    it "calculates the top edge correctly" do
      expected_top_edge = frame.center_y - (frame.height / half)
      expect(frame.top_edge).to eq(expected_top_edge)
    end
  end

  describe "#bottom_edge" do
    it "calculates the bottom edge correctly" do
      expected_bottom_edge = frame.center_y + (frame.height / half)
      expect(frame.bottom_edge).to eq(expected_bottom_edge)
    end
  end

  describe "#wraps?" do
    let(:parent_frame) { Fabricate(:frame, center_x: 50, center_y: 50, width: 100, height: 100) }

    context "when the circle is completely wrapped by the frame" do
      let(:wrapped_circle_frame) { Fabricate(:frame, center_x: 50, center_y: 50, width: 80, height: 80) }

      it { expect(parent_frame.wraps?(wrapped_circle_frame)).to be_truthy }
    end

    context "when the circle extends beyond the left edge" do
      let(:overlapping_circle) { Fabricate(:frame, center_x: -1, center_y: 50, width: 20, height: 20) }

      it { expect(parent_frame.wraps?(overlapping_circle)).to be_falsy }
    end

    context "when the circle touches the edges" do
      let(:touching_circle) { Fabricate(:frame, center_x: 50, center_y: 50, width: 100, height: 100) }

      it { expect(parent_frame.wraps?(touching_circle)).to be_truthy }
    end
  end

  describe "#collides_with_existing_frame?" do
    let(:subject_frame) { Fabricate(:frame, center_x: 50, center_y: 50, width: 20, height: 40) }

    context "when there is an existing frame that collides with the subject frame" do
      let!(:colliding_frame) { Fabricate(:frame, center_x: 55, center_y: 50, width: 20, height: 20) }

      it { expect(subject_frame.collides_with_existing_frame?).to be_truthy }
    end

    context "when there is no existing frame that collides with the subject frame" do
      let!(:non_colliding_frame) { Fabricate(:frame, center_x: 100, center_y: 100, width: 10, height: 10) }

      it { expect(subject_frame.collides_with_existing_frame?).to be_falsy }
    end

    context "when the subject frame is persisted" do
      let!(:persisted_subject_frame) { Fabricate(:frame, center_x: 50, center_y: 50, width: 20, height: 40) }

      it "does not collide with itself" do
        expect(persisted_subject_frame.collides_with_existing_frame?).to be_falsy
      end

      context "and there is another frame that collides" do
        let!(:another_colliding_frame) { Fabricate(:frame, center_x: 55, center_y: 50, width: 20, height: 20) }

        it { expect(persisted_subject_frame.collides_with_existing_frame?).to be_truthy }
      end
    end

    context "edge cases for collision" do
      let!(:base_frame) { Fabricate(:frame, center_x: 50, center_y: 50, width: 20, height: 20) }

      it "returns true when frames just touch on the right" do
        test_frame = Fabricate.build(:frame, center_x: 60, center_y: 50, width: 20, height: 20)
        expect(test_frame.collides_with_existing_frame?).to be_truthy
      end

      it "returns true when frames just touch on the top" do
        test_frame = Fabricate.build(:frame, center_x: 50, center_y: 60, width: 20, height: 20)
        expect(test_frame.collides_with_existing_frame?).to be_truthy
      end

      it "returns false when frames are adjacent but do not overlap (gap)" do
        test_frame = Fabricate.build(:frame, center_x: 71, center_y: 50, width: 20, height: 20)
        expect(test_frame.collides_with_existing_frame?).to be_falsy
      end
    end
  end
end
