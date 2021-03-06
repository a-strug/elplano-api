# frozen_string_literal: true

require 'acceptance_helper'

resource 'Admin users' do
  explanation <<~DESC
    El Plano administration: Users.
    
    #{Descriptions::Model.user}

    #{Descriptions::Model.student}

    #{Descriptions::Model.user_status}

    <b>NOTES</b> :

      - Also, include reference to student profile(additional user info)
  DESC

  let(:user)  { create(:admin, :student) }
  let(:token) { create(:token, resource_owner_id: user.id).token }
  let(:authorization) { "Bearer #{token}" }

  let(:random_user) { create(:user, :student) }
  let(:id)          { random_user.id }

  header 'Accept',        'application/vnd.api+json'
  header 'Content-Type',  'application/vnd.api+json'
  header 'Authorization', :authorization

  get 'api/v1/admin/users' do
    example 'INDEX : Retrieve a list of users' do
      explanation <<~DESC
        Returns a list of the application users.

        <b>OPTIONAL FILTERS</b> :

        - `"status": "confirmed"` - Returns users filtered by one of the status(`active`, `confirmed`, `banned`).
        - `"search": "part_of_the_username_or_email"` - Returns users found by provided search term(email, username).

        Example: 

        <pre>
        {
          "filters": {
            "status": "active",
            "search": "wat@email_or_username"
          }
        }
        </pre>

        <b>MORE INFORMATION</b> :

          - See user attributes description in the section description.
          - See "Filters" and "Pagination" sections in the README section. 

        <b>NOTE:<b>

          - By default, this endpoint returns users sorted by recently created.
          - By default, this endpoint returns users without status assumptions.
          - By default, this endpoint returns users limited by 15.
      DESC

      do_request

      expected_body = UserSerializer
                        .new([user], include: [:student])
                        .to_json

      expect(status).to eq(200)
      expect(response_body).to eq(expected_body)
    end
  end

  get 'api/v1/admin/users/:id' do
    example 'SHOW : Retrieve information about requested user' do
      explanation <<~DESC
        Returns a single instance of the user.

        <b>MORE INFORMATION</b> :

          - See user attributes description in the section description.
      DESC

      do_request

      expected_body = UserSerializer
                        .new(random_user, include: [:student])
                        .to_json

      expect(status).to eq(200)
      expect(response_body).to eq(expected_body)
    end
  end

  patch 'api/v1/admin/users/:id' do
    parameter :action_type, 'One of the action types(`ban`, `unban`, `unlock`, `confirm`)', required: true

    let(:raw_post) do
      { action_type: 'ban' }.to_json
    end

    example 'UPDATE : Updates selected user state' do
      explanation <<~DESC
        Updates user state and returns updated user.

        Available actions list:

          - `ban` - Block access to the application.
          - `unban` - Remove application access block.
          - `unlock` - Remove lock caused by wrong password input.
          - `confirm` - Confirm user account.
          - `logout` - Revoke all access tokens.

        <b>MORE INFORMATION</b> :

          - See user attributes description in the section description.
      DESC

      do_request

      expected_body = UserSerializer
                        .new(random_user.reload, include: [:student])
                        .to_json

      expect(status).to eq(200)
      expect(response_body).to eq(expected_body)
    end
  end

  delete 'api/v1/admin/users/:id' do
    example 'DELETE : Delete selected user' do
      explanation <<~DESC
        Permanently deletes user and all related to that user data.
        
        <b>WARNING!</b>: This action cannot be undone.
      DESC

      do_request

      expect(status).to eq(204)
    end
  end
end
