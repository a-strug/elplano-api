# frozen_string_literal: true

require 'acceptance_helper'

resource 'Labels' do
  explanation <<~DESC
    El Plano labels API.
    
    Label attributes :

      - `title` - Represents email that was used to register a label in the application(unique in application scope).
      - `description` - Represents used's label name.
      - `color` - `false` if regular label `true`, if the label has access to application settings.
      - `text_color` - `false` if the label did not confirm his address otherwise `true`.
      - `timestamps`
  DESC

  let_it_be(:student)  { create(:student, :group_supervisor) }

  let_it_be(:token) { create(:token, resource_owner_id: student.user.id).token }
  let_it_be(:authorization) { "Bearer #{token}" }

  let_it_be(:label) { create(:label, group: student.group) }

  let_it_be(:id) { label.id }

  header 'Accept',        'application/vnd.api+json'
  header 'Content-Type',  'application/vnd.api+json'
  header 'Authorization', :authorization

  get 'api/v1/labels' do
    example 'INDEX : Retrieve a list of labels' do
      explanation <<~DESC
        Returns a list of labels created by authenticated student.

        <b>Optional filter params</b> :

        - `"search": "part_of_the_title_or_description"` - Returns labels founded by provided search term(title, description).

        Example: 

        <pre>
        {
          "filters": {
            "search": "lorem.."
          }
        }
        </pre>

        For more details see "Filters" and "Pagination" sections in the README section. 

        <b>NOTE:<b>

          - By default, this endpoint returns labels sorted by recently created.
          - By default, this endpoint returns labels limited by 15

        See label attributes description in the section description.
      DESC

      do_request

      expected_body = LabelSerializer.new([label]).serialized_json

      expect(status).to eq(200)
      expect(response_body).to eq(expected_body)
    end
  end

  get 'api/v1/labels/:id' do
    example 'SHOW : Retrieve information about requested label' do
      explanation <<~DESC
        Returns a single instance of the label.

        See label attributes description in the section description.
      DESC

      do_request

      expected_body = LabelSerializer.new(label).serialized_json

      expect(status).to eq(200)
      expect(response_body).to eq(expected_body)
    end
  end

  post 'api/v1/labels' do
    with_options scope: %i[label] do
      parameter :title, 'Text identity of the label(uniq in student scope)',
                required: true

      parameter :description, 'Label detailed description'

      parameter :color, 'The background color (HEX)',
                default: Label::DEFAULT_COLOR
    end

    let(:raw_post) do
      { label: attributes_for(:label).without(:group_id) }.to_json
    end

    example 'CREATE : Creates a new label' do
      explanation <<~DESC
        Creates and returns created label.
      DESC

      do_request

      created_label = student.group.labels.order(id: :asc).last

      expected_body = LabelSerializer.new(created_label).serialized_json

      expect(status).to eq(201)
      expect(response_body).to eq(expected_body)
    end
  end

  patch 'api/v1/labels/:id' do
    with_options scope: %i[lable] do
      parameter :title, 'Text identity of the label(uniq in student scope)',
                required: true

      parameter :description, 'Label detailed description'

      parameter :color, 'The background color (HEX)'
    end

    let(:raw_post) do
      { label: attributes_for(:label).without(:group_id) }.to_json
    end

    example 'UPDATE : Updates selected label state' do
      explanation <<~DESC
        Updates label returns updated label.

        See label attributes description in the section description.
      DESC

      do_request

      expected_body = LabelSerializer.new(label.reload).serialized_json

      expect(status).to eq(200)
      expect(response_body).to eq(expected_body)
    end
  end

  delete 'api/v1/labels/:id' do
    example 'DELETE : Delete selected label' do
      explanation <<~DESC
        Permanently deletes label and all related to that label data.
        
        <b>WARNING!</b>: This action cannot be undone.
      DESC

      do_request

      expect(status).to eq(204)
    end
  end
end
