# frozen_string_literal: true

# Uploader
#
#   Used as base uploader class
#
class Uploader < Shrine
  #
  # Generates a more organized directory structure on the storage.
  #
  # https://github.com/shrinerb/shrine/blob/v2.16.0/doc/plugins/pretty_location.md#readme
  #
  plugin :pretty_location

  #
  # The delete_promoted plugin deletes files that have been promoted,
  # after the record is saved. This means that cached files handled by
  # the attacher will automatically get deleted once they're uploaded to store.
  #
  # This also applies to any other uploaded file passed to Attacher#promote.
  #
  # https://github.com/shrinerb/shrine/blob/v2.16.0/doc/plugins/delete_promoted.md#readme
  #
  plugin :delete_promoted

  #
  # The delete_raw plugin will automatically delete raw files that have been uploaded.
  # This is especially useful when doing processing, to ensure that temporary files have been deleted after upload.
  #
  # https://github.com/shrinerb/shrine/blob/v2.16.0/doc/plugins/delete_raw.md#readme
  #
  plugin :delete_raw, storages: [:store]

  #
  # Define validations
  # For a complete list of all validation helpers, see AttacherMethods.
  #
  # http://shrinerb.com/rdoc/classes/Shrine/Plugins/ValidationHelpers/AttacherMethods.html
  #

  Attacher.promote  { |data| UploadProcessors::PromoteWorker.perform_async(data) }
  Attacher.delete   { |data| UploadProcessors::DeleteWorker.perform_async(data) }
end