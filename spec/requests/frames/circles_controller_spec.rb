
require "swagger_helper"

RSpec.describe "Frames::CirclesController", type: :request do
  let(:parsed_body) { JSON.parse(response.body, symbolize_names: true) }
  path "/frames/{frame_id}/circles" do
    let!(:frame) { Fabricate(:frame_base, center_x: 0, center_y: 2, width: 10, height: 10) }
    let(:frame_id) { frame.id }

    post "create circle" do
      tags "Create Circle"
      produces "application/json"
      consumes "application/json"
      parameter name: :frame_id, in: :path, type: :integer, required: true
      parameter name: :circle, in: :body, schema: {
        type: :object,
        properties: {
          center_y: { type: :number, format: :double, example: 10.0 },
          center_x: { type: :number, format: :double, example: 30.0 },
          radius: { type: :number, format: :double, example: 22.0 }
        },
        required: %w[center_y center_x radius]
      }

      context "with valid params" do
        response "201", "creted" do
          schema type: :object,
            properties: {
              id: { type: :number, example: 77 },
              center_y: { type: :string, example: "123.4567" },
              center_x: { type: :string, example: "321.8765" },
              radius: { type: :string, example: "77.4589" },
              updated_at: { type: :string, example: "2025-10-22T11:45:02.833Z" },
              created_at: { type: :string, example: "2025-10-22T11:45:02.833Z" }
            }

          let(:circle) { Fabricate.attributes_for(:circle_base, center_y: 0.0, center_x: 0.0, radius: 1.0) }

          let(:expected_response) do
            {
              center_y: circle[:center_y].to_s,
              center_x: circle[:center_x].to_s,
              radius: circle[:radius].to_s
            }
          end

          run_test! do |response|
            expect(parsed_body).to a_hash_including(expected_response)
          end
        end
      end

      context "with invalid attributes" do
        response 422, "unprocessable entity" do
          schema type: :object,
            properties: {
              error: { type: :string, example: "Record Invalid" },
              message: { type: :string, example: "Center Y can't be blank" }
            }

          let(:circle) { Fabricate.attributes_for(:circle, center_y: nil) }
          let(:request_params) { { circle:  } }

          let(:expected_response) do
            {
              error: "Record Invalid",
              message: "Center y can't be blank and Center y is not a number"
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
