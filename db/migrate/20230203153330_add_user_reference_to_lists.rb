class AddUserReferenceToLists < ActiveRecord::Migration[7.0]
  def change
    add_reference :lists, :user, foreign_key: true
  end
end
