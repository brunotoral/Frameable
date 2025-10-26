require "swagger_helper"

RSpec.describe "FramesController", type: :request do
  let(:parsed_body) { JSON.parse(response.body, symbolize_names: true) }

  path "/frames" do
    get "list frames" do
      tags "List Frames"
      produces "application/json"

      response "200", "ok" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :number, example: 77 },
              center_y: { type: :string, example: "123.4567" },
              center_x: { type: :string, example: "321.8765" },
              width: { type: :string, example: "65.0987" },
              height: { type: :string, example: "77.4589" },
              circles_count: { type: :number, example: 3 },
              highest_circle_position: {
                type: :object,
                properties: {
                  center_x: { type: :string, example: "12" },
                  center_y: { type: :string, example: "17" }
                },
                nullable: true
              },
              lowest_circle_position: {
                type: :object,
                properties: {
                  center_x: { type: :string, example: "12" },
                  center_y: { type: :string, example: "17" }
                },
                nullable: true
              },
              leftmost_circle_position: {
                type: :object,
                properties: {
                  center_x: { type: :string, example: "12" },
                  center_y: { type: :string, example: "17" }
                },
                nullable: true
              },
              rightmost_circle_position: {
                type: :object,
                properties: {
                  center_x: { type: :string, example: "12" },
                  center_y: { type: :string, example: "17" }
                },

                nullable: true
              },
              updated_at: { type: :string, example: "2025-10-22T11:45:02.833Z" },
              created_at: { type: :string, example: "2025-10-22T11:45:02.833Z" }
            },
            required: %w[id center_y center_x width height]
          }

        let!(:frames) { Fabricate.times(3, :frame_base) }
        let(:expected_response)  do
          frames.map do
            _1.as_json.merge(
              highest_circle_position: nil,
              lowest_circle_position: nil,
              leftmost_circle_position: nil,
              rightmost_circle_position: nil
            ).deep_symbolize_keys
          end
        end

        run_test! do  |response|
          expect(parsed_body).to match_array(expected_response)
        end
      end
    end

    post "create frame" do
      tags "Frame Creation"
      produces "application/json"
      consumes "application/json"
      parameter name: :frame, in: :body, schema: {
        type: :object,
        properties: {
          center_y: { type: :number, format: :double, example: 10.0 },
          center_x: { type: :number, format: :double, example: 30.0 },
          width: { type: :number, format: :double, example: 22.0 },
          height: { type: :number, format: :double, example: 14.0 }
        },
        required: %w[center_y center_x width height]
      }

      context "with valid attributes" do
        response 201, "created" do
          schema type: :object,
            properties: {
              id: { type: :number, example: 77 },
              center_y: { type: :string, example: "123.4567" },
              center_x: { type: :string, example: "321.8765" },
              width: { type: :string, example: "65.0987" },
              height: { type: :string, example: "77.4589" },
              updated_at: { type: :string, example: "2025-10-22T11:45:02.833Z" },
              created_at: { type: :string, example: "2025-10-22T11:45:02.833Z" }
            },
            required: %w[id center_y center_x width height]


            let(:frame) { Fabricate.attributes_for(:frame) }
            let(:request_params) { { frame: } }

            let(:expected_response) do
              {
                center_y: frame[:center_y].to_s,
                center_x: frame[:center_x].to_s,
                width: frame[:width].to_s,
                height: frame[:height].to_s
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

          let(:frame) { Fabricate.attributes_for(:frame, center_y: nil) }
          let(:request_params) { { frame:  } }

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

  path "/frames/{id}" do
    let!(:frame) { Fabricate(:frame_base) }
    let(:id) { frame.id }

    get "show frame" do
      tags "Show Frame"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer, required: true

      context "when the frame exists" do
        response 200, "ok" do
          schema type: :object,
            properties: {
              id: { type: :number, example: 77 },
              center_y: { type: :string, example: "123.4567" },
              center_x: { type: :string, example: "321.8765" },
              width: { type: :string, example: "65.0987" },
              height: { type: :string, example: "77.4589" },
              circles_count: { type: :number, example: 3 },
              highest_circle_position: {
                type: :object,
                properties: {
                  center_x: { type: :string, example: "12" },
                  center_y: { type: :string, example: "17" }
                },
                nullable: true
              },
              lowest_circle_position: {
                type: :object,
                properties: {
                  center_x: { type: :string, example: "12" },
                  center_y: { type: :string, example: "17" }
                },
                nullable: true
              },
              leftmost_circle_position: {
                type: :object,
                properties: {
                  center_x: { type: :string, example: "12" },
                  center_y: { type: :string, example: "17" }
                },
                nullable: true
              },
              rightmost_circle_position: {
                type: :object,
                properties: {
                  center_x: { type: :string, example: "12" },
                  center_y: { type: :string, example: "17" }
                },

                nullable: true
              },
              updated_at: { type: :string, example: "2025-10-22T11:45:02.833Z" },
              created_at: { type: :string, example: "2025-10-22T11:45:02.833Z" }
            },
            required: %w[
              id
              center_y
              center_x
              width
              height
              highest_circle_position
              lowest_circle_position
              leftmost_circle_position
              rightmost_circle_position
            ]

            let(:expected_response) { frame.as_json.deep_symbolize_keys }

            run_test! do |response|
              expect(parsed_body).to a_hash_including(expected_response)
            end
        end
      end

      context "when the frame does not exist" do
        let(:id) { 123987 }

        response 404, "not found" do
          schema type: :object,
            properties: {
              error: { type: :string, example: "Record Not Found" },
              message: { type: :string, example: "Couldn't find Frame with 'id'=\"123\"" }
            }

          let(:expected_response) do
            {
              error: "Record Not Found",
              message: "Couldn't find Frame with 'id'=\"#{id}\""
            }
          end

          run_test! do |response|
            expect(parsed_body).to a_hash_including(expected_response)
          end
        end
      end
      end

    put "update frame" do
      tags "Update Frame"
      produces "application/json"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :frame_params, in: :body, schema: {
        type: :object,
        properties: {
          center_y: { type: :number, format: :double, example: 10.0 },
          center_x: { type: :number, format: :double, example: 30.0 },
          width: { type: :number, format: :double, example: 22.0 },
          height: { type: :number, format: :double, example: 14.0 }
        }
      }

      context "with valid attributes" do
        response 200, "ok" do
          schema type: :object,
            properties: {
              id: { type: :number, example: 77 },
              center_y: { type: :string, example: "123.4567" },
              center_x: { type: :string, example: "321.8765" },
              width: { type: :string, example: "65.0987" },
              height: { type: :string, example: "77.4589" },
              updated_at: { type: :string, example: "2025-10-22T11:45:02.833Z" },
              created_at: { type: :string, example: "2025-10-22T11:45:02.833Z" }
            }

          let(:frame_params) { { frame: { center_x: new_center_x  } } }
          let(:new_center_x) { "1.99" }

          let(:expected_response) do
            {
              center_x: new_center_x,
              center_y: frame.center_y,
              width: frame.width,
              height: frame.height
            }.as_json.deep_symbolize_keys
          end

          run_test! do |response|
            expect(parsed_body).to a_hash_including(expected_response)
          end
        end
      end
    end

    delete "delete frame" do
      tags "Delete Frame"
      consumes "application/json"
      parameter name: :id, in: :path, type: :integer, required: true

      context "when the frame exists and has no associated circles" do
        let(:id) { frame.id }

        response "204", "No Content" do
          run_test! do |response|
            expect { frame.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context "when the frame exists and has associated circles" do
        let!(:frame_with_circles) { Fabricate(:frame) }
        let(:id) { frame_with_circles.id }

        response "409", "Conflict" do
          schema type: :object,
            properties: {
              error: { type: :string, example: "Deletion Failed" },
              message: { type: :string, example: "This frame cannot be deleted because it is still referenced by other records (e.g., circles). Please delete associated records first." }
            }

          run_test! do |response|
            expect(frame_with_circles.reload).to be_persisted
          end
        end
      end

      context "when the frame does not exist" do
        let(:id) { 1234 }
        response "404", "Not Found" do
          schema type: :object,
            properties: {
              error: { type: :string, example: "Record Not Found" },
              message: { type: :string, example: "Couldn't find Frame with 'id'=\"123\"" }
            }

          let(:expected_response) do
            {
              error: "Record Not Found",
              message: "Couldn't find Frame with 'id'=\"#{id}\""
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
