require "swagger_helper"

RSpec.describe "CirclesController", type: :request do
  let(:parsed_body) { JSON.parse(response.body, symbolize_names: true) }

  path "/circles" do
    get "List and filter circles"  do
      tags "Circles"
      produces "application/json"
      consumes "application/json"
      parameter name: :center_x, in: :query, type: :string, required: false, description: "Center X coordinate for the search radius"
      parameter name: :center_y, in: :query, type: :string, required: false, description: "Center Y coordinate for the search radius"
      parameter name: :radius, in: :query, type: :string, required: false, description: "Radius for the search area"
      parameter name: :frame_id, in: :query, type: :string, required: false, description: "Optional frame ID to filter circles"

      response 200, "ok" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :number, example: 1 },
              center_y: { type: :string, example: "10.0" },
              center_x: { type: :string, example: "20.0" },
              radius: { type: :string, example: "5.0" },
              frame_id: { type: :number, example: 77 },
              updated_at: { type: :string, example: "2025-10-22T11:45:02.833Z" },
              created_at: { type: :string, example: "2025-10-22T11:45:02.833Z" }
            }
          }

        let!(:target_frame) { Fabricate(:frame_base) }
        let!(:other_frame) { Fabricate(:frame_base) }
        let!(:circle_inside_target_frame1) { Fabricate(:circle, frame: target_frame, center_x: 0, center_y: 0, radius: 1) }
        let!(:circle_inside_target_frame2) { Fabricate(:circle, frame: target_frame, center_x: 0.5, center_y: 0.5, radius: 0.5) }
        let!(:circle_inside_other_frame) { Fabricate(:circle, frame: other_frame, center_x: 0, center_y: 0, radius: 1) }
        let!(:circle_outside_radius1) { Fabricate(:circle, frame: target_frame, center_x: 5, center_y: 5, radius: 1) }
        let!(:circle_outside_radius2) { Fabricate(:circle, frame: target_frame, center_x: 1.5, center_y: 0, radius: 1) }
        let(:expected_query_string) { URI.encode_www_form(expected_query_params) }
        context "when filters are applied" do
          let(:center_x) { 0.0 }
          let(:center_y) { 0.0 }
          let(:radius) { 2.0 }
          let(:frame_id) { target_frame.id }

          let(:expected_query_params) do
            {
              center_x: center_x,
              center_y: center_y,
              radius: radius,
              frame_id: frame_id
            }.compact
          end

          let(:expected_ids) do
            [ circle_inside_target_frame1.id, circle_inside_target_frame2.id ]
          end

          run_test! do |response|
            actual_ids = parsed_body.map { |c| c[:id] }
            expect(actual_ids).to match_array(expected_ids)
            expect(request.fullpath).to eq("/circles?#{expected_query_string}")
          end
        end


        context "when no filters are applied" do
          let(:expected_ids) { Circle.ids }

          run_test! do |response|
            actual_ids = parsed_body.map { |c| c[:id] }
            expect(actual_ids).to match_array(expected_ids)
            expect(request.fullpath).to eq("/circles")
          end
        end
      end
    end
  end

  path "/circles/{id}" do
    let(:frame) { Fabricate(:frame_base, center_x: 0, center_y: 0, width: 100, height: 100) }
    let!(:circle) { Fabricate(:circle_base, frame:, center_y: 0, center_x: 0) }
    let(:id) { circle.id }

    put "Update Circle" do
      tags "Circles"
      produces "application/json"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :circle_params, in: :body, schema: {
        type: :object,
        properties: {
          center_y: { type: :number, format: :double, example: 10.0 },
          center_x: { type: :number, format: :double, example: 30.0 },
          radius: { type: :number, format: :double, example: 14.0 }
        }
      }

      context "when circle exists" do
        response "200", "ok" do
          schema type: :object,
            properties: {
              id: { type: :number, example: 77 },
              center_y: { type: :string, example: "123.4567" },
              center_x: { type: :string, example: "321.8765" },
              radius: { type: :string, example: "77.4589" },
              updated_at: { type: :string, example: "2025-10-22T11:45:02.833Z" },
              created_at: { type: :string, example: "2025-10-22T11:45:02.833Z" }
            }

          let(:circle_params) { { circle: { radius: new_radius } } }
          let(:new_radius) { "5.0" }

          let(:expected_response) do
            {
              radius: new_radius,
              center_y: circle.center_y,
              center_x: circle.center_x
            }.as_json.deep_symbolize_keys
          end

          run_test! do |response|
            expect(parsed_body).to a_hash_including(expected_response)
          end
        end
      end

      context "with invalid params" do
        response "422", "unprocessable entity" do
          schema type: :object,
            properties: {
              error: { type: :string, example: "Record Invalid" },
              message: { type: :string, example: "Radius is not a number" }
            }

          let(:circle_params) { { circle: {  radius: new_radius } } }
          let(:new_radius) { "foobar" }

          let(:expected_response) do
            {
              error: "Record Invalid",
              message: "Radius is not a number"
            }
          end

          run_test! do |response|
            expect(parsed_body).to a_hash_including(expected_response)
          end
        end
      end

      context "when circle does not exist" do
        response "404", "Not Found" do
          schema type: :object,
            properties: {
              error: { type: :string, example: "Record Not Found" },
              message: { type: :string, example: "Couldn't find Circle with 'id'=\"123\"" }
            }

          let(:id) { 999888 }
          let(:circle_params) { { circle: {  radius: new_radius } } }
          let(:new_radius) { "7.77" }

          let(:expected_response) do
            {
              error: "Record Not Found",
              message: "Couldn't find Circle with 'id'=\"#{id}\""
            }
          end

          run_test! do |response|
            expect(parsed_body).to a_hash_including(expected_response)
          end
        end
      end
    end

    delete "Delete Circle" do
      tags "Circles"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, required: true

      context "when circle exists" do
        response "204", "No Content" do
          run_test! do
            expect { circle.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context "when circle does not exist" do
        let(:id) { 777 }

        response "404", "Not Found" do
          let(:expected_response) do
            {
              error: "Record Not Found",
              message: "Couldn't find Circle with 'id'=\"#{id}\""
            }
          end

          run_test! do |response|
            expect(parsed_body).to a_hash_including(expected_response)
          end
        end
      end
    end
  end
end
