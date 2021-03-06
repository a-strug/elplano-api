# frozen_string_literal: true

module Api
  module V1
    # Api::V1::StatusesController
    #
    #   Authenticated user status management
    #
    class StatusesController < ApplicationController
      specify_title_header 'Status'

      specify_serializers default: UserStatusSerializer

      # GET : api/v1/status
      #
      # Get authenticated user status
      #
      def show
        render_resource current_user.status, status: :ok
      end

      # PATCH/PUT : api/v1/status
      #
      # Update authenticated user status
      #
      def update
        status = UserStatus.find_or_initialize_by(user_id: current_user.id)

        status.update!(status_params)

        render_resource status, status: :ok
      end

      # DELETE : api/v1/status
      #
      # Delete authenticated user status
      #
      def destroy
        current_user.status&.destroy!

        head :no_content
      end

      private

      def status_params
        params.require(:user_status).permit(:emoji, :message)
      end
    end
  end
end
