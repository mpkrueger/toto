class ItemSerializer < ActiveModel::Serializer
  attributes :id, :list_id, :description, :completed
end