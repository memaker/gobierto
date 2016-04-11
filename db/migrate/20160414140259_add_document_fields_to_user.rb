class AddDocumentFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :document_type, :string
    add_column :users, :document_number, :string
  end
end
