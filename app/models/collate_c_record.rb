class CollateCRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :collate_c }
end
